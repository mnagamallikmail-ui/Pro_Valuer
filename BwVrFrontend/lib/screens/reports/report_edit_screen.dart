import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../models/report_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ReportEditScreen extends StatefulWidget {
  final int reportId;

  const ReportEditScreen({super.key, required this.reportId});

  @override
  State<ReportEditScreen> createState() => _ReportEditScreenState();
}

class _ReportEditScreenState extends State<ReportEditScreen> {
  final ApiService _apiService = ApiService();
  ReportDetailModel? _report;
  bool _isLoading = true;
  String? _error;

  final Map<int, TextEditingController> _controllers = {};
  final Map<int, String> _uploadedPaths =
      {}; // placeholderId -> file name for UI
  final Map<int, PlatformFile> _stagedFiles =
      {}; // placeholderId -> actual file to upload

  bool _saving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    try {
      final r = await _apiService.getReport(widget.reportId);
      setState(() {
        _report = r;
        _isLoading = false;
        _initControllers(r);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _initControllers(ReportDetailModel r) {
    for (var v in r.values) {
      _controllers[v.placeholderId] =
          TextEditingController(text: v.textValue ?? '');
      if (v.isImage && (v.imageFilePath != null || v.hasImageData)) {
        _uploadedPaths[v.placeholderId] =
            v.imageOriginalName ?? 'Previously uploaded image';
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_report == null) return;
    setState(() => _saving = true);

    try {
      final List<Map<String, dynamic>> updateValues = [];
      for (var v in _report!.values) {
        if (!v.isImage) {
          final text = _controllers[v.placeholderId]?.text ?? '';
          if (text != (v.textValue ?? '')) {
            updateValues.add({
              'placeholderId': v.placeholderId,
              'placeholderKey': v.placeholderKey,
              'textValue': text,
            });
          }
        }
      }
      
      if (updateValues.isNotEmpty) {
        await _apiService.saveReportValues(widget.reportId, updateValues);
      }

      setState(() => _hasChanges = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Report saved successfully'),
              backgroundColor: AppTheme.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving: $e'),
              backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _uploadImage(ReportValueModel v) async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 70,
      );
      if (image == null) return; // User cancelled

      final bytes = await image.readAsBytes();
      if (bytes.isEmpty) throw Exception('Selected image is empty');

      final result = await _apiService.uploadImage(
        fileBytes: bytes,
        fileName: image.name,
        reportId: widget.reportId,
        placeholderKey: v.placeholderKey,
      );
        
      final filePath = result['filePath'] ?? result['imageUrl'];
      final originalName = result['originalName'] ?? image.name;

      if (filePath == null) {
         throw Exception('Server failed to provide a storage path');
      }

      // Save the image path to DB immediately so generator picks it up
      await _apiService.saveReportValues(widget.reportId, [
        {
          'placeholderId': v.placeholderId,
          'placeholderKey': v.placeholderKey,
          'imageFilePath': filePath,
          'imageOriginalName': originalName,
        }
      ]);
        
      if (mounted) {
        setState(() {
          _uploadedPaths[v.placeholderId] = originalName;
          v.imageOriginalName = originalName;
          v.imageFilePath = filePath;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${v.displayLabel} uploaded successfully'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking or uploading file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
          body: Center(
              child: Text('Error: $_error',
                  style: const TextStyle(color: AppTheme.danger))));
    }

    final r = _report!;

    final List<Widget> formFields = [];
    final List<ReportValueModel> allImages = [];

    String? currentSection;
    List<ReportValueModel> currentTableValues = [];

    void flushTable() {
      if (currentTableValues.isNotEmpty) {
        formFields.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TableFieldsView(
            values: currentTableValues,
            reportId: widget.reportId,
            controllers: _controllers,
            uploadedPaths: _uploadedPaths,
            onUpload: _uploadImage,
            onChanged: () => setState(() => _hasChanges = true),
          ),
        ));
        currentTableValues = [];
      }
    }

    for (var v in r.values) {
      if (v.isImage) {
        allImages.add(v);
        continue;
      }

      final sec = (v.sectionName?.isNotEmpty == true)
          ? v.sectionName!
          : 'General Information';

      if (currentSection != sec) {
        flushTable();
        if (currentSection != null) {
          formFields.add(const SizedBox(height: 20));
        }
        currentSection = sec;
        formFields.add(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(sec),
            const SizedBox(height: 12),
          ],
        ));
      }

      if (v.isInTable) {
        if (currentTableValues.isNotEmpty &&
            currentTableValues.last.tableContext != v.tableContext) {
          flushTable();
        }
        currentTableValues.add(v);
      } else {
        flushTable();
        formFields.add(_FieldCard(
          v: v,
          controller: _controllers[v.placeholderId]!,
          onChanged: () => setState(() => _hasChanges = true),
        ));
      }
    }
    flushTable();

    if (allImages.isNotEmpty) {
      formFields.add(const SizedBox(height: 20));
      formFields.add(const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader('Image Uploads'),
          SizedBox(height: 12),
        ],
      ));
      for (var v in allImages) {
        formFields.add(_ImageFieldCard(
          v: v,
          reportId: widget.reportId,
          uploadedName: _uploadedPaths[v.placeholderId],
          onUpload: () => _uploadImage(v),
        ));
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Column(
        children: [
          // Top action bar
          Container(
            color: AppTheme.cardBg,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => context.go('/reports/${widget.reportId}'),
                  child: const Text('← Back to Report'),
                ),
                const SizedBox(width: 16),
                ReferenceChip(
                    referenceNumber: r.referenceNumber, fontSize: 12),
                const Spacer(),
                if (_hasChanges || _saving)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(_saving ? 'Saving...' : 'Unsaved changes',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.warning)),
                  ),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_rounded, size: 16),
                  label: const Text('Save'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Form body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: formFields,
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Right side contextual help or mini map
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Instructions',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          const Text(
                            'Provide values for all placeholders mapped from the selected template.\n\n'
                            '• DATE fields expect yyyy-mm-dd format.\n'
                            '• Tables automatically fill repeating rows if supported.\n'
                            '• Save frequently to avoid data loss.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                height: 1.5),
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 20),
                          const Text('Progress',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          _ProgressCircle(report: r),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary));
  }
}

class _FieldCard extends StatelessWidget {
  final ReportValueModel v;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _FieldCard({
    required this.v,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _fieldTypeColor(v.fieldType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(v.fieldType,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _fieldTypeColor(v.fieldType))),
              ),
              const SizedBox(width: 8),
              Text(v.placeholderKey,
                  style: const TextStyle(
                      fontFamily: 'Courier New',
                      fontSize: 11,
                      color: AppTheme.accent)),
            ],
          ),
          const SizedBox(height: 10),
          Text(v.questionText,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              hintText: 'Enter ${v.displayLabel.toLowerCase()}...',
              hintStyle: const TextStyle(color: AppTheme.textSecondary),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            maxLines: v.fieldType == 'TEXT' ? 1 : 3,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Color _fieldTypeColor(String type) {
    switch (type) {
      case 'DATE':
        return AppTheme.warning;
      case 'IMAGE':
        return const Color(0xFF8B5CF6);
      case 'NUMBER':
        return AppTheme.success;
      default:
        return AppTheme.accent;
    }
  }
}

class _ImageFieldCard extends StatelessWidget {
  final ReportValueModel v;
  final int reportId;
  final String? uploadedName;
  final VoidCallback onUpload;

  const _ImageFieldCard({
    required this.v,
    required this.reportId,
    this.uploadedName,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = uploadedName != null || v.hasImageData;
    final imageUrl = hasImage ? ApiService().getBlobImageUrl(v.valueId ?? 0, v.placeholderKey) : null;
    
    // Fallback: If we just uploaded it but don't have a valueId yet, we might not have a URL easily.
    // However, in our system, saveReportValues creates the record if it doesn't exist.
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: hasImage ? AppTheme.success : AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: hasImage ? AppTheme.chipGreen : AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: hasImage ? AppTheme.success : AppTheme.border),
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      ApiService().getBlobImageUrl(reportId, v.placeholderKey),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.success,
                        size: 28,
                      ),
                    ),
                  )
                : Icon(
                    Icons.image_outlined,
                    color: AppTheme.textSecondary,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.questionText,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(v.placeholderKey,
                    style: const TextStyle(
                        fontFamily: 'Courier New',
                        fontSize: 11,
                        color: AppTheme.accent)),
                if (hasImage) ...[
                  const SizedBox(height: 4),
                  Text(uploadedName!,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.success)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            child: ElevatedButton(
              onPressed: onUpload,
              child: Text('📤 Select ${v.displayLabel} Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableFieldsView extends StatelessWidget {
  final List<ReportValueModel> values;
  final int reportId;
  final Map<int, TextEditingController> controllers;
  final Map<int, String> uploadedPaths;
  final Function(ReportValueModel) onUpload;
  final VoidCallback onChanged;

  const _TableFieldsView({
    required this.values,
    required this.reportId,
    required this.controllers,
    required this.uploadedPaths,
    required this.onUpload,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Group by table context
    final Map<String, List<ReportValueModel>> byTable = {};
    for (final v in values) {
      final key = v.tableContext ?? 'unknown';
      byTable.putIfAbsent(key, () => []).add(v);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(40),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(2),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(color: AppTheme.surface),
            children: ['#', 'Field', 'Value']
                .map((h) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Text(h,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary))))
                .toList(),
          ),
          ...values.asMap().entries.map((entry) {
            final i = entry.key;
            final v = entry.value;
            return TableRow(
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppTheme.border))),
              children: [
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary))),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.displayLabel,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                      if (v.col1Header != null || v.col2Header != null)
                        Text('${v.col1Header ?? ''} | ${v.col2Header ?? ''}',
                            style: const TextStyle(
                                fontSize: 10, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: v.isImage
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             if (uploadedPaths[v.placeholderId] != null || v.hasImageData)
                               Expanded(
                                 child: Row(
                                   children: [
                                     ClipRRect(
                                       borderRadius: BorderRadius.circular(4),
                                       child: Image.network(
                                         ApiService().getBlobImageUrl(reportId, v.placeholderKey),
                                         width: 24,
                                         height: 24,
                                         fit: BoxFit.cover,
                                         errorBuilder: (context, error, stackTrace) => 
                                           const Icon(Icons.check_circle, color: AppTheme.success, size: 16),
                                       ),
                                     ),
                                     const SizedBox(width: 4),
                                     Expanded(
                                       child: Text(
                                         uploadedPaths[v.placeholderId] ?? 'Image uploaded',
                                         style: const TextStyle(fontSize: 10, color: AppTheme.success),
                                         overflow: TextOverflow.ellipsis,
                                       ),
                                     ),
                                   ],
                                 ),
                               )
                            else
                               const Expanded(
                                 child: Text(
                                   'No image',
                                   style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                   overflow: TextOverflow.ellipsis,
                                 ),
                               ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => onUpload(v),
                              icon: const Icon(Icons.upload_rounded, size: 14),
                              label: const Text('Upload', style: TextStyle(fontSize: 11)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        )
                      : TextFormField(
                          controller: controllers[v.placeholderId],
                          onChanged: (_) => onChanged(),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ProgressCircle extends StatelessWidget {
  final ReportDetailModel report;

  const _ProgressCircle({required this.report});

  @override
  Widget build(BuildContext context) {
    final filled = report.values.where((v) => v.hasValue).length;
    final total = report.values.length;
    final pct = total == 0 ? 0.0 : filled / total;

    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: pct,
                  backgroundColor: AppTheme.border,
                  color: pct == 1.0 ? AppTheme.success : AppTheme.accent,
                  strokeWidth: 8,
                ),
                Center(
                    child: Text('${(pct * 100).toInt()}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('$filled of $total filled',
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
