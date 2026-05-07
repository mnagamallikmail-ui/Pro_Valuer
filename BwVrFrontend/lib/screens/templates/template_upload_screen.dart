import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_layout.dart';

class TemplateUploadScreen extends StatefulWidget {
  const TemplateUploadScreen({super.key});

  @override
  State<TemplateUploadScreen> createState() => _TemplateUploadScreenState();
}

class _TemplateUploadScreenState extends State<TemplateUploadScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _bankController = TextEditingController();
  final _nameController = TextEditingController();

  PlatformFile? _selectedFile;
  bool _uploading = false;
  String? _error;
  int _step = 0; // 0=idle, 1=uploading, 2=parsing, 3=done

  static const _steps = ['Uploading', 'Parsing', 'Detecting Placeholders'];

  @override
  void dispose() {
    _bankController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
      withData: true,
    );
    if (result != null) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      setState(() => _error = 'Please select a .docx file');
      return;
    }

    setState(() {
      _uploading = true;
      _error = null;
      _step = 1;
    });

    try {
      // Simulate step progression
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _step = 2);

      final response = await _api.uploadTemplate(
        fileBytes: _selectedFile!.bytes!,
        fileName: _selectedFile!.name,
        bankName: _bankController.text.trim(),
        templateName: _nameController.text.trim(),
      );

      setState(() => _step = 3);
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      context.go('/templates/${response.templateId}/confirm');
    } catch (e) {
      setState(() {
        _error = 'Upload failed: $e';
        _uploading = false;
        _step = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/templates/upload',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumb
                Row(
                  children: [
                    TextButton(
                      onPressed: () => context.go('/templates'),
                      child: const Text('← Templates'),
                    ),
                    const Text(' / Upload'),
                  ],
                ),
                const SizedBox(height: 16),

                // Upload progress indicator
                if (_uploading) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        const Text('Processing Template...',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 20),
                        Row(
                          children: _steps.asMap().entries.map((entry) {
                            final i = entry.key + 1;
                            final done = _step > i;
                            final active = _step == i;
                            return Expanded(
                                child: Row(
                              children: [
                                Column(children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: done
                                          ? AppTheme.success
                                          : active
                                              ? AppTheme.accent
                                              : AppTheme.border,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      done ? Icons.check_rounded : Icons.circle,
                                      color: done || active
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(entry.value,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: active
                                            ? AppTheme.accent
                                            : AppTheme.textSecondary,
                                        fontWeight: active
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      )),
                                ]),
                                if (i < _steps.length)
                                  Expanded(
                                      child: Container(
                                          height: 2,
                                          color: done
                                              ? AppTheme.success
                                              : AppTheme.border)),
                              ],
                            ));
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Template Details',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _bankController,
                          decoration: const InputDecoration(
                            labelText: 'Bank Name *',
                            hintText: 'e.g. HDFC Bank, SBI',
                            prefixIcon:
                                Icon(Icons.account_balance_rounded, size: 18),
                          ),
                          validator: (v) =>
                              (v?.isEmpty ?? true) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Template Name *',
                            hintText: 'e.g. Annual Audit Report 2024',
                            prefixIcon: Icon(Icons.label_rounded, size: 18),
                          ),
                          validator: (v) =>
                              (v?.isEmpty ?? true) ? 'Required' : null,
                        ),
                        const SizedBox(height: 24),

                        // File drop zone
                        GestureDetector(
                          onTap: _uploading ? null : _pickFile,
                          child: DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              color: _selectedFile != null
                                  ? AppTheme.success
                                  : AppTheme.accent,
                              strokeWidth: 2,
                              dashPattern: const [8, 4],
                              radius: const Radius.circular(12),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: _selectedFile != null ? 24 : 40,
                                  horizontal: 24),
                              child: Column(
                                children: [
                                  Icon(
                                    _selectedFile != null
                                        ? Icons.check_circle_rounded
                                        : Icons.upload_file_rounded,
                                    size: _selectedFile != null ? 36 : 48,
                                    color: _selectedFile != null
                                        ? AppTheme.success
                                        : AppTheme.accent,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _selectedFile != null
                                        ? _selectedFile!.name
                                        : 'Drop a .docx file here or click to browse',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: _selectedFile != null
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: _selectedFile != null
                                          ? AppTheme.success
                                          : AppTheme.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (_selectedFile != null) ...[
                                    const SizedBox(height: 4),
                                    Builder(
                                      builder: (context) {
                                        try {
                                          final num size =
                                              _selectedFile?.size ?? 0;
                                          final sizeKb = size / 1024;
                                          return Text(
                                            '${sizeKb.toStringAsFixed(1)} KB',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.textSecondary),
                                          );
                                        } catch (_) {
                                          return const SizedBox();
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: _uploading ? null : _pickFile,
                                      child: const Text('Change file'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.chipRed,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppTheme.danger.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: AppTheme.danger, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(_error!,
                                        style: const TextStyle(
                                            color: AppTheme.danger,
                                            fontSize: 13))),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _uploading ? null : _upload,
                            icon: _uploading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.upload_rounded, size: 18),
                            label: Text(_uploading
                                ? 'Processing...'
                                : 'Upload & Parse Template'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
