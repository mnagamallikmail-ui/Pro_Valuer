import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../services/api_service.dart';
import '../../models/template_model.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_layout.dart';

class TemplateReviseScreen extends StatefulWidget {
  final int oldTemplateId;
  const TemplateReviseScreen({super.key, required this.oldTemplateId});

  @override
  State<TemplateReviseScreen> createState() => _TemplateReviseScreenState();
}

class _TemplateReviseScreenState extends State<TemplateReviseScreen> {
  final _api = ApiService();
  
  TemplateModel? _oldTemplate;
  List<PlaceholderModel> _oldPlaceholders = [];
  List<PlaceholderModel> _newPlaceholders = [];
  int? _newTemplateId;
  
  bool _loading = true;
  String? _error;
  
  PlatformFile? _selectedFile;
  bool _uploading = false;
  int _step = 0; // 0=idle, 1=uploading/parsing, 2=diffing, 3=done

  @override
  void initState() {
    super.initState();
    _loadOldTemplate();
  }

  Future<void> _loadOldTemplate() async {
    try {
      final t = await _api.getTemplate(widget.oldTemplateId);
      final phs = await _api.getPlaceholders(widget.oldTemplateId);
      setState(() {
        _oldTemplate = t;
        _oldPlaceholders = phs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
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

  Future<void> _uploadAndDiff() async {
    if (_selectedFile == null) return;

    setState(() {
      _uploading = true;
      _error = null;
      _step = 1;
    });

    try {
      final response = await _api.uploadTemplate(
        fileBytes: _selectedFile!.bytes!,
        fileName: _selectedFile!.name,
        bankName: _oldTemplate!.bankName,
        templateName: _oldTemplate!.templateName, // keep the same name
      );

      _newTemplateId = response.templateId;
      
      setState(() => _step = 2);
      
      final newPhs = await _api.getPlaceholders(_newTemplateId!);
      
      // Auto-copy labels and question texts from old placeholders to new placeholders
      for (var newPh in newPhs) {
        try {
          final oldPh = _oldPlaceholders.firstWhere((p) => p.placeholderKey == newPh.placeholderKey);
          newPh.displayLabel = oldPh.displayLabel;
          newPh.questionText = oldPh.questionText;
          newPh.fieldType = oldPh.fieldType;
        } catch (_) {
          // New placeholder, no old equivalent found
        }
      }

      setState(() {
        _newPlaceholders = newPhs;
        _step = 3;
        _uploading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Upload failed: $e';
        _uploading = false;
        _step = 0;
      });
    }
  }

  Future<void> _confirmChanges() async {
    if (_newTemplateId == null) return;
    
    setState(() => _uploading = true);
    
    try {
      // 1. Confirm new placeholders
      final updates = _newPlaceholders
          .map((p) => {
                'placeholderId': p.placeholderId,
                'questionText': p.questionText,
                'displayLabel': p.displayLabel,
                'fieldType': p.fieldType,
                'isRequired': p.isRequired == 'Y',
              })
          .toList();

      await _api.confirmPlaceholders(_newTemplateId!, updates);
      
      // 2. Archive old template
      await _api.archiveTemplate(widget.oldTemplateId);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Template successfully revised!'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating));
      context.go('/templates');
    } catch (e) {
      setState(() => _uploading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/templates',
      child: _loading 
        ? const Center(child: CircularProgressIndicator())
        : _error != null && _oldTemplate == null
          ? Center(child: Text('Error: $_error'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
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
                          const Text(' / Revise'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Text('Revise Template', style: AppTypography.heading2),
                      Text('Upload a newer version of the .docx file to replace the current template.', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 24),

                      // Read-only Details
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.structural,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_oldTemplate!.bankName, style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
                                  Text(_oldTemplate!.templateName, style: AppTypography.subheading),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_step < 3) ...[
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
                                        : 'Drop new .docx file here or click to browse',
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
                                  if (_selectedFile != null && !_uploading) ...[
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: _pickFile,
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
                          Text(_error!, style: const TextStyle(color: AppTheme.danger)),
                        ],

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: (_uploading || _selectedFile == null) ? null : _uploadAndDiff,
                            icon: _uploading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.compare_arrows_rounded, size: 18),
                            label: Text(_uploading ? 'Processing...' : 'Upload & Compare'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ] else ...[
                        // Diff View
                        _buildDiffView(),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _uploading ? null : () => setState(() { _step = 0; _selectedFile = null; _newTemplateId = null; }),
                              child: const Text('Cancel & Re-upload'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _uploading ? null : _confirmChanges,
                              icon: _uploading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.check_rounded, size: 18),
                              label: const Text('Confirm Changes'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                backgroundColor: AppTheme.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDiffView() {
    final oldKeys = _oldPlaceholders.map((p) => p.placeholderKey).toSet();
    final newKeys = _newPlaceholders.map((p) => p.placeholderKey).toSet();
    
    final addedKeys = newKeys.difference(oldKeys);
    final removedKeys = oldKeys.difference(newKeys);
    final unchangedKeys = newKeys.intersection(oldKeys);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.compare_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Text('Placeholder Changes', style: AppTypography.heading3),
              ],
            ),
          ),
          const Divider(height: 1),
          if (addedKeys.isEmpty && removedKeys.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppTheme.success, size: 48),
                    const SizedBox(height: 16),
                    Text('No structural changes detected.', style: AppTypography.subheading),
                    Text('The placeholders match exactly.', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Please review the detected placeholder changes before confirming. Removed placeholders will no longer be available for data entry.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
            
            // Removed Placeholders
            if (removedKeys.isNotEmpty) ...[
              Container(color: const Color(0xFFFEE2E2), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: const Text('REMOVED', style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold, fontSize: 12))),
              ...removedKeys.map((k) => ListTile(
                leading: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444)),
                title: Text(k, style: const TextStyle(fontFamily: 'Courier New', color: Color(0xFFEF4444), decoration: TextDecoration.lineThrough)),
                dense: true,
              )).toList(),
            ],
            
            // Added Placeholders
            if (addedKeys.isNotEmpty) ...[
              Container(color: const Color(0xFFDCFCE7), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: const Text('ADDED', style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.bold, fontSize: 12))),
              ...addedKeys.map((k) => ListTile(
                leading: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981)),
                title: Text(k, style: const TextStyle(fontFamily: 'Courier New', color: Color(0xFF10B981))),
                subtitle: const Text('Requires question setup after confirm', style: TextStyle(fontSize: 12)),
                dense: true,
              )).toList(),
            ],
            
            // Unchanged Summary
            if (unchangedKeys.isNotEmpty) ...[
              Container(color: AppColors.structural, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: const Text('UNCHANGED', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12))),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('${unchangedKeys.length} placeholders remain unchanged.', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ),
            ],
          ]
        ],
      ),
    );
  }
}
