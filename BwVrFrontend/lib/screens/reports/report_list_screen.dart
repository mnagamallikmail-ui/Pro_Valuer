import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
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
  final _searchController = TextEditingController();
  List<ReportModel> _reports = [];
  String? _selectedStatus;
  bool _loading = true;
  String? _error;
  int _totalReports = 0;
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.searchReports(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        status: _selectedStatus,
        page: _currentPage,
        size: _pageSize,
      );
      final content = data['content'] as List? ?? [];
      setState(() {
        _reports = content.map((r) => ReportModel.fromJson(r)).toList();
        _totalReports = data['totalElements'] ?? 0;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteReport(ReportModel r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Report?', style: AppTypography.heading3),
        content: Text('Delete ${r.referenceNumber} permanently? This cannot be undone.', style: AppTypography.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _api.deleteReport(r.reportId);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/reports',
      child: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final padding = isMobile ? 16.0 : 32.0;

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search / filter bar
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search vendor, location...',
                              prefixIcon: Icon(Icons.search_rounded, size: 20),
                            ),
                            onChanged: (_) {
                              _currentPage = 0;
                              _load();
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Status'),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('All Statuses')),
                              DropdownMenuItem(value: 'DRAFT', child: Text('Draft')),
                              DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                              DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
                              DropdownMenuItem(value: 'ARCHIVED', child: Text('Archived')),
                            ],
                            onChanged: (v) {
                              setState(() => _selectedStatus = v);
                              _load();
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await context.push('/reports/new');
                              _load();
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('New Report'),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search vendor, location, or reference...',
                                prefixIcon: Icon(Icons.search_rounded, size: 20),
                              ),
                              onChanged: (_) {
                                _currentPage = 0;
                                _load();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: const InputDecoration(labelText: 'Status'),
                              items: const [
                                DropdownMenuItem(value: null, child: Text('All Statuses')),
                                DropdownMenuItem(value: 'DRAFT', child: Text('Draft')),
                                DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                                DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
                                DropdownMenuItem(value: 'ARCHIVED', child: Text('Archived')),
                              ],
                              onChanged: (v) {
                                setState(() => _selectedStatus = v);
                                _load();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await context.push('/reports/new');
                              _load();
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('New Report'),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              Text('$_totalReports reports found', style: AppTypography.label),
              const SizedBox(height: 16),

              // Report list
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.textPrimary))
                    : _error != null
                        ? Center(child: Text('Error: $_error', style: AppTypography.bodyMedium))
                        : _reports.isEmpty
                            ? EmptyState(
                                icon: Icons.description_outlined,
                                title: 'No reports found',
                                subtitle: 'Try adjusting your filters or create a new report',
                                action: ElevatedButton(
                                  onPressed: () => context.push('/reports/new').then((_) => _load()),
                                  child: const Text('Create New Report'),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: ListView.separated(
                                  itemCount: _reports.length,
                                  separatorBuilder: (_, __) => const Divider(),
                                  itemBuilder: (context, i) {
                                    final r = _reports[i];
                                    final completion = r.completionPercentage;
                                    return ListTile(
                                      contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 12),
                                      onTap: () => context.go('/reports/${r.reportId}'),
                                      leading: isMobile ? null : Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.accent.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.description_rounded, color: AppColors.textPrimary, size: 24),
                                      ),
                                      title: Wrap(
                                        spacing: 8,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          ReferenceChip(referenceNumber: r.referenceNumber, fontSize: 11),
                                          Text(r.reportTitle, style: AppTypography.subheading, overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 6),
                                          Text('${r.bankName ?? '—'} • ${r.vendorName ?? ''}', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: LinearProgressIndicator(
                                                    value: completion / 100,
                                                    backgroundColor: AppColors.border,
                                                    valueColor: AlwaysStoppedAnimation(completion == 100 ? AppColors.secondary : AppColors.primary),
                                                    minHeight: 4,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text('$completion%', style: AppTypography.label.copyWith(fontSize: 10)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: isMobile ? null : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              StatusChip(status: r.reportStatus),
                                              const SizedBox(height: 6),
                                              Text(r.createdAt != null ? DateFormat('dd MMM yyyy').format(r.createdAt!) : '—', style: AppTypography.label.copyWith(fontSize: 10)),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed: () => _deleteReport(r),
                                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
