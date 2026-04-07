import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/common_widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  late TabController _tabController;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _pendingUsers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final all = await _api.getAdminUsers();
      final pending = await _api.getPendingUsers();
      setState(() {
        _allUsers = all;
        _pendingUsers = pending;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _approve(Map<String, dynamic> user) async {
    try {
      await _api.approveUser(user['id'] as int);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User '${user['username']}' approved."),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _reject(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject User'),
        content: Text(
            "Are you sure you want to reject '${user['username']}'? They will not be able to login."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Reject',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.rejectUser(user['id'] as int);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User '${user['username']}' rejected."),
        backgroundColor: AppTheme.warning,
        behavior: SnackBarBehavior.floating,
      ));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/admin/users',
      title: 'User Management',
      child: Column(
        children: [
          // Tab bar
          Container(
            color: AppTheme.cardBg,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.accent,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.accent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pending Approvals'),
                      if (_pendingUsers.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.danger,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_pendingUsers.length}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'All Users'),
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppTheme.danger, size: 48),
                            const SizedBox(height: 12),
                            Text(_error!,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary)),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _load,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _UserList(
                            users: _pendingUsers,
                            showActions: true,
                            emptyTitle: 'No pending approvals',
                            emptySubtitle:
                                'All signup requests have been reviewed.',
                            onApprove: _approve,
                            onReject: _reject,
                          ),
                          _UserList(
                            users: _allUsers,
                            showActions: false,
                            emptyTitle: 'No users yet',
                            emptySubtitle: 'Users will appear here after signup.',
                            onApprove: _approve,
                            onReject: _reject,
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final bool showActions;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function(Map<String, dynamic>) onApprove;
  final Future<void> Function(Map<String, dynamic>) onReject;

  const _UserList({
    required this.users,
    required this.showActions,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final user = users[i];
        final status = user['status'] as String? ?? 'PENDING';
        final role = user['role'] as String? ?? 'USER';
        final username = user['username'] as String? ?? '';
        final fullName = user['fullName'] as String?;
        final createdAt = user['createdAt'] as String?;

        Color statusColor;
        IconData statusIcon;
        switch (status) {
          case 'APPROVED':
            statusColor = AppTheme.success;
            statusIcon = Icons.check_circle_rounded;
            break;
          case 'REJECTED':
            statusColor = AppTheme.danger;
            statusIcon = Icons.cancel_rounded;
            break;
          default:
            statusColor = AppTheme.warning;
            statusIcon = Icons.pending_rounded;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    role == 'ADMIN' ? const Color(0xFF8B5CF6) : AppTheme.accent,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          fullName ?? username,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary),
                        ),
                        const SizedBox(width: 8),
                        if (role == 'ADMIN')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF8B5CF6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('ADMIN',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF8B5CF6))),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('@$username',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                    if (createdAt != null)
                      Text(
                        'Registered: ${createdAt.split('T').first}',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary),
                      ),
                  ],
                ),
              ),

              // Status chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(status,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor)),
                  ],
                ),
              ),

              // Actions for pending
              if (showActions && status == 'PENDING') ...[
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => onApprove(user),
                  icon: const Icon(Icons.check_rounded, size: 14),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => onReject(user),
                  icon: const Icon(Icons.close_rounded, size: 14),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.danger,
                    side:
                        BorderSide(color: AppTheme.danger.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
