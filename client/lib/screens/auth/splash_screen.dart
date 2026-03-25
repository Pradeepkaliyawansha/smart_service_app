import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final auth = ref.read(authProvider);
    if (auth.isLoading) {
      // Wait a bit more
      await Future.delayed(const Duration(milliseconds: 1500));
    }
    if (!mounted) return;
    final authFinal = ref.read(authProvider);
    if (authFinal.isAuthenticated) {
      context.go(authFinal.isAdmin ? '/admin' : '/home');
    } else {
      context.go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: AppTheme.background,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: const Text(
                'PackageBuilder',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: const Text(
                'Build smart. Price right.',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 60),
            FadeIn(
              delay: const Duration(milliseconds: 800),
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.primary.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
