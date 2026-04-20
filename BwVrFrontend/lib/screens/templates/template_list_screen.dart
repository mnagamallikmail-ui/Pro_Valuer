import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../models/template_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/common_widgets.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import 'package:intl/intl.dart';

class TemplateListScreen extends StatefulWidget {
  const TemplateListScreen({super.key});

  @override
  State<TemplateListScreen> createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends State<TemplateListScreen> {
  final _api = ApiService();
  List<TemplateModel> _templates = [];
  List<String> _banks = [];
  String? _selectedBank;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final templates = await _api.getTemplateList(bankName: _selectedBank);
      final banks = await _api.getBankNames();
      setState(() {
        _templates = templates;
        _banks = banks;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteTemplate(TemplateModel t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _DeleteDialog(templateName: t.templateName, bankName: t.bankName),
    );
    if (confirmed == true) {
      try {
        await _api.deleteTemplate(t.templateId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Template deleted'),
            behavior: SnackBarBehavior.floating));
        _load();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/templates',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbar
            Row(
              children: [
                Expanded(
                  child: _banks.isEmpty
                      ? const SizedBox.shrink()
                      : DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Filter by Bank',
                            prefixIcon:
                                Icon(Icons.account_balance_rounded, size: 18),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          value: _selectedBank,
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('All Banks')),
                            ..._banks.map((b) =>
                                DropdownMenuItem(value: b, child: Text(b))),
                          ],
                          onChanged: (v) {
                            setState(() => _selectedBank = v);
                            _load();
                          },
                        ),
                ),
                const SizedBox(width: 16),
                if (AuthService().session?.isAdmin ?? false)
                  ElevatedButton.icon(
                    onPressed: () async {
                      await context.push('/templates/upload');
                      _load();
                    },
                    icon: const Icon(Icons.upload_rounded, size: 16),
                    label: const Text('Upload Template'),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : _templates.isEmpty
                          ? EmptyState(
                              icon: Icons.folder_copy_outlined,
                              title: 'No templates found',
                              subtitle:
                                  'Upload a .docx template to get started',
                                  action: (AuthService().session?.isAdmin ?? false)
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            await context.push('/templates/upload');
                                            _load();
                                          },
                                          child: const Text('Upload Template'),
                                        )
                                      : null,
                                )
                          : Container(
                              decoration: BoxDecoration(
                                color: AppTheme.cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: SingleChildScrollView(
                                child: _TemplateTable(
                                  templates: _templates,
                                  onDelete: _deleteTemplate,
                                  onConfirm: (t) async {
                                    await context.push(
                                        '/templates/${t.templateId}/confirm');
                                    _load();
                                  },
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
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2.5),
        2: FixedColumnWidth(100),
        3: FixedColumnWidth(120),
        4: FixedColumnWidth(150),
        5: FixedColumnWidth(120),
      },
      children: [
        // Header row
        TableRow(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          children: [
            'Bank',
            'Template Name',
            'Fields',
            'Status',
            'Created',
            'Actions'
          ]
              .map((h) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Text(h,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary)),
                  ))
              .toList(),
        ),
        // Data rows
        ...templates.map((t) => TableRow(
              decoration: BoxDecoration(
                border: const Border(top: BorderSide(color: AppTheme.border)),
              ),
              children: [
                _cell(Text(t.bankName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500))),
                _cell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.templateName,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                    Text(t.templateFileName,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                )),
                _cell(Text('${t.placeholderCount ?? 0}',
                    style: const TextStyle(fontSize: 13))),
                _cell(StatusChip(status: t.parsedStatus)),
                _cell(Text(
                    t.createdAt != null
                        ? DateFormat('dd MMM yyyy').format(t.createdAt!)
                        : '—',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary))),
                _cell(Row(
                  children: [
                    if (AuthService().session?.isAdmin ?? false) ...[
                      if (!t.isConfirmed)
                        IconButton(
                          onPressed: () => onConfirm(t),
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          tooltip: 'Confirm Placeholders',
                          color: AppTheme.success,
                          iconSize: 18,
                        ),
                      IconButton(
                        onPressed: () => onDelete(t),
                        icon: const Icon(Icons.delete_outline_rounded),
                        tooltip: 'Delete',
                        color: AppTheme.danger,
                        iconSize: 18,
                      ),
                    ] else
                      Text('View Only', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                )),
              ],
            )),
      ],
    );
  }

  Widget _cell(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      title: const Text('Delete Template?'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
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
