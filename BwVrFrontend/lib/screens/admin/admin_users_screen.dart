import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
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
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<void> _approve(Map<String, dynamic> user) async {
    try {
      await _api.approveUser(user['id'] as int);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User '${user['username']}' approved."),
        backgroundColor: AppColors.textPrimary,
      ));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Future<void> _reject(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reject User', style: AppTypography.heading3),
        content: Text("Reject '${user['username']}' permanently?", style: AppTypography.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject'),
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
        backgroundColor: AppColors.textPrimary,
      ));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete User', style: AppTypography.heading3),
        content: Text("Are you sure you want to delete '${user['username']}'? This action cannot be undone.", style: AppTypography.bodyMedium),
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
    if (confirmed != true) return;
    try {
      await _api.deleteUser(user['id'] as int);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User '${user['username']}' deleted."),
        backgroundColor: AppColors.textPrimary,
      ));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Future<void> _showCreateUserDialog() async {
    final usernameCtrl = TextEditingController();
    final fullNameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String role = 'USER';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInternalState) => AlertDialog(
          title: Text('Create New User', style: AppTypography.heading3),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Username', hintText: 'e.g. jdoe'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: fullNameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name', hintText: 'e.g. John Doe'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'USER', child: Text('USER')),
                    DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                  ],
                  onChanged: (v) => setInternalState(() => role = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        await _api.createAdminUser(
          username: usernameCtrl.text.trim(),
          password: passwordCtrl.text,
          fullName: fullNameCtrl.text.trim(),
          role: role,
        );
        _load();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/admin/users',
      title: 'User Management',
      trailing: ElevatedButton.icon(
        onPressed: _showCreateUserDialog,
        icon: const Icon(Icons.person_add_rounded, size: 18),
        label: const Text('Add User'),
      ),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pending Approvals'),
                      if (_pendingUsers.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '${_pendingUsers.length}',
                            style: AppTypography.label.copyWith(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
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
                            emptySubtitle: 'All requests have been reviewed.',
                            onApprove: _approve,
                            onReject: _reject,
                          ),
                          _UserList(
                            users: _allUsers,
                            showActions: false,
                            canDelete: true,
                            emptyTitle: 'No users yet',
                            emptySubtitle: 'Registered users appear here.',
                            onApprove: _approve,
                            onReject: _reject,
                            onDelete: _deleteUser,
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
  final bool canDelete;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function(Map<String, dynamic>) onApprove;
  final Future<void> Function(Map<String, dynamic>) onReject;
  final Future<void> Function(Map<String, dynamic>)? onDelete;

  const _UserList({
    required this.users,
    required this.showActions,
    this.canDelete = false,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onApprove,
    required this.onReject,
    this.onDelete,
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
      padding: const EdgeInsets.all(32),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, i) {
        final user = users[i];
        final status = user['status'] as String? ?? 'PENDING';
        final role = user['role'] as String? ?? 'USER';
        final username = user['username'] as String? ?? '';
        final fullName = user['fullName'] as String?;
        final createdAt = user['createdAt'] as String?;

        Color statusBg;
        switch (status) {
          case 'APPROVED': statusBg = AppColors.secondary; break;
          case 'REJECTED': statusBg = AppColors.error; break;
          default: statusBg = AppColors.primary;
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: role == 'ADMIN' ? AppColors.accent : AppColors.primary,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                  style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(fullName ?? username, style: AppTypography.subheading),
                        const SizedBox(width: 12),
                        if (role == 'ADMIN')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text('ADMIN', style: AppTypography.label.copyWith(fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('@$username', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    if (createdAt != null)
                      Text('Since ${createdAt.split('T').first}', style: AppTypography.label.copyWith(fontSize: 10)),
                  ],
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(status.toUpperCase(), style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ),

              if (showActions && status == 'PENDING') ...[
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => onApprove(user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Approve'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => onReject(user),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Reject'),
                ),
              ],
              if (canDelete) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => onDelete?.call(user),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  tooltip: 'Delete User',
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
