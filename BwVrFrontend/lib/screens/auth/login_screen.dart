import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
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
        _errorMessage =
            e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Stack(
        children: [
          // Decorative gradient blobs
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.accent.withOpacity(0.35),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.25),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // Center content
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo / Brand
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.accent, const Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withOpacity(0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.shield_rounded,
                            color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'BwVr Report System',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Card
                      Container(
                        width: 400,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.12)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Error banner
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.danger.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color:
                                            AppTheme.danger.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded,
                                          color: AppTheme.danger, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(_errorMessage!,
                                            style: const TextStyle(
                                                color: AppTheme.danger,
                                                fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // Username
                              _Label('Username'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _usernameController,
                                autofocus: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(
                                  hint: 'Enter your username',
                                  icon: Icons.person_outline_rounded,
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Username is required'
                                    : null,
                                onFieldSubmitted: (_) => _login(),
                              ),
                              const SizedBox(height: 20),

                              // Password
                              _Label('Password'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(
                                  hint: 'Enter your password',
                                  icon: Icons.lock_outline_rounded,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.white38,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Password is required'
                                        : null,
                                onFieldSubmitted: (_) => _login(),
                              ),
                              const SizedBox(height: 28),

                              // Login button
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accent,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        AppTheme.accent.withOpacity(0.5),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5),
                                        )
                                      : const Text('Sign In',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign up link
                      TextButton(
                        onPressed: () => context.go('/signup'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor: Colors.white.withOpacity(0.06),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_add_outlined,
                                size: 16, color: Colors.white60),
                            const SizedBox(width: 8),
                            Text(
                              'New user? Sign up',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '© 2026 BwVr Report Management',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white38, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.danger),
      ),
      errorStyle: const TextStyle(color: AppTheme.danger),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      );
}
