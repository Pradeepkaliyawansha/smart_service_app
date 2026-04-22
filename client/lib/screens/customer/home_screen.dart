import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/services_provider.dart';
import '../../widgets/service_card.dart';
import '../../widgets/shimmer_loader.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final servicesState = ref.watch(servicesProvider);
    final popular = ref.watch(popularServicesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: AppTheme.cardBg,
          onRefresh: () => ref
              .read(servicesProvider.notifier)
              .loadServices(forceRefresh: true),
          child: CustomScrollView(
            slivers: [
              // ─── Header ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: FadeInDown(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hey, ${auth.user?.name.split(' ').first ?? 'there'} 👋',
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Build your package',
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => ref.read(authProvider.notifier).logout(),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Hero Banner ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Smart Pricing\nEngine',
                                  style: TextStyle(
                                    fontFamily: 'Syne',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.background,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Bundle add-ons and get automatic discounts.',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 13,
                                    color: Color(0x99000000),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () => context.go('/services'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.background,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Browse Services →',
                                      style: TextStyle(
                                        fontFamily: 'Syne',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text('📦', style: TextStyle(fontSize: 56)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Offline Banner ───────────────────────────────────────────
              if (servicesState.isOffline)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.warning.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            color: AppTheme.warning,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Offline mode — showing cached data',
                            style: TextStyle(
                              color: AppTheme.warning,
                              fontFamily: 'DMSans',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ─── Popular Section ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Most Popular',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/services'),
                        child: const Text(
                          'See all →',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 13,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Popular Cards ────────────────────────────────────────────
              if (servicesState.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: ShimmerLoader(),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: popular.isEmpty
                        ? const Center(
                            child: Text(
                              'No services yet',
                              style: TextStyle(color: AppTheme.textMuted),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                            itemCount: popular.length,
                            itemBuilder: (ctx, i) => Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: FadeInRight(
                                delay: Duration(milliseconds: i * 100),
                                child: ServiceCard(
                                  service: popular[i],
                                  isCompact: true,
                                  onTap: () => context.push(
                                    '/package-builder/${popular[i].id}',
                                    extra: popular[i],
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),

              // ─── All Services ─────────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Text(
                    'All Services',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),

              if (servicesState.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: ShimmerLoader(count: 3),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((ctx, i) {
                      final service = servicesState.services[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FadeInUp(
                          delay: Duration(milliseconds: i * 80),
                          child: ServiceCard(
                            service: service,
                            onTap: () => context.push(
                              '/package-builder/${service.id}',
                              extra: service,
                            ),
                          ),
                        ),
                      );
                    }, childCount: servicesState.services.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
