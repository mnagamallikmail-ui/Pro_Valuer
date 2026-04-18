import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../models/template_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/common_widgets.dart';

class TemplateListScreen extends StatefulWidget {
  const TemplateListScreen({super.key});

  @override
  State<TemplateListScreen> createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends State<TemplateListScreen> {
  final _api = ApiService();
  final _notifications = NotificationService();
  List<TemplateModel> _templates = [];
  List<String> _banks = [];
  String? _selectedBank;
  bool _loading = true;
  String? _error;
  StreamSubscription? _changeSubscription;

  @override
  void initState() {
    super.initState();
    _load();
    _changeSubscription = _notifications.changeStream.listen((_) {
      _load(silent: true);
    });
  }

  @override
  void dispose() {
    _changeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final templates = await _api.getTemplateList(bankName: _selectedBank);
      final banks = await _api.getBankNames();
      if (!mounted) return;
      setState(() {
        _templates = templates;
        _banks = banks;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteTemplate(TemplateModel t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteDialog(templateName: t.templateName, bankName: t.bankName),
    );
    if (confirmed == true) {
      try {
        await _api.deleteTemplate(t.templateId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blueprint deleted'), behavior: SnackBarBehavior.floating)
        );
        _load();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return AppLayout(
      currentRoute: '/templates',
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: isMobile 
                ? Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Filter Bank'),
                        value: _selectedBank,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Institutions')),
                          ..._banks.map((b) => DropdownMenuItem(value: b, child: Text(b))),
                        ],
                        onChanged: (v) {
                          setState(() => _selectedBank = v);
                          _load();
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/templates/upload').then((_) => _load()),
                          icon: const Icon(Icons.upload_rounded, size: 18),
                          label: const Text('Upload Docx'),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Institutional Filter',
                            prefixIcon: Icon(Icons.account_balance_rounded, size: 18),
                          ),
                          value: _selectedBank,
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Institutions')),
                            ..._banks.map((b) => DropdownMenuItem(value: b, child: Text(b))),
                          ],
                          onChanged: (v) {
                            setState(() => _selectedBank = v);
                            _load();
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/templates/upload').then((_) => _load()),
                        icon: const Icon(Icons.upload_rounded, size: 18),
                        label: const Text('Upload Blueprint'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        ),
                      ),
                    ],
                  ),
            ),
            const SizedBox(height: 32),

            // Results Heading
            Row(
              children: [
                Text('${_templates.length} Blueprints', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                const Icon(Icons.sync_rounded, size: 14, color: AppColors.success),
                const SizedBox(width: 8),
                Text('Real-time sync active', style: AppTypography.label.copyWith(color: AppColors.success)),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _error != null
                      ? Center(child: Text('Error: $_error', style: AppTypography.bodyMedium.copyWith(color: AppColors.error)))
                      : _templates.isEmpty
                          ? EmptyState(
                              icon: Icons.folder_copy_outlined,
                              title: 'No Blueprints',
                              subtitle: 'Upload a .docx template to get started',
                              action: ElevatedButton(
                                onPressed: () => context.push('/templates/upload').then((_) => _load()),
                                child: const Text('Upload Draft'),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border, width: 1),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(minWidth: 900),
                                    child: _TemplateTable(
                                      templates: _templates,
                                      onDelete: _deleteTemplate,
                                      onConfirm: (t) async {
                                        await context.push('/templates/${t.templateId}/confirm');
                                        _load();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateTable extends StatelessWidget {
  final List<TemplateModel> templates;
  final ValueChanged<TemplateModel> onDelete;
  final ValueChanged<TemplateModel> onConfirm;

  const _TemplateTable({
    required this.templates,
    required this.onDelete,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(2),
        2: FixedColumnWidth(80),
        3: FixedColumnWidth(120),
        4: FixedColumnWidth(140),
        5: FixedColumnWidth(100),
      },
      children: [
        // Header row
        TableRow(
          decoration: const BoxDecoration(color: AppColors.surface),
          children: [
            _th('INSTITUTION'),
            _th('BLUEPRINT NAME'),
            _th('FIELDS'),
            _th('PARSING'),
            _th('CREATED'),
            _th('ACTIONS'),
          ],
        ),
        // Data rows
        ...templates.map((t) => TableRow(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              children: [
                _td(Text(t.bankName, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600))),
                _td(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.templateName, style: AppTypography.bodyMedium),
                    Text(t.templateFileName, style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                )),
                _td(Text('${t.placeholderCount ?? 0}', style: AppTypography.bodyMedium)),
                _td(StatusChip(status: t.parsedStatus)),
                _td(Text(
                    t.createdAt != null ? DateFormat('dd MMM yyyy').format(t.createdAt!) : '—',
                    style: AppTypography.label.copyWith(fontSize: 11, color: AppColors.textSecondary))),
                _td(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!t.isConfirmed)
                      IconButton(
                        onPressed: () => onConfirm(t),
                        icon: const Icon(Icons.settings_suggest_rounded, color: AppColors.primary, size: 18),
                        tooltip: 'Configure',
                      ),
                    IconButton(
                      onPressed: () => onDelete(t),
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                      tooltip: 'Remove',
                    ),
                  ],
                )),
              ],
            )),
      ],
    );
  }

  Widget _th(String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Text(label, style: AppTypography.label.copyWith(fontSize: 10, letterSpacing: 1)),
  );

  Widget _td(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: child,
  );
}

class _DeleteDialog extends StatelessWidget {
  final String templateName;
  final String bankName;
  const _DeleteDialog({required this.templateName, required this.bankName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
              'This will permanently remove the template and all its parsed data.'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.chipRed,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(templateName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(bankName,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
