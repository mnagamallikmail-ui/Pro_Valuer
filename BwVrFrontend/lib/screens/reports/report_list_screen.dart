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

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/reports',
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Toolbar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.bodyLarge,
                      decoration: const InputDecoration(
                        filled: false,
                        hintText: 'Filter by vendor, location or reference...',
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryText),
                      ),
                      onChanged: (_) {
                        _currentPage = 0;
                        _load();
                      },
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      style: AppTypography.bodyMedium,
                      decoration: const InputDecoration(filled: false, labelText: 'Report Status'),
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
                  const SizedBox(width: 32),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/reports/new').then((_) => _load()),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('New Valuation'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Row(
              children: [
                Text('$_totalReports Valuations Found', style: AppTypography.heading3.copyWith(fontSize: 16)),
                const Spacer(),
                Text('Showing Page ${_currentPage + 1}', style: AppTypography.label),
              ],
            ),
            const SizedBox(height: 24),

            // Records List
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryText))
                  : _error != null
                      ? Center(child: Text('Data fetch failed: $_error', style: AppTypography.bodyMedium))
                      : _reports.isEmpty
                          ? const EmptyState(
                              icon: Icons.search_off_rounded,
                              title: 'No Matches Found',
                              subtitle: 'Adjust your search parameters to find the records.',
                            )
                          : ListView.builder(
                              itemCount: _reports.length,
                              itemBuilder: (context, i) {
                                final r = _reports[i];
                                return _ReportListItem(report: r, onTap: () => context.go('/reports/${r.reportId}'));
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

  const _ReportListItem({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final completion = report.completionPercentage;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.description_rounded, color: AppColors.primaryText, size: 24),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(report.reportTitle, style: AppTypography.heading3.copyWith(fontSize: 16)),
                        const SizedBox(width: 12),
                        ReferenceChip(label: report.referenceNumber),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${report.bankName ?? 'Unknown FI'} • ${report.location ?? 'Global'}', 
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.accent)),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('COMPLETION', style: AppTypography.label.copyWith(fontSize: 9)),
                        Text('$completion%', style: AppTypography.label.copyWith(fontSize: 9, color: AppColors.primaryText)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: completion / 100,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation(completion == 100 ? AppColors.success : AppColors.primary),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(status: report.reportStatus),
                  const SizedBox(height: 6),
                  Text(report.createdAt != null ? DateFormat('MMMM dd, yyyy').format(report.createdAt!) : '', 
                    style: AppTypography.label.copyWith(fontSize: 10)),
                ],
              ),
              const SizedBox(width: 24),
              const Icon(Icons.chevron_right_rounded, color: AppColors.border),
            ],
          ),
        ),
      ),
    );
  }
}
