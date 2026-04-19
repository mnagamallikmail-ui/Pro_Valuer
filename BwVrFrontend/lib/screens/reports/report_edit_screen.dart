import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 70,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final result = await _apiService.uploadImage(
        fileBytes: bytes,
        fileName: image.name,
        reportId: widget.reportId,
        placeholderKey: v.placeholderKey,
      );
        
      final filePath = result['filePath'] ?? result['imageUrl'];
      final originalName = result['originalName'] ?? image.name;

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

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 900;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Toolbar
            _buildToolbar(r, isMobile),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildInstructions(isMobile),
                              const SizedBox(height: 16),
                              _ProgressCard(report: r, isMobile: true),
                              const SizedBox(height: 24),
                              ...sections,
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: sections,
                                ),
                              ),
                              const SizedBox(width: 32),
                              // Sidebar (Desktop)
                              SizedBox(
                                width: 300,
                                child: Column(
                                  children: [
                                    _buildInstructions(false),
                                    const SizedBox(height: 24),
                                    _ProgressCard(report: r, isMobile: false),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildToolbar(ReportDetailModel r, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 32, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/reports/${widget.reportId}'),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
          ),
          if (!isMobile) ...[
            const SizedBox(width: 16),
            ReferenceChip(referenceNumber: r.referenceNumber),
          ],
          const Spacer(),
          if (_hasChanges && !isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text('Unsaved changes', style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
            ),
          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving 
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary)) 
                : const Icon(Icons.check_rounded, size: 18),
            label: Text(_saving ? 'Saving...' : (isMobile ? 'Save' : 'Save Changes')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(bool isMobile) {
    final title = Text('Instructions', style: AppTypography.subheading);
    final content = Text(
      'Enter values for all placeholders. Dates should be in yyyy-mm-dd format. Images will be automatically optimized for the document.',
      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
    );

    if (isMobile) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          title: title,
          initiallyExpanded: false,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: content,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  List<Widget> _buildSections() {
    final List<Widget> widgets = [];
    final Map<String, List<ReportValueModel>> sectionsMap = {};
    final List<ReportValueModel> allImages = [];

    for (var v in _report!.values) {
      if (v.isImage) {
        allImages.add(v);
        continue;
      }
      final sec = (v.sectionName?.isNotEmpty == true) ? v.sectionName! : 'General Information';
      sectionsMap.putIfAbsent(sec, () => []).add(v);
    }

    sectionsMap.forEach((name, values) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 24, top: 12),
        child: Text(name.toUpperCase(), style: AppTypography.label.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ));
      
      for (var v in values) {
        widgets.add(_FieldCard(
          v: v,
          controller: _controllers[v.placeholderId]!,
          onChanged: () => setState(() => _hasChanges = true),
        ));
      }
      widgets.add(const SizedBox(height: 24));
    });

    if (allImages.isNotEmpty) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 24, top: 12),
        child: Text('IMAGE UPLOADS', style: AppTypography.label.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ));
      for (var v in allImages) {
        widgets.add(_ImageFieldCard(
          v: v,
          reportId: widget.reportId,
          uploadedName: _uploadedPaths[v.placeholderId],
          onUpload: () => _uploadImage(v),
        ));
      }
    }

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
            decoration: const InputDecoration(
              hintText: 'Enter value...',
              fillColor: AppColors.background,
              filled: true,
            ),
            maxLines: v.fieldType == 'TEXT' ? 1 : 4,
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
  final VoidCallback onUpload;

  const _ImageFieldCard({required this.v, required this.reportId, this.uploadedName, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 500;
      final hasImage = uploadedName != null || v.hasImageData;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hasImage ? AppColors.secondary : AppColors.border),
        ),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImagePreview(hasImage),
                  const SizedBox(height: 20),
                  _buildInfo(),
                  const SizedBox(height: 24),
                  _buildActionButton(),
                ],
              )
            : Row(
                children: [
                  _buildImagePreview(hasImage),
                  const SizedBox(width: 24),
                  Expanded(child: _buildInfo()),
                  const SizedBox(width: 24),
                  _buildActionButton(),
                ],
              ),
      );
    });
  }

  Widget _buildImagePreview(bool hasImage) {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                ApiService().getBlobImageUrl(reportId, v.placeholderKey),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 32),
              ),
            )
          : const Icon(Icons.image_outlined, color: AppColors.textSecondary, size: 32),
    );
  }

  Widget _buildInfo() {
    final hasImage = uploadedName != null || v.hasImageData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(v.questionText, style: AppTypography.subheading),
        if (hasImage) ...[
          const SizedBox(height: 8),
          Text(uploadedName ?? 'Image Uploaded', style: AppTypography.label.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: onUpload,
      icon: const Icon(Icons.upload_rounded, size: 18),
      label: const Text('Choose Image'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final ReportDetailModel report;
  final bool isMobile;
  const _ProgressCard({required this.report, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final filled = report.values.where((v) => v.hasValue).length;
    final total = report.values.length;
    final pct = total == 0 ? 0.0 : filled / total;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: isMobile
          ? Row(
              children: [
                _buildCircularProgress(pct),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Progress', style: AppTypography.subheading),
                      const SizedBox(height: 4),
                      Text('$filled of $total fields complete', style: AppTypography.label),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _buildCircularProgress(pct),
                const SizedBox(height: 20),
                Text('$filled of $total complete', style: AppTypography.label),
              ],
            ),
    );
  }

  Widget _buildCircularProgress(double pct) {
    return SizedBox(
      width: 70, height: 70,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: pct,
            backgroundColor: AppColors.background,
            color: pct == 1.0 ? AppColors.secondary : AppColors.primary,
            strokeWidth: 8,
          ),
          Center(child: Text('${(pct * 100).toInt()}%', style: AppTypography.label.copyWith(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
