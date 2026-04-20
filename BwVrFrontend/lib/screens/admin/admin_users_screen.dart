import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/common_widgets.dart';
import '../../services/auth_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _users = [];
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
      final all = await _api.getAdminUsers();
      setState(() {
        _users = all;
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

  Future<void> _deleteUser(int userId, String username) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete User', style: AppTypography.heading3),
        content: Text("Are you sure you want to delete user '$username'? This action cannot be undone.", style: AppTypography.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _api.deleteUser(userId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted successfully')));
        _load();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _approveUser(int userId, String username) async {
    try {
      await _api.approveUser(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User '$username' approved successfully")));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    }
  }

  Future<void> _rejectUser(int userId, String username) async {
    try {
      await _api.rejectUser(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User '$username' rejected")));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    }
  }

  Future<void> _toggleRole(int userId, String currentRole) async {
    final newRole = currentRole == 'ADMIN' ? 'USER' : 'ADMIN';
    try {
      await _api.updateUserRole(userId, newRole);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User role updated to $newRole")));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    }
  }

  Future<void> _changePassword(int userId, String username) async {
    final passwordController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset Password', style: AppTypography.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Set new password for '$username'", style: AppTypography.label),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'New Password', hintText: 'Min 6 characters'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );

    if (result == true && passwordController.text.isNotEmpty) {
      try {
        await _api.updateUserPassword(userId, passwordController.text);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _addUser() async {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    String role = 'USER';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Add New User', style: AppTypography.heading3),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Full Name', style: AppTypography.label),
                const SizedBox(height: 8),
                TextField(controller: nameController, decoration: const InputDecoration(hintText: 'John Doe')),
                const SizedBox(height: 16),
                Text('Email / Username', style: AppTypography.label),
                const SizedBox(height: 8),
                TextField(controller: emailController, decoration: const InputDecoration(hintText: 'john@example.com')),
                const SizedBox(height: 16),
                Text('Initial Password', style: AppTypography.label),
                const SizedBox(height: 8),
                TextField(controller: passwordController, decoration: const InputDecoration(hintText: 'Min 6 chars')),
                const SizedBox(height: 16),
                Text('Role', style: AppTypography.label),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'USER', child: Text('Standard User')),
                    DropdownMenuItem(value: 'ADMIN', child: Text('Administrator')),
                  ],
                  onChanged: (v) => setDialogState(() => role = v ?? 'USER'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        await _api.addAdminUser(
          email: emailController.text.trim(),
          fullName: nameController.text.trim(),
          password: passwordController.text,
          role: role,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User created successfully')));
        _load();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/admin/users',
      title: 'User Management',
      child: Container(
        color: Colors.white,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                children: [
                  // Toolbar
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('System Users', style: AppTypography.heading2),
                            Text('Manage accounts and access permissions', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _addUser,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add User'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Table
                  Expanded(
                    child: _error != null
                        ? Center(child: Text(_error!, style: AppTypography.bodyMedium.copyWith(color: AppColors.error)))
                        : _users.isEmpty
                            ? const EmptyState(icon: Icons.people_outline, title: 'No Users Found', subtitle: 'Start by adding a new user manually.')
                            : SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: DataTable(
                                      headingRowColor: MaterialStateProperty.all(AppColors.surface),
                                      dataRowMaxHeight: 70,
                                      columns: [
                                        DataColumn(label: Text('USER', style: AppTypography.label.copyWith(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('ROLE', style: AppTypography.label.copyWith(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('STATUS', style: AppTypography.label.copyWith(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('ACTIONS', style: AppTypography.label.copyWith(fontWeight: FontWeight.bold))),
                                      ],
                                      rows: _users.map((user) {
                                        final id = user['id'] as int;
                                        final username = user['username'] as String;
                                        final fullName = user['fullName'] as String?;
                                        final role = user['role'] as String;
                                        final status = user['status'] as String;

                                        return DataRow(cells: [
                                          DataCell(
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(fullName ?? 'No Name', style: AppTypography.subheading.copyWith(fontSize: 14)),
                                                Text(username, style: AppTypography.label.copyWith(fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: role == 'ADMIN' ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(role, style: AppTypography.label.copyWith(fontSize: 10, color: role == 'ADMIN' ? AppColors.primary : AppColors.textPrimary)),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: status == 'APPROVED' ? const Color(0xFFDCFCE7) : status == 'PENDING' ? const Color(0xFFFEF9C3) : const Color(0xFFFEE2E2),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(status, style: AppTypography.label.copyWith(fontSize: 10, color: status == 'APPROVED' ? const Color(0xFF166534) : status == 'PENDING' ? const Color(0xFF854D0E) : const Color(0xFF991B1B))),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              children: [
                                                if (status == 'PENDING') ...[
                                                  IconButton(
                                                    icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF059669), size: 20),
                                                    tooltip: 'Approve User',
                                                    onPressed: () => _approveUser(id, username),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.highlight_off_rounded, color: Color(0xFFE11D48), size: 20),
                                                    tooltip: 'Reject User',
                                                    onPressed: () => _rejectUser(id, username),
                                                  ),
                                                ],
                                                IconButton(
                                                  icon: Icon(role == 'ADMIN' ? Icons.shield_outlined : Icons.shield_rounded, 
                                                    color: role == 'ADMIN' ? Colors.orange : Colors.blue, size: 20),
                                                  tooltip: role == 'ADMIN' ? 'Demote to User' : 'Promote to Admin',
                                                  onPressed: () => _toggleRole(id, role),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.lock_reset_rounded, color: Colors.indigo, size: 20),
                                                  tooltip: 'Change Password',
                                                  onPressed: () => _changePassword(id, username),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF64748B), size: 20),
                                                  tooltip: 'Delete User',
                                                  onPressed: () => _deleteUser(id, username),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
      ),
    );
  }
}
