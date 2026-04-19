import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../models/report_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
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
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
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
          backgroundColor: AppColors.textPrimary));
    } catch (e) {
      if (mounted) {
        setState(() => _generating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Generation failed: $e'),
            backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/reports',
      title: _report?.referenceNumber ?? 'Report Detail',
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.textPrimary))
          : _error != null
              ? Center(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.textPrimary, size: 48),
                    const SizedBox(height: 16),
                    Text(_error!, style: AppTypography.bodyMedium),
                    const SizedBox(height: 24),
                    ElevatedButton(onPressed: _load, child: const Text('Retry')),
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
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Panel
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ReferenceChip(referenceNumber: report.referenceNumber),
                          const SizedBox(width: 12),
                          StatusChip(status: report.reportStatus),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: const Text('Edit Data'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(report.reportTitle, style: AppTypography.heading2),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 24,
                        runSpacing: 8,
                        children: [
                          if (report.bankName != null) _InfoItem(Icons.account_balance_rounded, report.bankName!),
                          if (report.vendorName != null) _InfoItem(Icons.business_rounded, report.vendorName!),
                          if (report.location != null) _InfoItem(Icons.location_on_rounded, report.location!),
                          if (report.templateName != null) _InfoItem(Icons.folder_copy_rounded, report.templateName!),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('$completion% Complete', style: AppTypography.subheading),
                              const Spacer(),
                              Text('$filledValues / $totalFields fields', style: AppTypography.label),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: completion / 100,
                              minHeight: 10,
                              backgroundColor: AppColors.background,
                              valueColor: AlwaysStoppedAnimation(completion == 100 ? AppColors.secondary : AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Fields Panel
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Report Data', style: AppTypography.heading3),
                      ),
                      const Divider(height: 1),
                      ..._buildSections(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),

          // Sidebar Actions
          SizedBox(
            width: 280,
            child: Column(
              children: [
                _ActionTile(
                  title: 'Fill Information',
                  subtitle: 'Update field values and images',
                  icon: Icons.edit_note_rounded,
                  color: AppColors.primary,
                  onTap: onEdit,
                ),
                const SizedBox(height: 16),
                _ActionTile(
                  title: 'Generate Document',
                  subtitle: completion < 100 ? 'Warning: Incomplete' : 'Ready to build .docx',
                  icon: Icons.bolt_rounded,
                  color: completion < 100 ? AppColors.primary : AppColors.secondary,
                  loading: generating,
                  onTap: () {
                    if (completion < 100) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Generate Incomplete?', style: AppTypography.heading3),
                          content: const Text('Some fields are empty. Generate anyway?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Go Back')),
                            ElevatedButton(
                              onPressed: () { Navigator.pop(ctx); onGenerate(); },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                              child: const Text('Generate'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      onGenerate();
                    }
                  },
                ),
                if (report.hasGeneratedFile) ...[
                  const SizedBox(height: 16),
                  _ActionTile(
                    title: 'Download DOCX',
                    subtitle: 'Save final report to device',
                    icon: Icons.download_rounded,
                    color: AppColors.accent,
                    onTap: () async {
                      final url = Uri.parse(downloadUrl);
                      if (await canLaunchUrl(url)) await launchUrl(url);
                    },
                  ),
                ],
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System Info', style: AppTypography.subheading),
                      const SizedBox(height: 20),
                      _MetaItem('Author', report.createdBy ?? '—'),
                      _MetaItem('Date', report.createdAt != null ? DateFormat('dd-MMM-yyyy').format(report.createdAt!) : '—'),
                      if (report.generatedAt != null) _MetaItem('Last Built', DateFormat('dd-MMM-yyyy HH:mm').format(report.generatedAt!)),
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

  List<Widget> _buildSections() {
    Map<String, List<ReportValueModel>> sectionsMap = {};
    for (var v in report.values) {
      final sec = (v.sectionName != null && v.sectionName!.isNotEmpty) ? v.sectionName! : 'General';
      sectionsMap.putIfAbsent(sec, () => []).add(v);
    }

    List<Widget> widgets = [];
    sectionsMap.forEach((name, values) {
      widgets.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          color: AppColors.background,
          child: Text(name.toUpperCase(), style: AppTypography.label.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
      );
      for (var v in values) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.displayLabel, style: AppTypography.subheading.copyWith(fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(v.placeholderKey, style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'Courier New')),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: v.hasValue
                      ? v.isImage
                          ? Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    ApiService().getBlobImageUrl(report.reportId, v.placeholderKey),
                                    width: 40, height: 40, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.image_rounded, color: AppColors.textSecondary),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(v.imageOriginalName ?? 'Image Uploaded', style: AppTypography.bodyMedium)),
                              ],
                            )
                          : Text(v.textValue ?? '', style: AppTypography.bodyMedium)
                      : Text('—', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
                  child: Text(v.fieldType, style: AppTypography.label.copyWith(fontSize: 9)),
                ),
              ],
            ),
          ),
        );
        widgets.add(const Divider(height: 1, indent: 24, endIndent: 24));
      }
    });
    return widgets;
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoItem(this.icon, this.text);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(text, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  const _MetaItem(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: loading ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary)) : Icon(icon, color: AppColors.textPrimary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.subheading.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AppTypography.label.copyWith(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
