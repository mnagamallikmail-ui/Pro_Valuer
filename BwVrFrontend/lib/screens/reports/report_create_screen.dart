import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../models/template_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_layout.dart';

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

  @override
  void initState() {
    super.initState();
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
    try {
      final templates = await _api.getTemplateList();
      setState(() {
        _templates = templates.where((t) => t.isParsed).toList();
        _loadingTemplates = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingTemplates = false;
      });
    }
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTemplate == null) {
      setState(() => _error = 'Please select a template');
      return;
    }

    setState(() {
      _creating = true;
      _error = null;
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
      context.go('/reports/${report.reportId}/edit');
    } catch (e) {
      setState(() {
        _creating = false;
        _error = e.toString();
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
                                  ? Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppTheme.chipAmber,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppTheme.warning
                                                .withOpacity(0.4)),
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
                                                      'No templates available.',
                                                      style:
                                                          TextStyle(fontSize: 13))),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          TextButton(
                                            onPressed: () =>
                                                context.go('/templates/upload'),
                                            child: const Text('Upload Now →'),
                                          ),
                                        ],
                                      ),
                                    )
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
                                      onChanged: (v) =>
                                          setState(() => _selectedTemplate = v),
                                      validator: (v) => v == null
                                          ? 'Please select a template'
                                          : null,
                                    ),
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Report Title *',
                              hintText: 'e.g. Audit Q1 2024',
                              prefixIcon: Icon(Icons.title_rounded, size: 18),
                            ),
                            validator: (v) =>
                                (v?.isEmpty ?? true) ? 'Required' : null,
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

                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.chipRed,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppTheme.danger.withOpacity(0.3)),
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
                              onPressed: (_creating || _templates.isEmpty)
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

  Widget _buildVendorField() => TextFormField(
        controller: _vendorController,
        decoration: const InputDecoration(
          labelText: 'Vendor Name',
          hintText: 'e.g. Acme Corp',
          prefixIcon: Icon(Icons.business_rounded, size: 18),
        ),
      );

  Widget _buildLocationField() => TextFormField(
        controller: _locationController,
        decoration: const InputDecoration(
          labelText: 'Location / Branch',
          hintText: 'e.g. Mumbai',
          prefixIcon: Icon(Icons.location_on_rounded, size: 18),
        ),
      );
}
