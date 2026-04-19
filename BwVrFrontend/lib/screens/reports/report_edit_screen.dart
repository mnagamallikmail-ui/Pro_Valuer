import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../models/report_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
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
  final Map<int, String> _uploadedPaths = {};
  final Map<int, Uint8List> _previewBytes = {};
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
      if (mounted) {
        setState(() {
          _report = r;
          _isLoading = false;
          _initControllers(r);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _initControllers(ReportDetailModel r) {
    for (var v in r.values) {
      if (!v.isUserVisible) continue;
      _controllers[v.placeholderId] = TextEditingController(text: v.textValue ?? '');
      if (v.isImage && (v.imageFilePath != null || v.hasImageData)) {
        _uploadedPaths[v.placeholderId] = v.imageOriginalName ?? 'Image Uploaded';
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
        if (!v.isUserVisible) continue;
        if (!v.isImage) {
          final text = _controllers[v.placeholderId]?.text ?? '';
          if (text != (v.textValue ?? '')) {
            updateValues.add({
              'placeholderId': v.placeholderId,
              'placeholderKey': v.hiddenInternalKey,
              'textValue': text,
            });
          }
        }
      }
      
      if (updateValues.isNotEmpty) {
        await _apiService.saveReportValues(widget.reportId, updateValues);
      }

      if (mounted) {
        setState(() {
          _hasChanges = false;
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report saved successfully'), backgroundColor: AppColors.textPrimary),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _uploadImage(ReportValueModel v) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;
      
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return;
      
      // Immediate UI Feedback: show preview locally before/during upload
      if (mounted) {
        setState(() {
          _previewBytes[v.placeholderId] = bytes;
          _hasChanges = true; 
        });
      }

      final uploadResult = await _apiService.uploadImage(
        fileBytes: bytes,
        fileName: file.name,
        reportId: widget.reportId,
        placeholderKey: v.hiddenInternalKey,
      );
        
      final filePath = uploadResult['filePath'] ?? uploadResult['imageUrl'];
      final originalName = uploadResult['originalName'] ?? file.name;

      await _apiService.saveReportValues(widget.reportId, [
        {
          'placeholderId': v.placeholderId,
          'placeholderKey': v.hiddenInternalKey,
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
          const SnackBar(content: Text('Image uploaded!'), backgroundColor: AppColors.textPrimary),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.textPrimary)));
    if (_error != null) return Scaffold(body: Center(child: Text('Error: $_error', style: AppTypography.bodyMedium)));

    final r = _report!;
    final List<Widget> sections = _buildSections();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.go('/reports/${widget.reportId}'),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Back'),
                ),
                const SizedBox(width: 24),
                ReferenceChip(label: r.referenceNumber),
                const Spacer(),
                if (_hasChanges)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text('Unsaved changes', style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
                  ),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary)) : const Icon(Icons.check_rounded, size: 18),
                  label: Text(_saving ? 'Saving...' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(children: sections),
                  ),
                  const SizedBox(width: 32),
                  // Sidebar
                  SizedBox(
                    width: 300,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Instructions', style: AppTypography.subheading),
                          const SizedBox(height: 16),
                          Text(
                            'Enter values for all placeholders. Dates should be in yyyy-mm-dd format. Images will be automatically optimized for the document.',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 32),
                          _ProgressCard(report: r),
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

  List<Widget> _buildSections() {
    final List<Widget> widgets = [];
    final Map<String, List<ReportValueModel>> sectionsMap = {};

    // Group fields by section, keeping order
    for (var v in _report!.values) {
      if (!v.isUserVisible) continue;
      final sec = (v.sectionName?.isNotEmpty == true) ? v.sectionName! : 'General Information';
      sectionsMap.putIfAbsent(sec, () => []).add(v);
    }

    sectionsMap.forEach((name, values) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 24, top: 12),
        child: Text(name.toUpperCase(), style: AppTypography.label.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ));
      
      for (var v in values) {
        if (v.isImage) {
          widgets.add(_ImageFieldCard(
            v: v,
            reportId: widget.reportId,
            uploadedName: _uploadedPaths[v.placeholderId] ?? v.imageOriginalName,
            previewBytes: _previewBytes[v.placeholderId],
            onUpload: () => _uploadImage(v),
          ));
        } else {
          widgets.add(_FieldCard(
            v: v,
            controller: _controllers[v.placeholderId]!,
            onChanged: () => setState(() => _hasChanges = true),
          ));
        }
      }
      widgets.add(const SizedBox(height: 24));
    });

    return widgets;
  }
}

class _FieldCard extends StatelessWidget {
  final ReportValueModel v;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _FieldCard({required this.v, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(v.questionText, style: AppTypography.subheading),
          const SizedBox(height: 20),
          TextFormField(
            controller: controller,
            onChanged: (val) => onChanged(),
            decoration: InputDecoration(
              hintText: 'Enter value...',
              fillColor: AppColors.background,
              filled: true,
            ),
            maxLines: v.inputType == 'TEXT' ? 1 : 4,
          ),
        ],
      ),
    );
  }
}

class _ImageFieldCard extends StatelessWidget {
  final ReportValueModel v;
  final int reportId;
  final String? uploadedName;
  final Uint8List? previewBytes;
  final VoidCallback onUpload;

  const _ImageFieldCard({required this.v, required this.reportId, this.uploadedName, this.previewBytes, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final hasImage = uploadedName != null || v.hasImageData;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (hasImage || previewBytes != null) ? AppColors.secondary : AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onUpload,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: (previewBytes != null)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(previewBytes!, fit: BoxFit.cover),
                        )
                      : hasImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                ApiService().getBlobImageUrl(reportId, v.hiddenInternalKey),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 32),
                              ),
                            )
                          : const Icon(Icons.image_outlined, color: AppColors.textSecondary, size: 32),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.sectionName ?? 'Asset Category', style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(v.questionText, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                        (previewBytes != null || hasImage) 
                          ? (uploadedName ?? v.imageOriginalName ?? 'Image Attached') 
                          : 'Click to upload valuation photo',
                        style: AppTypography.label.copyWith(
                          color: (hasImage || previewBytes != null) ? AppColors.secondary : AppColors.textSecondary,
                          fontWeight: (hasImage || previewBytes != null) ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  (hasImage || previewBytes != null) ? Icons.check_circle_rounded : Icons.add_a_photo_outlined,
                  color: (hasImage || previewBytes != null) ? AppColors.secondary : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final ReportDetailModel report;
  const _ProgressCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final visibleValues = report.values.where((v) => v.isUserVisible).toList();
    final filled = visibleValues.where((v) => v.hasValue).length;
    final total = visibleValues.length;
    final pct = total == 0 ? 0.0 : filled / total;

    return Column(
      children: [
        SizedBox(
          width: 100, height: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: pct,
                backgroundColor: AppColors.background,
                color: pct == 1.0 ? AppColors.secondary : AppColors.primary,
                strokeWidth: 10,
              ),
              Center(child: Text('${(pct * 100).toInt()}%', style: AppTypography.heading3)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('$filled of $total complete', style: AppTypography.label),
      ],
    );
  }
}
