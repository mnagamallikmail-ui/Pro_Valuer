import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../models/template_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/common_widgets.dart';

class TemplateConfirmScreen extends StatefulWidget {
  final int templateId;
  const TemplateConfirmScreen({super.key, required this.templateId});

  @override
  State<TemplateConfirmScreen> createState() => _TemplateConfirmScreenState();
}

class _TemplateConfirmScreenState extends State<TemplateConfirmScreen> {
  final _api = ApiService();
  List<PlaceholderModel> _placeholders = [];
  bool _loading = true;
  bool _saving = false;
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
      final phs = await _api.getPlaceholders(widget.templateId);
      setState(() {
        _placeholders = phs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);
    try {
      final updates = _placeholders
          .map((p) => {
                'placeholderId': p.placeholderId,
                'questionText': p.questionText,
                'displayLabel': p.displayLabel,
                'fieldType': p.fieldType,
                'isRequired': p.isRequired == 'Y',
              })
          .toList();

      await _api.confirmPlaceholders(widget.templateId, updates);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Placeholders confirmed ✓'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating));
      context.go('/templates');
    } catch (e) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPlaceholders =
        _placeholders.where((p) => p.placeholderPrefix == 'TEXT').toList();
    final datePlaceholders =
        _placeholders.where((p) => p.placeholderPrefix == 'DATE').toList();
    final imagePlaceholders =
        _placeholders.where((p) => p.placeholderPrefix == 'IMG' || p.fieldType == 'IMAGE').toList();

    final List<Widget> sectionWidgets = [];
    final List<PlaceholderModel> allImages = [];

    String? currentSection;
    List<PlaceholderModel> currentBlockPlaceholders = [];

    void flushBlock() {
      if (currentBlockPlaceholders.isNotEmpty && currentSection != null) {
        sectionWidgets.add(_PlaceholderSection(
          title: currentSection,
          color: AppTheme.accent,
          placeholders: currentBlockPlaceholders,
        ));
        currentBlockPlaceholders = [];
      }
    }

    for (var p in _placeholders) {
      if (p.fieldType == 'IMAGE' || p.placeholderPrefix == 'IMG') {
        allImages.add(p);
        continue;
      }

      final sec = (p.sectionName?.isNotEmpty == true)
          ? p.sectionName!
          : 'General Information';

      if (currentSection != sec) {
        flushBlock();
        currentSection = sec;
      }
      currentBlockPlaceholders.add(p);
    }
    flushBlock();

    if (allImages.isNotEmpty) {
      sectionWidgets.add(_PlaceholderSection(
        title: 'Image Uploads',
        color: const Color(0xFF8B5CF6),
        placeholders: allImages,
      ));
    }

    return AppLayout(
      currentRoute: '/templates',
      title: 'Confirm Placeholders',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : Column(
                    children: [
                      // Summary bar
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.chipBlue,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.accent.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: AppTheme.accent, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(
                                    'Found ${_placeholders.length} placeholders: '
                                    '${textPlaceholders.length} text, '
                                    '${datePlaceholders.length} date, '
                                    '${imagePlaceholders.length} image. '
                                    'Review and edit questions before confirming.',
                                    style: const TextStyle(
                                        color: AppTheme.accent, fontSize: 13))),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _saving ? null : _confirm,
                              icon: _saving
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.check_rounded, size: 16),
                              label: const Text('Confirm All'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.success),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Placeholder table
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Column(
                              children: sectionWidgets,
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

class _PlaceholderSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<PlaceholderModel> placeholders;

  const _PlaceholderSection({
    required this.title,
    required this.color,
    required this.placeholders,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ),
        Table(
          columnWidths: const {
            0: FixedColumnWidth(200),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(2),
            3: FixedColumnWidth(120),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: AppTheme.surface),
              children: [
                'Placeholder Key',
                'Display Label',
                'Question for Users',
                'Field Type'
              ]
                  .map((h) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Text(h,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary))))
                  .toList(),
            ),
            ...placeholders.map((p) => TableRow(
                  decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppTheme.border))),
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(p.placeholderKey,
                            style: const TextStyle(
                                fontFamily: 'Courier New',
                                fontSize: 11,
                                color: AppTheme.accent))),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        initialValue: p.displayLabel,
                        onChanged: (v) => p.displayLabel = v,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        initialValue: p.questionText,
                        onChanged: (v) => p.questionText = v,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: _FieldTypeDropdown(
                        value: p.fieldType,
                        onChanged: (v) => p.fieldType = v!,
                      ),
                    ),
                  ],
                )),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _FieldTypeDropdown extends StatefulWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _FieldTypeDropdown({required this.value, required this.onChanged});

  @override
  State<_FieldTypeDropdown> createState() => _FieldTypeDropdownState();
}

class _FieldTypeDropdownState extends State<_FieldTypeDropdown> {
  late String _current;

  @override
  void initState() {
    super.initState();
    _current = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _current,
      isDense: true,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      items: const [
        DropdownMenuItem(
            value: 'TEXT', child: Text('Text', style: TextStyle(fontSize: 12))),
        DropdownMenuItem(
            value: 'DATE', child: Text('Date', style: TextStyle(fontSize: 12))),
        DropdownMenuItem(
            value: 'IMAGE',
            child: Text('Image', style: TextStyle(fontSize: 12))),
        DropdownMenuItem(
            value: 'NUMBER',
            child: Text('Number', style: TextStyle(fontSize: 12))),
        DropdownMenuItem(
            value: 'SELECT',
            child: Text('Select', style: TextStyle(fontSize: 12))),
      ],
      onChanged: (v) {
        setState(() => _current = v!);
        widget.onChanged(v);
      },
    );
  }
}
