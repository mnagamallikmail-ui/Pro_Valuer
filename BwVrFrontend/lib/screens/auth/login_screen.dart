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

class _LoginScreenState extends State<LoginScreen> {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 900;

          if (isDesktop) {
            return Row(
              children: [
                // Left Panel: Branding
                Expanded(
                  flex: 1,
                  child: _BrandingPanel(),
                ),
                // Right Panel: Login Form
                Expanded(
                  flex: 1,
                  child: _LoginFormPanel(
                    formKey: _formKey,
                    usernameController: _usernameController,
                    passwordController: _passwordController,
                    obscurePassword: _obscurePassword,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                    onLogin: _login,
                  ),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  children: [
                    _BrandingPanel(isMobile: true),
                    _LoginFormPanel(
                      isMobile: true,
                      formKey: _formKey,
                      usernameController: _usernameController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      isLoading: _isLoading,
                      errorMessage: _errorMessage,
                      onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                      onLogin: _login,
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _BrandingPanel extends StatelessWidget {
  final bool isMobile;
  const _BrandingPanel({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.structural,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isMobile) const SizedBox(height: 60),
            Image.asset(
              'assets/images/logo.png',
              height: isMobile ? 60 : 80,
            ),
            const SizedBox(height: 24),
            Text(
              'Professional Valuation Company, Chartered Engineers, Lenders Independent Engineers',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            if (isMobile) const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _LoginFormPanel extends StatelessWidget {
  final bool isMobile;
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  const _LoginFormPanel({
    this.isMobile = false,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    this.errorMessage,
    required this.onTogglePassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sign In',
                    style: AppTypography.heading2.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Access your valuer dashboard',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  
                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.error, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text('Username', style: AppTypography.label),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your username',
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Username is required'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  Text('Password', style: AppTypography.label),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: onTogglePassword,
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Password is required'
                        : null,
                    onFieldSubmitted: (_) => onLogin(),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                          : const Text('Login to Account', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Need an account?',
                        style: AppTypography.bodyMedium.copyWith(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () => context.go('/signup'),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
