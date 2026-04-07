import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/report_model.dart';
import '../../theme/app_theme.dart';
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
        search:
            _searchController.text.isNotEmpty ? _searchController.text : null,
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
        title: const Text('Delete Report Permanently?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text('Are you sure you want to permanently delete report ${r.referenceNumber} from the database? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search / filter bar
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText:
                          'Search by vendor, location, or reference number...',
                      prefixIcon: Icon(Icons.search_rounded, size: 18),
                      suffixIcon: Icon(Icons.close_rounded, size: 16),
                    ),
                    onChanged: (_) {
                      _currentPage = 0;
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(
                          value: null, child: Text('All Statuses')),
                      DropdownMenuItem(value: 'DRAFT', child: Text('Draft')),
                      DropdownMenuItem(
                          value: 'IN_PROGRESS', child: Text('In Progress')),
                      DropdownMenuItem(
                          value: 'COMPLETED', child: Text('Completed')),
                      DropdownMenuItem(
                          value: 'ARCHIVED', child: Text('Archived')),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedStatus = v);
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await context.push('/reports/new');
                    _load();
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('New Report'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('$_totalReports reports found',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),

            // Report list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : _reports.isEmpty
                          ? EmptyState(
                              icon: Icons.description_outlined,
                              title: 'No reports found',
                              subtitle:
                                  'Create a new report or adjust your search filters',
                              action: ElevatedButton(
                                onPressed: () async {
                                  await context.push('/reports/new');
                                  _load();
                                },
                                child: const Text('Create New Report'),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: AppTheme.cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: ListView.separated(
                                itemCount: _reports.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final r = _reports[i];
                                  final completion = r.completionPercentage;
                                  return InkWell(
                                    onTap: () =>
                                        context.go('/reports/${r.reportId}'),
                                    borderRadius: i == 0
                                        ? const BorderRadius.vertical(
                                            top: Radius.circular(12))
                                        : BorderRadius.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          // Status icon
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: AppTheme.chipBlue,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                                Icons.description_rounded,
                                                color: AppTheme.accent,
                                                size: 22),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    ReferenceChip(
                                                        referenceNumber:
                                                            r.referenceNumber,
                                                        fontSize: 11),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(r.reportTitle,
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Text(r.bankName ?? '—',
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppTheme
                                                                .textSecondary)),
                                                    if (r.vendorName !=
                                                        null) ...[
                                                      const Text(' • ',
                                                          style: TextStyle(
                                                              color: AppTheme
                                                                  .textSecondary)),
                                                      Text(r.vendorName!,
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              color: AppTheme
                                                                  .textSecondary)),
                                                    ],
                                                    if (r.location != null) ...[
                                                      const Text(' • ',
                                                          style: TextStyle(
                                                              color: AppTheme
                                                                  .textSecondary)),
                                                      const Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 12,
                                                          color: AppTheme
                                                              .textSecondary),
                                                      Text(r.location!,
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              color: AppTheme
                                                                  .textSecondary)),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                // Progress bar
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        child:
                                                            LinearProgressIndicator(
                                                          value:
                                                              completion / 100,
                                                          backgroundColor:
                                                              AppTheme.border,
                                                          valueColor:
                                                              AlwaysStoppedAnimation(
                                                                  completion ==
                                                                          100
                                                                      ? AppTheme
                                                                          .success
                                                                      : AppTheme
                                                                          .accent),
                                                          minHeight: 4,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text('$completion%',
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            color: AppTheme
                                                                .textSecondary)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              StatusChip(
                                                  status: r.reportStatus),
                                              const SizedBox(height: 6),
                                              Text(
                                                  r.createdAt != null
                                                      ? DateFormat('dd MMM yy')
                                                          .format(r.createdAt!)
                                                      : '—',
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppTheme
                                                          .textSecondary)),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed: () => _deleteReport(r),
                                            icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 18,
                                                color: AppTheme.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
