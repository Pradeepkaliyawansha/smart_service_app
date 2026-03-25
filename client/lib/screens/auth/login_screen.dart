import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (success && mounted) {
      final auth = ref.read(authProvider);
      context.go(auth.isAdmin ? '/admin' : '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // Logo
                FadeInDown(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: AppTheme.background,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                FadeInLeft(
                  delay: const Duration(milliseconds: 100),
                  child: const Text(
                    'Welcome\nback.',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInLeft(
                  delay: const Duration(milliseconds: 150),
                  child: const Text(
                    'Sign in to build your perfect package.',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Error
                if (auth.error != null)
                  FadeIn(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              auth.error!,
                              style: const TextStyle(
                                color: AppTheme.error,
                                fontFamily: 'DMSans',
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Email
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: AppTextField(
                    controller: _emailCtrl,
                    label: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                FadeInUp(
                  delay: const Duration(milliseconds: 250),
                  child: AppTextField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.textMuted,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Login button
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: AppButton(
                    label: 'Sign In',
                    isLoading: auth.isLoading,
                    onPressed: _login,
                    icon: Icons.arrow_forward_rounded,
                  ),
                ),
                const SizedBox(height: 24),

                // Register link
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => context.go('/auth/register'),
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontFamily: 'DMSans',
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Demo credentials
                const SizedBox(height: 40),
                FadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Demo Credentials',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppTheme.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _demoTile('Customer', 'user@demo.com', 'demo123'),
                        const SizedBox(height: 4),
                        _demoTile('Admin', 'admin@demo.com', 'demo123'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _demoTile(String role, String email, String pass) {
    return GestureDetector(
      onTap: () {
        _emailCtrl.text = email;
        _passwordCtrl.text = pass;
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              role,
              style: const TextStyle(
                fontFamily: 'Syne',
                fontSize: 11,
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$email / $pass',
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
