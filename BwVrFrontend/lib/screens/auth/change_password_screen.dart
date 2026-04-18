import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _hideCurrentPwd = true;
  bool _hideNewPwd = true;
  bool _hideConfirmPwd = true;

  @override
  void dispose() {
    _currentPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      // Call the change-password endpoint
      final authService = AuthService();
      final token = authService.token;
      if (token == null) throw Exception('Not authenticated');

      final dio = authService.createAuthenticatedDio();
      final response = await dio.post('/auth/change-password', data: {
        'currentPassword': _currentPwdCtrl.text,
        'newPassword': _newPwdCtrl.text,
      });

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully!'), backgroundColor: AppTheme.success),
          );
          context.go('/');
        }
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to change password');
      }
    } on DioException catch (e) {
      final serverData = e.response?.data;
      String msg = 'Request failed. Please check your inputs.';
      if (serverData is Map) {
        msg = serverData['error'] ?? serverData['message'] ?? msg;
      }
      setState(() => _error = msg);
    } catch (e) {
      String msg = e.toString().replaceAll('Exception: ', '');
      // Strip raw DioException noise from the message
      if (msg.contains('DioException') || msg.contains('status code')) {
        msg = 'Request failed. Please try again.';
      }
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.warning.withOpacity(0.4)),
                ),
                child: const Icon(Icons.key_rounded, color: AppTheme.warning, size: 30),
              ),
              const SizedBox(height: 20),
              const Text('Change Your Password',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('You must change your password before proceeding.',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Container(
                width: 380,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.danger.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                          ),
                          child: Text(_error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildPwdField('Current Password', _currentPwdCtrl, _hideCurrentPwd,
                          () => setState(() => _hideCurrentPwd = !_hideCurrentPwd)),
                      const SizedBox(height: 16),
                      _buildPwdField('New Password', _newPwdCtrl, _hideNewPwd,
                          () => setState(() => _hideNewPwd = !_hideNewPwd),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v.length < 6) return 'Minimum 6 characters';
                            return null;
                          }),
                      const SizedBox(height: 16),
                      _buildPwdField('Confirm New Password', _confirmPwdCtrl, _hideConfirmPwd,
                          () => setState(() => _hideConfirmPwd = !_hideConfirmPwd),
                          validator: (v) => v != _newPwdCtrl.text ? 'Passwords do not match' : null),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _loading
                              ? const SizedBox(width: 18, height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPwdField(String label, TextEditingController ctrl, bool hide, VoidCallback toggle,
      {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: hide,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            hintText: label,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.12))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.12))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.accent, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.danger)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            suffixIcon: IconButton(
              icon: Icon(hide ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.white38, size: 18),
              onPressed: toggle,
            ),
          ),
          validator: validator ?? (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }
}
