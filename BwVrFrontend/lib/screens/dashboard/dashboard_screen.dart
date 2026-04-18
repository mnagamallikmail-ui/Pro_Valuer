import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/report_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _api = ApiService();
  DashboardStats? _stats;
  List<ReportModel> _recentReports = [];
  bool _loading = true;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    // Reactive: Setup periodic refresh to reflect backend updates instantly
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
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
      final stats = await _api.getDashboardStats();
      final reports = await _api.getReportList();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _recentReports = reports.take(8).toList();
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

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/',
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryText))
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _load)
              : _DashboardContent(
                  stats: _stats!,
                  recentReports: _recentReports,
                ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardStats stats;
  final List<ReportModel> recentReports;

  const _DashboardContent({required this.stats, required this.recentReports});

  @override
  Widget build(BuildContext context) {
    final session = AuthService().session;
    final displayName = session?.displayName ?? 'User';
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          if (isMobile) ...[
            Text('VALUATION INSIGHTS', style: AppTypography.label.copyWith(color: AppColors.primary, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text('Welcome, \n$displayName', style: AppTypography.heading1.copyWith(fontSize: 32)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('/reports/new'),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Initiate Valuation'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VALUATION INSIGHTS', style: AppTypography.label.copyWith(color: AppColors.primary, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text('Welcome, $displayName', style: AppTypography.heading1.copyWith(fontSize: 40)),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => context.go('/reports/new'),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Initiate Valuation'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: isMobile ? 32 : 48),

          // Stats Grid
          GridView.count(
            crossAxisCount: isMobile ? 1 : (width < 1200 ? 2 : 4),
            shrinkWrap: true,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: isMobile ? 2.0 : 1.4,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatsCard(
                title: 'Active Valuations',
                value: stats.totalReports.toString(),
                icon: Icons.assignment_outlined,
                color: AppColors.primaryText,
                trend: '+12% this week',
              ),
              StatsCard(
                title: 'Monthly Throughput',
                value: stats.reportsThisMonth.toString(),
                icon: Icons.trending_up_rounded,
                color: AppColors.primary,
                trend: 'Stable',
              ),
              StatsCard(
                title: 'Templates Utilized',
                value: stats.activeTemplates.toString(),
                icon: Icons.layers_outlined,
                color: AppColors.accent,
                trend: '4 new',
              ),
              StatsCard(
                title: 'Connected FIs',
                value: stats.distinctBanks.toString(),
                icon: Icons.account_balance_outlined,
                color: AppColors.secondary,
                trend: 'Global',
              ),
            ],
          ),
          SizedBox(height: isMobile ? 40 : 64),

          // Main Content Region
          if (isMobile) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Recent Activity'),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: 600),
                        child: _RecentTable(reports: recentReports)
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const SectionHeader(title: 'System Board'),
                _SystemBoardItem(
                  title: 'Auto-Sync Active',
                  subtitle: 'Oracle DB connection healthy',
                  icon: Icons.sync_rounded,
                  color: AppColors.primaryText,
                ),
                const SizedBox(height: 16),
                _SystemBoardItem(
                  title: 'New Template Added',
                  subtitle: 'HDFC General - v2.4',
                  icon: Icons.add_to_photos_rounded,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 16),
                _SystemBoardItem(
                  title: 'API Status',
                  subtitle: 'All endpoints responding',
                  icon: Icons.bolt_rounded,
                  color: AppColors.secondary,
                ),
              ],
            )
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Recent Table
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Recent Activity'),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryText.withOpacity(0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 800),
                              child: _RecentTable(reports: recentReports),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                // Right: System Board
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'System Board'),
                      _SystemBoardItem(
                        title: 'Auto-Sync Active',
                        subtitle: 'Oracle DB connection healthy',
                        icon: Icons.sync_rounded,
                        color: AppColors.primaryText,
                      ),
                      const SizedBox(height: 16),
                      _SystemBoardItem(
                        title: 'New Template Added',
                        subtitle: 'HDFC General - v2.4',
                        icon: Icons.add_to_photos_rounded,
                        color: AppColors.accent,
                      ),
                      const SizedBox(height: 16),
                      _SystemBoardItem(
                        title: 'API Status',
                        subtitle: 'All endpoints responding',
                        icon: Icons.bolt_rounded,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentTable extends StatelessWidget {
  final List<ReportModel> reports;
  const _RecentTable({required this.reports});

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const EmptyState(
        icon: Icons.description_outlined,
        title: 'Queue Empty',
        subtitle: 'Start a new report to see results here',
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FixedColumnWidth(140),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: AppColors.surface),
          children: [
            _th('Valuation Details'),
            _th('Bank / Vendor'),
            _th('Status'),
          ],
        ),
        ...reports.map((r) => TableRow(
              children: [
                _td(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.reportTitle, style: AppTypography.heading3.copyWith(fontSize: 14)),
                    const SizedBox(height: 4),
                    ReferenceChip(label: r.referenceNumber),
                  ],
                )),
                _td(Text('${r.bankName ?? 'N/A'}\n${r.vendorName ?? 'N/A'}',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.accent))),
                _td(StatusChip(status: r.reportStatus)),
              ],
            )),
      ],
    );
  }

  Widget _th(String label) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(label, style: AppTypography.label.copyWith(color: AppColors.primaryText)),
      );

  Widget _td(Widget child) => InkWell(
        onTap: () {}, // Detail navigation
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: child,
        ),
      );
}

class _SystemBoardItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SystemBoardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.heading3.copyWith(fontSize: 14)),
                Text(subtitle, style: AppTypography.bodyMedium.copyWith(fontSize: 12, color: AppColors.accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.primary, size: 64),
          const SizedBox(height: 24),
          Text('Streaming Disrupted', style: AppTypography.heading2),
          const SizedBox(height: 12),
          Text(error, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: onRetry, child: const Text('Re-initialize Stream')),
        ],
      ),
    );
  }
}
