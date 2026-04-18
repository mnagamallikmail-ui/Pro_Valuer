import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final session = await AuthService().login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      if (session.mustChangePassword) {
        context.go('/change-password');
      } else {
        context.go('/');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    final infoSection = Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(isMobile ? 32 : 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryText,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 32),
          Text('BwVr', style: AppTypography.heading1.copyWith(fontSize: 48, color: AppColors.primaryText)),
          const SizedBox(height: 16),
          Text(
            'Precision Valuation & Reporting System',
            style: AppTypography.heading3.copyWith(color: AppColors.primaryText.withOpacity(0.8)),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          _InfoItem(icon: Icons.check_circle_outline_rounded, text: 'Real-time property data syncing'),
          _InfoItem(icon: Icons.check_circle_outline_rounded, text: 'Automated document generation'),
          _InfoItem(icon: Icons.check_circle_outline_rounded, text: 'Secure multi-role management'),
        ],
      ),
    );

    final formSection = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 24 : 40),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Welcome Back', style: AppTypography.heading2),
                const SizedBox(height: 8),
                Text('Please sign in to your account', 
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.accent)),
                const SizedBox(height: 48),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_errorMessage!, style: AppTypography.bodyMedium.copyWith(color: AppColors.error))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                Text('Username', style: AppTypography.label.copyWith(color: AppColors.primaryText)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  style: AppTypography.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Enter your ID',
                    prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                  ),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Username required' : null,
                ),
                const SizedBox(height: 24),

                Text('Password', style: AppTypography.label.copyWith(color: AppColors.primaryText)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: AppTypography.bodyLarge,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Password required' : null,
                  onFieldSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 48),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Access Dashboard'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account?', style: AppTypography.bodyMedium),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: Text('Register', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isMobile 
        ? SingleChildScrollView(child: Column(children: [infoSection, formSection]))
        : Row(children: [Expanded(flex: 4, child: infoSection), Expanded(flex: 5, child: formSection)]),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryText, size: 24),
          const SizedBox(width: 16),
          Text(text, style: AppTypography.bodyLarge.copyWith(color: AppColors.primaryText)),
        ],
      ),
    );
  }
}
