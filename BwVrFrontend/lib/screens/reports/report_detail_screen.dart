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
import '../../services/auth_service.dart';

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

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await _api.submitReport(widget.reportId);
      if (!mounted) return;
      _load();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted for review')));
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _approve() async {
    setState(() => _loading = true);
    try {
      await _api.approveReport(widget.reportId);
      if (!mounted) return;
      _load();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report approved')));
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Approval failed: $e'), backgroundColor: AppColors.error));
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
                  onSubmit: _submit,
                  onApprove: _approve,
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
  final VoidCallback onSubmit;
  final VoidCallback onApprove;
  final bool generating;
  final String downloadUrl;

  const _ReportDetailContent({
    required this.report,
    required this.onEdit,
    required this.onGenerate,
    required this.onSubmit,
    required this.onApprove,
    required this.generating,
    required this.downloadUrl,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final isMobile = box.maxWidth < 900;
      
      return SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 32),
        child: Column(
          children: [
            if (isMobile) ...[
              _buildSidebarActions(true), // Move actions to top on mobile
              const SizedBox(height: 16),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Panel
                      _buildHeaderPanel(isMobile),
                      const SizedBox(height: 24),

                      // Fields Panel
                      _buildFieldsPanel(isMobile),
                    ],
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 32),
                  // Sidebar Actions (Desktop)
                  SizedBox(
                    width: 280,
                    child: _buildSidebarActions(false),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeaderPanel(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
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
              if (!isMobile)
                ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Edit Data'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(report.reportTitle, style: isMobile ? AppTypography.heading3 : AppTypography.heading2),
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
                  Text('${report.completionPercentage}% Complete', style: AppTypography.subheading),
                  const Spacer(),
                  Text('${report.values.where((v) => v.hasValue).length} / ${report.values.length} fields', style: AppTypography.label),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: report.completionPercentage / 100,
                  minHeight: 10,
                  backgroundColor: AppColors.structural,
                  valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsPanel(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
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
          ..._buildSections(isMobile),
        ],
      ),
    );
  }

  Widget _buildSidebarActions(bool isMobile) {
    final role = AuthService().session?.role ?? 'USER';
    final isAdmin = role == 'ADMIN';
    final isValidator = role == 'VALIDATOR';
    final status = report.reportStatus;
    
    final canEdit = isAdmin || (isValidator && (status == 'SUBMITTED' || status == 'UNDER_REVIEW' || status == 'DRAFT')) || (role == 'USER' && status == 'DRAFT');
    final canGenerate = isAdmin || (isValidator && status == 'APPROVED') || status == 'APPROVED';

    return Column(
      children: [
        if (canEdit)
          _ActionTile(
            title: 'Capture Data',
            subtitle: 'Update field values and images',
            icon: Icons.edit_note_rounded,
            color: AppColors.primary,
            onTap: onEdit,
          ),
        if (status == 'DRAFT') ...[
          const SizedBox(height: 16),
          _ActionTile(
            title: 'Submit for Review',
            subtitle: 'Send to your validator',
            icon: Icons.send_rounded,
            color: AppColors.accent,
            onTap: onSubmit,
          ),
        ],
        if ((isValidator || isAdmin) && (status == 'SUBMITTED' || status == 'UNDER_REVIEW')) ...[
          const SizedBox(height: 16),
          _ActionTile(
            title: 'Approve Report',
            subtitle: 'Mark as ready for generation',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
            onTap: onApprove,
          ),
        ],
        // GENERATE BUTTON LOGIC
        const SizedBox(height: 16),
        _ActionTile(
          title: 'Generate Build',
          subtitle: canGenerate 
              ? (report.completionPercentage < 100 ? 'Warning: Incomplete' : 'Ready to export .docx')
              : 'Awaiting Approval',
          icon: Icons.bolt_rounded,
          color: canGenerate 
              ? (report.completionPercentage < 100 ? AppColors.primary : AppColors.secondary)
              : AppColors.textSecondary.withOpacity(0.5),
          loading: generating,
          onTap: canGenerate ? onGenerate : null,
        ),
        // DOWNLOAD BUTTON LOGIC
        const SizedBox(height: 16),
        _ActionTile(
          title: 'Download DOCX',
          subtitle: (report.hasGeneratedFile && (status == 'GENERATED' || isAdmin)) 
              ? 'Save final report to device' 
              : 'Not Generated Yet',
          icon: Icons.download_rounded,
          color: (report.hasGeneratedFile && (status == 'GENERATED' || isAdmin))
              ? AppColors.accent 
              : AppColors.textSecondary.withOpacity(0.5),
          onTap: (report.hasGeneratedFile && (status == 'GENERATED' || isAdmin))
              ? () async {
                  final url = Uri.parse(downloadUrl);
                  if (await canLaunchUrl(url)) await launchUrl(url);
                }
              : null,
        ),
        if (!isMobile) ...[
          const SizedBox(height: 32),
          _buildSystemInfoPanel(),
        ],
      ],
    );
  }

  Widget _buildSystemInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
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
    );
  }

  List<Widget> _buildSections(bool isMobile) {
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
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.displayLabel, style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      _buildValueDisplay(v, isMobile),
                    ],
                  )
                : Row(
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
                        child: _buildValueDisplay(v, isMobile),
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

  Widget _buildValueDisplay(ReportValueModel v, bool isMobile) {
    if (!v.hasValue) {
      return Text('—', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary));
    }
    if (v.isImage) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              ApiService().getBlobImageUrl(report.reportId, v.placeholderKey),
              width: 48, height: 48, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image_rounded, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(v.imageOriginalName ?? 'Image Uploaded', style: AppTypography.bodyMedium, overflow: TextOverflow.ellipsis)),
        ],
      );
    }
    return Text(v.textValue ?? '', style: AppTypography.bodyMedium);
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
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: loading ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary)) : Icon(icon, color: color, size: 22),
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
