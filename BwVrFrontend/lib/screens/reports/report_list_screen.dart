import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../models/report_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/common_widgets.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final _api = ApiService();
  final _notifications = NotificationService();
  final _searchController = TextEditingController();
  List<ReportModel> _reports = [];
  String? _selectedStatus;
  bool _loading = true;
  String? _error;
  int _totalReports = 0;
  int _currentPage = 0;
  static const int _pageSize = 20;

  StreamSubscription? _changeSubscription;

  @override
  void initState() {
    super.initState();
    _load();
    // Reactive: Listen to real-time changes
    _changeSubscription = _notifications.changeStream.listen((_) {
      _load(silent: true);
    });
  }

  @override
  void dispose() {
    _changeSubscription?.cancel();
    _searchController.dispose();
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
      final data = await _api.searchReports(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        status: _selectedStatus,
        page: _currentPage,
        size: _pageSize,
      );
      final content = data['content'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _reports = content.map((r) => ReportModel.fromJson(r)).toList();
        _totalReports = data['totalElements'] ?? 0;
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

  Future<void> _deleteReport(ReportModel report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Valuation', style: AppTypography.heading3),
        content: Text("Are you sure you want to delete '${report.reportTitle}'? This action cannot be undone.", style: AppTypography.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _api.deleteReport(report.reportId);
        _load(silent: true);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Valuation deleted successfully'), backgroundColor: AppColors.textPrimary),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return AppLayout(
      currentRoute: '/reports',
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Toolbar
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
                      TextField(
                        controller: _searchController,
                        style: AppTypography.bodyMedium,
                        decoration: const InputDecoration(
                          filled: false,
                          hintText: 'Search asset or reference...',
                          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                        ),
                        onChanged: (_) {
                          _currentPage = 0;
                          _load();
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        style: AppTypography.bodyMedium,
                        decoration: const InputDecoration(filled: false, labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All Records')),
                          DropdownMenuItem(value: 'DRAFT', child: Text('Drafts')),
                          DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                          DropdownMenuItem(value: 'COMPLETED', child: Text('Finalized')),
                        ],
                        onChanged: (v) {
                          setState(() => _selectedStatus = v);
                          _load();
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/reports/new').then((_) => _load()),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Valuation'),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _searchController,
                          style: AppTypography.bodyLarge,
                          decoration: const InputDecoration(
                            filled: false,
                            hintText: 'Filter valuations by keyword...',
                            prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
                          ),
                          onChanged: (_) {
                            _currentPage = 0;
                            _load();
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          style: AppTypography.bodyMedium,
                          decoration: const InputDecoration(filled: false, labelText: 'Status Filter'),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('All Records')),
                            DropdownMenuItem(value: 'DRAFT', child: Text('Drafts')),
                            DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                            DropdownMenuItem(value: 'COMPLETED', child: Text('Finalized')),
                          ],
                          onChanged: (v) {
                            setState(() => _selectedStatus = v);
                            _load();
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/reports/new').then((_) => _load()),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('New Valuation'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        ),
                      ),
                    ],
                  ),
            ),
            SizedBox(height: isMobile ? 24 : 32),
            
            Row(
              children: [
                Text('$_totalReports Records Matching', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('Page ${_currentPage + 1}', style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 16),

            // Records List
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _error != null
                      ? Center(child: Text('Interrupted: $_error', style: AppTypography.bodyMedium.copyWith(color: AppColors.error)))
                      : _reports.isEmpty
                          ? const EmptyState(
                              icon: Icons.search_off_rounded,
                              title: 'No Matches',
                              subtitle: 'Try a different keyword.',
                            )
                          : ListView.builder(
                              itemCount: _reports.length,
                              itemBuilder: (context, i) {
                                final r = _reports[i];
                                return _ReportListItem(
                                  report: r,
                                  onTap: () => context.go('/reports/${r.reportId}'),
                                  onDelete: () => _deleteReport(r),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportListItem extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  _ReportListItem({super.key, required this.report, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final completion = report.completionPercentage;
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: isMobile 
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(report.reportTitle, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ReferenceChip(label: report.referenceNumber),
                  const SizedBox(height: 16),
                  Text('${report.bankName ?? 'Independent'} • ${report.location ?? 'India'}', 
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$completion% COMPLETE', style: AppTypography.label.copyWith(fontSize: 10, fontWeight: FontWeight.w600)),
                      StatusChip(status: report.reportStatus),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completion / 100,
                      backgroundColor: AppColors.surface,
                      valueColor: AlwaysStoppedAnimation(completion == 100 ? AppColors.success : AppColors.primary),
                      minHeight: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                        label: Text('Delete', style: AppTypography.label.copyWith(color: AppColors.error)),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report.reportTitle, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ReferenceChip(label: report.referenceNumber),
                            const SizedBox(width: 8),
                            Text('• ${report.bankName ?? 'Independent'}', 
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(completion == 100 ? 'READY' : 'PROGRESS', style: AppTypography.label.copyWith(fontSize: 9)),
                            Text('$completion%', style: AppTypography.label.copyWith(fontSize: 9, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: completion / 100,
                            backgroundColor: AppColors.surface,
                            valueColor: AlwaysStoppedAnimation(completion == 100 ? AppColors.success : AppColors.primary),
                            minHeight: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusChip(status: report.reportStatus),
                      const SizedBox(height: 6),
                      Text(report.createdAt != null ? DateFormat('dd MMM yyyy').format(report.createdAt!) : '-', 
                        style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                    tooltip: 'Delete Valuation',
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.border, size: 20),
                ],
              ),
        ),
      ),
    );
  }
}

