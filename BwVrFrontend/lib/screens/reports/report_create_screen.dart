import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../models/template_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_layout.dart';
import '../../services/auth_service.dart';

class ReportCreateScreen extends StatefulWidget {
  const ReportCreateScreen({super.key});

  @override
  State<ReportCreateScreen> createState() => _ReportCreateScreenState();
}

class _ReportCreateScreenState extends State<ReportCreateScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _vendorController = TextEditingController();
  final _locationController = TextEditingController();

  List<TemplateModel> _templates = [];
  TemplateModel? _selectedTemplate;
  bool _loadingTemplates = true;
  bool _creating = false;
  String? _error;
  bool _isConfigError = false; // True when error is a DB/config issue, not user error

  @override
  void initState() {
    super.initState();;
    _loadTemplates();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _vendorController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _loadingTemplates = true;
      _error = null;
    });
    try {
      final templates = await _api.getTemplateList();
      if (!mounted) return;
      setState(() {
        _templates = templates.where((t) => t.isParsed).toList();
        _loadingTemplates = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load templates: ${_cleanError(e.toString())}';
        _loadingTemplates = false;
      });
    }
  }

  /// Strips the 'Exception: ' prefix that Dart adds to exception strings.
  String _cleanError(String raw) {
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }
    return raw;
  }

  bool _isDbConfigError(String message) {
    return message.contains('report_ref_seq') ||
        message.contains('sequence') ||
        message.contains('configuration issue') ||
        message.contains('REPORT_CREATION_ERROR');
  }

  Future<void> _create() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTemplate == null) {
      setState(() {
        _error = 'Please select a template to continue.';
        _isConfigError = false;
      });
      return;
    }

    setState(() {
      _creating = true;
      _error = null;
      _isConfigError = false;
    });

    try {
      final report = await _api.createReport(
        templateId: _selectedTemplate!.templateId,
        reportTitle: _titleController.text.trim(),
        vendorName: _vendorController.text.trim().isNotEmpty
            ? _vendorController.text.trim()
            : null,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
      );

      if (!mounted) return;
      // Navigate to the edit screen on success
      context.go('/reports/${report.reportId}/edit');
    } catch (e) {
      if (!mounted) return;
      final cleaned = _cleanError(e.toString());
      setState(() {
        _creating = false;
        _error = cleaned;
        _isConfigError = _isDbConfigError(cleaned);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/reports/new',
      title: 'Create New Report',
      child: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final padding = isMobile ? 16.0 : 32.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => context.go('/reports'),
                        child: const Text('← Reports'),
                      ),
                      const Text(' / New Report'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                          const Text('Report Details',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          const Text(
                              'A unique reference number will be auto-generated for this report.',
                              style: TextStyle(
                                  fontSize: 13, color: AppTheme.textSecondary)),
                          const SizedBox(height: 24),

                          // Template selector
                          const Text('Template *',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          _loadingTemplates
                              ? const LinearProgressIndicator()
                              : _templates.isEmpty
                                  ? _buildNoTemplatesWarning(context)
                                  : DropdownButtonFormField<TemplateModel>(
                                      isExpanded: true,
                                      value: _selectedTemplate,
                                      decoration: const InputDecoration(
                                        hintText: 'Select a template...',
                                        prefixIcon: Icon(
                                            Icons.folder_copy_rounded,
                                            size: 18),
                                      ),
                                      items: _templates
                                          .map((t) => DropdownMenuItem(
                                                value: t,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(t.templateName,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500),
                                                        overflow: TextOverflow.ellipsis),
                                                    Text(
                                                        '${t.bankName} • ${t.placeholderCount ?? 0} fields',
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            color: AppTheme
                                                                .textSecondary),
                                                        overflow: TextOverflow.ellipsis),
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: _creating
                                          ? null
                                          : (v) => setState(() => _selectedTemplate = v),
                                      validator: (v) => v == null
                                          ? 'Please select a template'
                                          : null,
                                    ),
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _titleController,
                            enabled: !_creating,
                            decoration: const InputDecoration(
                              labelText: 'Report Title *',
                              hintText: 'e.g. Audit Q1 2024',
                              prefixIcon: Icon(Icons.title_rounded, size: 18),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Report title is required' : null,
                          ),
                          const SizedBox(height: 16),

                          if (!isMobile)
                            Row(
                              children: [
                                Expanded(child: _buildVendorField()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildLocationField()),
                              ],
                            )
                          else ...[
                            _buildVendorField(),
                            const SizedBox(height: 16),
                            _buildLocationField(),
                          ],

                          // Error display — shows backend message + config error hint
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            _buildErrorBanner(),
                          ],

                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: (_creating || _loadingTemplates || _templates.isEmpty)
                                  ? null
                                  : _create,
                              icon: _creating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.arrow_forward_rounded,
                                      size: 18),
                              label: Text(_creating
                                  ? 'Creating...'
                                  : 'Create & Fill Data →'),
                              style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16)),
                            ),
                          ),

                          // Retry button shown when request failed
                          if (_error != null && !_creating) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _create,
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text('Retry'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorBanner() {
    // Config errors get a different look — orange/amber to signal admin attention
    final isConfig = _isConfigError;
    final bgColor = isConfig ? AppTheme.chipAmber : AppTheme.chipRed;
    final borderColor = isConfig
        ? AppTheme.warning.withOpacity(0.5)
        : AppTheme.danger.withOpacity(0.3);
    final iconColor = isConfig ? AppTheme.warning : AppTheme.danger;
    final icon = isConfig ? Icons.settings_outlined : Icons.error_outline;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _error!,
                  style: TextStyle(color: iconColor, fontSize: 13),
                ),
              ),
            ],
          ),
          if (isConfig) ...[
            const SizedBox(height: 6),
            Text(
              'This is a server configuration issue. Please contact your administrator.',
              style: TextStyle(
                  color: iconColor.withOpacity(0.8),
                  fontSize: 11,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoTemplatesWarning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.chipAmber,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.warning.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppTheme.warning, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                  child: Text(
                      'No templates available. An admin needs to upload a template first.',
                      style: TextStyle(fontSize: 13))),
            ],
          ),
          if (AuthService().session?.isAdmin ?? false) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => context.go('/templates/upload'),
              icon: const Icon(Icons.upload_rounded, size: 16),
              label: const Text('Upload Template Now →'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVendorField() => TextFormField(
        controller: _vendorController,
        enabled: !_creating,
        decoration: const InputDecoration(
          labelText: 'Vendor Name',
          hintText: 'e.g. Acme Corp',
          prefixIcon: Icon(Icons.business_rounded, size: 18),
        ),
      );

  Widget _buildLocationField() => TextFormField(
        controller: _locationController,
        enabled: !_creating,
        decoration: const InputDecoration(
          labelText: 'Location / Branch',
          hintText: 'e.g. Mumbai',
          prefixIcon: Icon(Icons.location_on_rounded, size: 18),
        ),
      );
}
