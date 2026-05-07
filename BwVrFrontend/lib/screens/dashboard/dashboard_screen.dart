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
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
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

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 900;
      final padding = isMobile ? 16.0 : 32.0;

      return SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header (Minimalist)
            _buildWelcomeInfo(isAdmin, displayName, context, isMobile),
            const SizedBox(height: 48),

            // Stats cards
            Text('Overview', style: AppTypography.heading3),
            const SizedBox(height: 20),
            _buildStatsGrid(constraints.maxWidth, context),
            
            const SizedBox(height: 48),

            // Recent reports
            Row(
              children: [
                Text('Recent Reports', style: AppTypography.heading3),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/reports'),
                  child: const Text('View all →'),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentReports.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final r = recentReports[i];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 24, vertical: 12),
                      leading: isMobile 
                        ? null 
                        : Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.description_rounded,
                                color: AppColors.textPrimary, size: 24),
                          ),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ReferenceChip(referenceNumber: r.referenceNumber, fontSize: 11),
                          const SizedBox(width: 8),
                          Text(r.reportTitle,
                              style: AppTypography.subheading,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('${r.bankName ?? ''} • ${r.vendorName ?? ''}',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis),
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
    });
  }

  Widget _buildWelcomeInfo(bool isAdmin, String displayName, BuildContext context, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAdmin ? 'Admin Dashboard' : 'Welcome back,',
                style: AppTypography.subheading.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                displayName,
                style: AppTypography.heading1.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: isMobile ? 24 : 32,
                ),
              ),
            ],
          ),
        ),
        if (!isMobile)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAdmin) ...[
                OutlinedButton.icon(
                  onPressed: () => context.go('/templates/upload'),
                  icon: const Icon(Icons.upload_rounded, size: 18),
                  label: const Text('Upload Template'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              ElevatedButton.icon(
                onPressed: () => context.go('/reports/new'),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary, // Gold CTA
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStatsGrid(double maxWidth, BuildContext context) {
<<<<<<< HEAD
    final double spacing = 20;
    int crossAxisCount = 4;
    if (maxWidth < 600) crossAxisCount = 1;
    else if (maxWidth < 1000) crossAxisCount = 2;

    final double cardWidth = (maxWidth - (spacing * (crossAxisCount + 1))) / crossAxisCount;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        _buildStatsCard(
          cardWidth,
          context,
          '/reports',
          'Total Reports',
          stats.totalReports.toString(),
          Icons.description_rounded,
          AppColors.accent,
        ),
        _buildStatsCard(
          cardWidth,
          context,
          '/reports',
          'This Month',
          stats.reportsThisMonth.toString(),
          Icons.calendar_today_rounded,
          AppColors.secondary,
          subtitle: 'New reports',
        ),
        _buildStatsCard(
          cardWidth,
          context,
          '/templates',
          'Active Templates',
          stats.activeTemplates.toString(),
          Icons.folder_copy_rounded,
          AppColors.primary,
        ),
        _buildStatsCard(
          cardWidth,
          context,
          '',
          'Banks',
          stats.distinctBanks.toString(),
          Icons.account_balance_rounded,
          AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildStatsCard(double width, BuildContext context, String route, String title, String value, IconData icon, Color color, {String? subtitle}) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: route.isEmpty ? null : () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: StatsCard(
          title: title,
          value: value,
          icon: icon,
          color: color,
          subtitle: subtitle,
        ),
=======
    final bool isMobile = maxWidth < 800;
    
    final cards = [
      _buildStatsCard(context, '/reports', 'Total Reports', stats.totalReports.toString(), Icons.description_rounded, AppColors.accent),
      _buildStatsCard(context, '/reports', 'This Month', stats.reportsThisMonth.toString(), Icons.calendar_today_rounded, AppColors.secondary, subtitle: 'New reports'),
      _buildStatsCard(context, '/templates', 'Active Templates', stats.activeTemplates.toString(), Icons.folder_copy_rounded, AppColors.primary),
      _buildStatsCard(context, '', 'Banks', stats.distinctBanks.toString(), Icons.account_balance_rounded, AppColors.accent),
    ];

    if (isMobile) {
      return Column(
        children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList(),
      );
    }

    return Row(
      children: cards.map((c) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: c == cards.last ? 0 : 16),
          child: c,
        ),
      )).toList(),
    );
  }

  Widget _buildStatsCard(BuildContext context, String route, String title, String value, IconData icon, Color color, {String? subtitle}) {
    return InkWell(
      onTap: route.isEmpty ? null : () => context.go(route),
      borderRadius: BorderRadius.circular(12),
      child: StatsCard(
        title: title,
        value: value,
        icon: icon,
        color: color,
        subtitle: subtitle,
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
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
          const Icon(Icons.error_outline, color: AppColors.textPrimary, size: 48),
          const SizedBox(height: 16),
          Text('Failed to load dashboard', style: AppTypography.heading3),
          const SizedBox(height: 8),
          Text(error, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 32),
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
