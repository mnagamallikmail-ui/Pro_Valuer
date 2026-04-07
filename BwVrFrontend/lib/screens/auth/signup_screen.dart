import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
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
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final msg = await AuthService().signup(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
      );
      if (!mounted) return;
      // Show success and go back to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/login');
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
      backgroundColor: AppTheme.primary,
      body: Stack(
        children: [
          // Decorative background blobs
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.accent.withOpacity(0.3),
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
                  const Color(0xFF8B5CF6).withOpacity(0.2),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

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
                      // Logo
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.accent, const Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_add_rounded,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Request access to BwVr Report System',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Card
                      Container(
                        width: 420,
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
                                        color: AppTheme.danger.withOpacity(0.4)),
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

                              // Full Name (optional)
                              _Label('Full Name (optional)'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                autofocus: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(
                                  hint: 'Enter your full name',
                                  icon: Icons.badge_outlined,
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Username
                              _Label('Username *'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _usernameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(
                                  hint: 'Choose a username',
                                  icon: Icons.person_outline_rounded,
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Username is required';
                                  }
                                  if (v.trim().length < 3) {
                                    return 'Username must be at least 3 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),

                              // Password
                              _Label('Password *'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(
                                  hint: 'At least 6 characters',
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
                                    onPressed: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (v.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),

                              // Confirm Password
                              _Label('Confirm Password *'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirm,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(
                                  hint: 'Re-enter your password',
                                  icon: Icons.lock_reset_rounded,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirm
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.white38,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscureConfirm = !_obscureConfirm),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (v != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _signup(),
                              ),
                              const SizedBox(height: 28),

                              // Submit button
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _signup,
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
                                      : const Text('Submit Request',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700)),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Back to login
                              Center(
                                child: TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: Text(
                                    'Already have an account? Sign in',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'New accounts require admin approval before login.',
                              style: TextStyle(
                                color: Colors.amber.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
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
      hintStyle:
          TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
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
