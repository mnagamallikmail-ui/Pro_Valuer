import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../models/report_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/common_widgets.dart';

class ReportDetailScreen extends StatefulWidget {
  final int reportId;
  const ReportDetailScreen({super.key, required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final _api = ApiService();
  ReportDetailModel? _report;
  bool _loading = true;
  bool _generating = false;
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
      final r = await _api.getReport(widget.reportId);
      setState(() {
        _report = r;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      await _api.generateReport(widget.reportId);
      if (!mounted) return;
      setState(() => _generating = false);
      _load();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Document generated! Ready for download.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating));
    } catch (e) {
      setState(() => _generating = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Generation failed: $e'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/reports',
      title: _report != null ? _report!.referenceNumber : 'Report Detail',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.danger, size: 48),
                    const SizedBox(height: 16),
                    Text(_error!,
                        style: const TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: _load, child: const Text('Retry')),
                  ],
                ))
              : _ReportDetailContent(
                  report: _report!,
                  onEdit: () => context.go('/reports/${widget.reportId}/edit'),
                  onGenerate: _generate,
                  generating: _generating,
                  downloadUrl: _api.getDownloadUrl(widget.reportId),
                ),
    );
  }
}

class _ReportDetailContent extends StatelessWidget {
  final ReportDetailModel report;
  final VoidCallback onEdit;
  final VoidCallback onGenerate;
  final bool generating;
  final String downloadUrl;

  const _ReportDetailContent({
    required this.report,
    required this.onEdit,
    required this.onGenerate,
    required this.generating,
    required this.downloadUrl,
  });

  @override
  Widget build(BuildContext context) {
    final completion = report.completionPercentage;
    final filledValues = report.values.where((v) => v.hasValue).length;
    final totalFields = report.values.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left panel: info + fields
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ReferenceChip(
                              referenceNumber: report.referenceNumber),
                          const SizedBox(width: 12),
                          StatusChip(status: report.reportStatus),
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_rounded, size: 16),
                            label: const Text('Fill Data'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(report.reportTitle,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        children: [
                          if (report.bankName != null)
                            _InfoChip(
                                icon: Icons.account_balance_rounded,
                                text: report.bankName!),
                          if (report.vendorName != null)
                            _InfoChip(
                                icon: Icons.business_rounded,
                                text: report.vendorName!),
                          if (report.location != null)
                            _InfoChip(
                                icon: Icons.location_on_rounded,
                                text: report.location!),
                          if (report.templateName != null)
                            _InfoChip(
                                icon: Icons.folder_copy_rounded,
                                text: report.templateName!),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Completion bar
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('$completion% Complete',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    Text(
                                        '$filledValues / $totalFields fields filled',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: completion / 100,
                                    backgroundColor: AppTheme.border,
                                    valueColor: AlwaysStoppedAnimation(
                                        completion == 100
                                            ? AppTheme.success
                                            : AppTheme.accent),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Values table
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Text('Field Values',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 12),
                      Table(
                        columnWidths: const {
                          0: FixedColumnWidth(40),
                          1: FlexColumnWidth(1.5),
                          2: FlexColumnWidth(2),
                          3: FixedColumnWidth(100),
                        },
                        children: [
                          TableRow(
                            decoration:
                                const BoxDecoration(color: AppTheme.surface),
                            children: ['#', 'Section / Field', 'Value', 'Type']
                                .map((h) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Text(h,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textSecondary))))
                                .toList(),
                          ),
                          ...() {
                            int displayIndex = 1;
                            Map<String, List<ReportValueModel>> sectionsMap =
                                {};
                            for (var v in report.values) {
                              final sec = (v.sectionName?.isNotEmpty == true)
                                  ? v.sectionName!
                                  : 'General Information';
                              sectionsMap.putIfAbsent(sec, () => []).add(v);
                            }

                            List<TableRow> rows = [];
                            sectionsMap.forEach((sectionName, values) {
                              rows.add(TableRow(
                                  decoration: const BoxDecoration(
                                      color: AppTheme.surface),
                                  children: [
                                    const SizedBox(), // Empty for #
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      child: Text(sectionName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.accent,
                                              fontSize: 13)),
                                    ),
                                    const SizedBox(),
                                    const SizedBox(),
                                  ]));

                              for (var v in values) {
                                rows.add(TableRow(
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          top: BorderSide(
                                              color: AppTheme.border))),
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text('${displayIndex++}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color:
                                                    AppTheme.textSecondary))),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(v.displayLabel,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500)),
                                          Text(v.placeholderKey,
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppTheme.accent,
                                                  fontFamily: 'Courier New')),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: v.hasValue
                                    ? v.isImage
                                        ? Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: Image.network(
                                                  ApiService().getBlobImageUrl(report.reportId, v.placeholderKey),
                                                  width: 32,
                                                  height: 32,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => 
                                                    const Icon(Icons.image_rounded, size: 20, color: AppTheme.success),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                v.imageOriginalName ?? 'Uploaded',
                                                style: const TextStyle(fontSize: 12, color: AppTheme.success),
                                              ),
                                            ],
                                          )
                                              : Text(v.textValue ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 12))
                                          : const Text('—',
                                              style: TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 12)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surface,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(v.fieldType,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.textSecondary)),
                                      ),
                                    ),
                                  ],
                                ));
                              }
                            });
                            return rows;
                          }(),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Right panel: actions
          SizedBox(
            width: 220,
            child: Column(
              children: [
                _ActionCard(
                  title: 'Fill Report Data',
                  subtitle: 'Enter values for all fields',
                  icon: Icons.edit_note_rounded,
                  color: AppTheme.accent,
                  onTap: onEdit,
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  title: 'Generate Document',
                  subtitle: completion < 100
                      ? 'Incomplete: $completion% filled'
                      : 'Create final .docx',
                  icon: Icons.play_arrow_rounded,
                  color: completion < 100 ? AppTheme.warning : AppTheme.success,
                  onTap: () {
                    if (completion < 100) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Generate Incomplete Report?'),
                          content: const Text(
                              'Some fields are empty. Missing values will be filled with "—" and a Missing Data Summary will be added to the document.\n\nDo you want to continue?'),
                          actions: [
                            TextButton(
                              autofocus: true,
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Go fix missing'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                onGenerate();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.danger,
                                  foregroundColor: Colors.white),
                              child: const Text('Generate anyway'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      onGenerate();
                    }
                  },
                  loading: generating,
                ),
                if (report.hasGeneratedFile) ...[
                  const SizedBox(height: 12),
                  _ActionCard(
                    title: 'Download Report',
                    subtitle: 'Save final .docx file',
                    icon: Icons.download_rounded,
                    color: const Color(0xFF8B5CF6),
                    onTap: () async {
                      final url = Uri.parse(downloadUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    externalUrl: downloadUrl,
                  ),
                ],
                const SizedBox(height: 20),
                // Metadata card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Report Info',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      _MetaRow('Created by', report.createdBy ?? '—'),
                      _MetaRow(
                          'Created at',
                          report.createdAt != null
                              ? DateFormat('dd MMM yyyy HH:mm')
                                  .format(report.createdAt!)
                              : '—'),
                      if (report.updatedBy != null)
                        _MetaRow('Last updated by', report.updatedBy!),
                      if (report.generatedAt != null)
                        _MetaRow(
                            'Generated at',
                            DateFormat('dd MMM yyyy HH:mm')
                                .format(report.generatedAt!)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(text,
            style:
                const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          Text(value,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;
  final String? externalUrl;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.loading = false,
    this.externalUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: onTap != null ? color.withOpacity(0.4) : AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: loading
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                          color: color, strokeWidth: 2))
                  : Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: onTap != null
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
