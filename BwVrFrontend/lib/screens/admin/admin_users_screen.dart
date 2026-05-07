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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
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

<<<<<<< HEAD
  Future<void> _toggleRole(int userId, String currentRole) async {
    final newRole = currentRole == 'ADMIN' ? 'USER' : 'ADMIN';
    try {
      await _api.updateUserRole(userId, newRole);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User role updated to $newRole")));
=======
  Future<void> _updateRole(int userId, String role) async {
    try {
      await _api.updateUserRole(userId, role);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User role updated to $role")));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    }
  }

  Future<void> _updateValidator(int userId, String validatorUsername) async {
    try {
      await _api.updateUserValidator(userId, validatorUsername);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Validator updated")));
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
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
<<<<<<< HEAD
=======
    final validatorController = TextEditingController();
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
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
<<<<<<< HEAD
=======
                    DropdownMenuItem(value: 'VALIDATOR', child: Text('Validator')),
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
                    DropdownMenuItem(value: 'ADMIN', child: Text('Administrator')),
                  ],
                  onChanged: (v) => setDialogState(() => role = v ?? 'USER'),
                ),
<<<<<<< HEAD
=======
                if (role == 'USER') ...[
                  const SizedBox(height: 16),
                  Text('Assigned Validator (Username)', style: AppTypography.label),
                  const SizedBox(height: 8),
                  TextField(controller: validatorController, decoration: const InputDecoration(hintText: 'validator@example.com')),
                ],
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
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
<<<<<<< HEAD
=======
        // We'd also need to set the validator if provided. Since our addAdminUser doesn't accept it, we'll do an update.
        if (role == 'USER' && validatorController.text.trim().isNotEmpty) {
          final users = await _api.getAdminUsers();
          final newUser = users.firstWhere((usr) => usr['username'] == emailController.text.trim());
          await _api.updateUserValidator(newUser['id'], validatorController.text.trim());
        }
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
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
      title: 'Directory',
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
                            Text('Access Control', style: AppTypography.heading2),
                            Text('Manage accounts and system permissions', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _addUser,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add User'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
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
                            : LayoutBuilder(builder: (context, box) {
                                if (box.maxWidth < 800) {
                                  return ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _users.length,
                                    itemBuilder: (context, i) {
                                      final user = _users[i];
                                      final id = user['id'] as int;
                                      final username = user['username'] as String;
                                      final fullName = user['fullName'] as String?;
                                      final role = user['role'] as String;
                                      final status = user['status'] as String;

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(fullName ?? 'No Name', style: AppTypography.subheading),
                                                      Text(username, style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
<<<<<<< HEAD
=======
                                                      if (role == 'USER') 
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 4.0),
                                                          child: _validatorEditor(id, user['validatorUsername'] as String?),
                                                        ),
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
                                                    ],
                                                  ),
                                                ),
                                                _statusTag(status),
                                              ],
                                            ),
                                            const Divider(height: 24),
                                            Row(
                                              children: [
                                                _roleDropdown(id, role),
                                                const Spacer(),
                                                _actionButtons(id, username, role, status),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                                return SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: DataTable(
                                        headingRowColor: MaterialStateProperty.all(AppColors.background),
                                        dataRowMaxHeight: 70,
                                        columns: [
                                          DataColumn(label: Text('USER', style: AppTypography.label.copyWith(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('ROLE', style: AppTypography.label.copyWith(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('STATUS', style: AppTypography.label.copyWith(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('ACTIONS', style: AppTypography.label.copyWith(fontWeight: FontWeight.bold))),
                                        ],
<<<<<<< HEAD
                                        rows: _users.map((u) {
                                          final id = u['id'] as int;
                                          final username = u['username'] as String;
                                          final fullName = u['fullName'] as String?;
                                          final role = u['role'] as String;
                                          final status = u['status'] as String;
=======
                                        rows: _users.map((user) {
                                          final id = user['id'] as int;
                                          final username = user['username'] as String;
                                          final fullName = user['fullName'] as String?;
                                          final role = user['role'] as String;
                                          final status = user['status'] as String;
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238

                                          return DataRow(cells: [
                                            DataCell(
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(fullName ?? 'No Name', style: AppTypography.subheading.copyWith(fontSize: 14)),
                                                  Text(username, style: AppTypography.label.copyWith(fontSize: 11)),
<<<<<<< HEAD
=======
                                                  if (role == 'USER') 
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 2.0),
                                                      child: _validatorEditor(id, user['validatorUsername'] as String?),
                                                    ),
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
                                                ],
                                              ),
                                            ),
                                            DataCell(_roleDropdown(id, role)),
                                            DataCell(_statusTag(status)),
                                            DataCell(_actionButtons(id, username, role, status)),
                                          ]);
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
      ),
    );
  }

  Widget _roleDropdown(int id, String currentRole) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: currentRole == 'ADMIN' ? AppColors.primary.withOpacity(0.1) : AppColors.structural,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: currentRole == 'ADMIN' ? AppColors.primary.withOpacity(0.2) : AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentRole,
          icon: Icon(Icons.arrow_drop_down, color: currentRole == 'ADMIN' ? AppColors.primary : AppColors.textSecondary, size: 16),
          style: AppTypography.label.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: currentRole == 'ADMIN' ? AppColors.primary : AppColors.textPrimary,
          ),
          onChanged: (String? newRole) {
            if (newRole != null && newRole != currentRole) {
<<<<<<< HEAD
              _toggleRole(id, currentRole); // _toggleRole just flips the role in backend
=======
              _updateRole(id, newRole);
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
            }
          },
          items: const [
            DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
<<<<<<< HEAD
=======
            DropdownMenuItem(value: 'VALIDATOR', child: Text('VALIDATOR')),
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
            DropdownMenuItem(value: 'USER', child: Text('USER')),
          ],
        ),
      ),
    );
  }

  Widget _statusTag(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'APPROVED' ? const Color(0xFFDCFCE7) : status == 'PENDING' ? const Color(0xFFFEF9C3) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(status, style: AppTypography.label.copyWith(fontSize: 10, color: status == 'APPROVED' ? const Color(0xFF166534) : status == 'PENDING' ? const Color(0xFF854D0E) : const Color(0xFF991B1B))),
    );
  }

<<<<<<< HEAD
=======
  Widget _validatorEditor(int userId, String? currentValidator) {
    return InkWell(
      onTap: () async {
        final ctrl = TextEditingController(text: currentValidator);
        final result = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Assign Validator'),
            content: TextField(
              controller: ctrl,
              decoration: const InputDecoration(hintText: 'validator@example.com'),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                child: const Text('Save'),
              ),
            ],
          ),
        );
        if (result != null) {
          _updateValidator(userId, result);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            currentValidator?.isNotEmpty == true ? currentValidator! : 'Unassigned',
            style: AppTypography.bodySmall.copyWith(
              color: currentValidator?.isNotEmpty == true ? AppColors.primary : AppColors.textSecondary,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
  Widget _actionButtons(int id, String username, String role, String status) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
      tooltip: 'Actions',
      onSelected: (value) {
        switch (value) {
          case 'approve':
            _approveUser(id, username);
            break;
          case 'reject':
            _rejectUser(id, username);
            break;
          case 'password':
            _changePassword(id, username);
            break;
          case 'delete':
            _deleteUser(id, username);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (status == 'PENDING') ...[
          const PopupMenuItem<String>(
            value: 'approve',
            child: ListTile(
              leading: Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 20),
              title: Text('Approve User'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          const PopupMenuItem<String>(
            value: 'reject',
            child: ListTile(
              leading: Icon(Icons.highlight_off_rounded, color: AppColors.error, size: 20),
              title: Text('Reject User'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          const PopupMenuDivider(),
        ],
        const PopupMenuItem<String>(
          value: 'password',
          child: ListTile(
            leading: Icon(Icons.lock_reset_rounded, color: Colors.indigo, size: 20),
            title: Text('Change Password'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
            title: Text('Delete User', style: TextStyle(color: Color(0xFFEF4444))),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }
}
