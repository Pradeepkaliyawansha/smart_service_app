import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/app_theme.dart';
import '../../providers/services_provider.dart';
import '../../widgets/service_card.dart';
import '../../widgets/shimmer_loader.dart';

const _categories = [
  'All',
  'photography',
  'videography',
  'aquaculture',
  'event',
  'custom',
];

class ServiceListScreen extends ConsumerWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(servicesProvider);
    final notifier = ref.read(servicesProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── AppBar ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: FadeInDown(
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Services',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    if (state.isOffline)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              color: AppTheme.warning,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Offline',
                              style: TextStyle(
                                color: AppTheme.warning,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '${state.filtered.length} services available',
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            // ─── Category Filter ─────────────────────────────────────────────
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _categories.length,
                itemBuilder: (ctx, i) {
                  final cat = _categories[i];
                  final isSelected =
                      (state.selectedCategory == null && cat == 'All') ||
                      state.selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          notifier.setCategory(cat == 'All' ? null : cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.divider,
                          ),
                        ),
                        child: Text(
                          cat == 'All' ? 'All' : _capitalize(cat),
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.background
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ─── List ────────────────────────────────────────────────────────
            const SizedBox(height: 16),
            Expanded(
              child: state.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: ShimmerLoader(count: 4),
                    )
                  : state.filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔍', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 16),
                          const Text(
                            'No services found',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different category',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppTheme.primary,
                      backgroundColor: AppTheme.cardBg,
                      onRefresh: () =>
                          notifier.loadServices(forceRefresh: true),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: state.filtered.length,
                        itemBuilder: (ctx, i) {
                          final service = state.filtered[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: FadeInUp(
                              delay: Duration(milliseconds: i * 60),
                              child: ServiceCard(
                                service: service,
                                onTap: () => context.push(
                                  '/package-builder/${service.id}',
                                  extra: service,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
