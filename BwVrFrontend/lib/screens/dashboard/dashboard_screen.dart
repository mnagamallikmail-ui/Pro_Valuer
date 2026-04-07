import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/report_model.dart';
import '../../theme/app_theme.dart';
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
      final stats = await _api.getDashboardStats();
      final reports = await _api.getReportList();
      setState(() {
        _stats = stats;
        _recentReports = reports.take(10).toList();
        _loading = false;
      });
    } catch (e) {
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
          ? const Center(child: CircularProgressIndicator())
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
    final isAdmin = session?.isAdmin ?? false;
    final displayName = session?.displayName ?? 'User';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAdmin ? 'Admin Dashboard' : 'Welcome back!',
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(displayName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => context.go('/reports/new'),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('New Report'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => context.go('/templates/upload'),
                            icon: const Icon(Icons.upload_rounded, size: 16),
                            label: const Text('Upload Template'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white30),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.description_rounded,
                    size: 80, color: Colors.white12),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats cards
          const Text('Overview',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: InkWell(
                onTap: () => context.go('/reports'),
                borderRadius: BorderRadius.circular(12),
                child: StatsCard(
                  title: 'Total Reports',
                  value: stats.totalReports.toString(),
                  icon: Icons.description_rounded,
                  color: AppTheme.accent,
                ),
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: InkWell(
                onTap: () => context.go('/reports'),
                borderRadius: BorderRadius.circular(12),
                child: StatsCard(
                  title: 'This Month',
                  value: stats.reportsThisMonth.toString(),
                  icon: Icons.calendar_today_rounded,
                  color: AppTheme.success,
                  subtitle: 'New reports',
                ),
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: InkWell(
                onTap: () => context.go('/templates'),
                borderRadius: BorderRadius.circular(12),
                child: StatsCard(
                  title: 'Active Templates',
                  value: stats.activeTemplates.toString(),
                  icon: Icons.folder_copy_rounded,
                  color: AppTheme.warning,
                ),
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: StatsCard(
                  title: 'Banks',
                  value: stats.distinctBanks.toString(),
                  icon: Icons.account_balance_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
              )),
            ],
          ),
          const SizedBox(height: 32),

          // Recent reports
          Row(
            children: [
              const Text('Recent Reports',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/reports'),
                child: const Text('View all →'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentReports.isEmpty)
            EmptyState(
              icon: Icons.description_outlined,
              title: 'No reports yet',
              subtitle: 'Create your first report to get started',
              action: ElevatedButton(
                onPressed: () => context.go('/reports/new'),
                child: const Text('Create Report'),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentReports.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final r = recentReports[i];
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.chipBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.description_rounded,
                          color: AppTheme.accent, size: 20),
                    ),
                    title: Row(
                      children: [
                        ReferenceChip(
                            referenceNumber: r.referenceNumber, fontSize: 11),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(r.reportTitle,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('${r.bankName ?? ''} • ${r.vendorName ?? ''}',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ),
                    trailing: StatusChip(status: r.reportStatus),
                    onTap: () => context.go('/reports/${r.reportId}'),
                  );
                },
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
          const Icon(Icons.error_outline, color: AppTheme.danger, size: 48),
          const SizedBox(height: 16),
          const Text('Failed to load dashboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(error,
              style: const TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
