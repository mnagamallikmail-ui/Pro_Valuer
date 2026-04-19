import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
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
  final _notifications = NotificationService();
  DashboardStats? _stats;
  List<ReportModel> _recentReports = [];
  bool _loading = true;
  String? _error;
  StreamSubscription? _changeSubscription;

  @override
  void initState() {
    super.initState();
    _load();
    // Reactive: Listen to real-time changes instead of polling
    _changeSubscription = _notifications.changeStream.listen((event) {
      debugPrint('[Dashboard] Reacting to: $event');
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
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Text(
            'LUMINOUS INSIGHTS', 
            style: AppTypography.label.copyWith(
              color: AppColors.primary, 
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600
            )
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  isMobile ? 'Welcome, \n$displayName' : 'Welcome back, $displayName', 
                  style: AppTypography.heading1.copyWith(fontSize: isMobile ? 32 : 36)
                ),
              ),
              if (!isMobile)
                ElevatedButton.icon(
                  onPressed: () => context.go('/reports/new'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New Valuation'),
                ),
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.go('/reports/new'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New Valuation'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],

          SizedBox(height: isMobile ? 32 : 40),

          // Stats Grid
          GridView.count(
            crossAxisCount: isMobile ? 1 : (width < 1200 ? 2 : 4),
            shrinkWrap: true,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: isMobile ? 2.2 : 1.6,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatsCard(
                title: 'Total Valuations',
                value: stats.totalReports.toString(),
                icon: Icons.assignment_outlined,
                color: AppColors.primaryText,
                trend: '+5%',
              ),
              StatsCard(
                title: 'Monthly Progress',
                value: stats.reportsThisMonth.toString(),
                icon: Icons.show_chart_rounded,
                color: AppColors.primary,
                trend: 'Active',
              ),
              StatsCard(
                title: 'Active Blueprints',
                value: stats.activeTemplates.toString(),
                icon: Icons.style_outlined,
                color: AppColors.action,
                trend: 'Updated',
              ),
              StatsCard(
                title: 'Financial Partners',
                value: stats.distinctBanks.toString(),
                icon: Icons.account_balance_outlined,
                color: AppColors.textSecondary,
                trend: 'Verified',
              ),
            ],
          ),
          SizedBox(height: isMobile ? 40 : 56),

          // Main Content Region
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
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: isMobile ? 600 : 800),
                            child: _RecentTable(reports: recentReports),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 32),
                // Right: System Alerts
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Alerts'),
                      _SystemBoardItem(
                        title: 'Data Synchronized',
                        subtitle: 'Database pulse normal',
                        icon: Icons.check_circle_outline_rounded,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 12),
                      _SystemBoardItem(
                        title: 'Template Update',
                        subtitle: 'RBI Compliance v3.0',
                        icon: Icons.info_outline_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      _SystemBoardItem(
                        title: 'Memory Usage',
                        subtitle: 'System load minimal',
                        icon: Icons.speed_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 32),
            const SectionHeader(title: 'System Alerts'),
            _SystemBoardItem(
              title: 'Data Synchronized',
              subtitle: 'Database pulse normal',
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.success,
            ),
          ]
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
        title: 'Empty Queue',
        subtitle: 'No valuations found',
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FixedColumnWidth(120),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: AppColors.surface),
          children: [
            _th('VALUATION ASSET'),
            _th('INSTITUTION'),
            _th('STATUS'),
          ],
        ),
        ...reports.map((r) => TableRow(
              children: [
                _td(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.reportTitle, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    ReferenceChip(label: r.referenceNumber),
                  ],
                )),
                _td(Text(r.bankName ?? 'Independent',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary))),
                _td(Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Center(child: StatusChip(status: r.reportStatus)),
                )),
              ],
            )),
      ],
    );
  }

  Widget _th(String label) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          label, 
          style: AppTypography.label.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
            letterSpacing: 1
          )
        ),
      );

  Widget _td(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: child,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitle, style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.textSecondary)),
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
          const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 48),
          const SizedBox(height: 24),
          Text('Sync Interrupted', style: AppTypography.heading3),
          const SizedBox(height: 12),
          Text(error, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry Connection')),
        ],
      ),
    );
  }
}

