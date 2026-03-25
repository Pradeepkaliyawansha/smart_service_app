import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/app_theme.dart';
import '../../providers/package_builder_provider.dart';
import '../../services/cache_service.dart';
import '../../models/price_calculation_model.dart';

class SavedPackagesScreen extends ConsumerWidget {
  const SavedPackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packages = ref.watch(savedPackagesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Text(
                'Saved Packages',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Text(
                'Compare your saved configurations',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: packages.isEmpty
                  ? const _EmptySaved()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: packages.length,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: FadeInUp(
                          delay: Duration(milliseconds: i * 60),
                          child: _SavedPackageCard(
                            package: packages[i],
                            onDelete: () async {
                              await CacheService.deletePackage(packages[i].id);
                              ref.invalidate(savedPackagesProvider);
                            },
                            onUse: () {
                              // Navigate to service and pre-fill
                              context.push(
                                '/package-builder/${packages[i].serviceId}',
                              );
                            },
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySaved extends StatelessWidget {
  const _EmptySaved();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔖', style: TextStyle(fontSize: 56)),
          SizedBox(height: 16),
          Text(
            'No saved packages',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Save packages from the builder to compare them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedPackageCard extends StatelessWidget {
  final SavedPackage package;
  final VoidCallback onDelete;
  final VoidCallback onUse;

  const _SavedPackageCard({
    required this.package,
    required this.onDelete,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  package.name,
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.error,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            package.serviceName,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _tag('${package.durationHours}h duration'),
              const SizedBox(width: 6),
              _tag('${package.addonIds.length} add-ons'),
              if (package.pricing.hasDiscount)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _tag(
                    '${(package.pricing.discountRate * 100).toInt()}% off',
                    isAccent: true,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs. ${package.pricing.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    if (package.pricing.hasDiscount)
                      Text(
                        'Saved Rs. ${package.pricing.discountAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 11,
                          color: AppTheme.success,
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onUse,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    'Use this →',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, {bool isAccent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAccent
            ? AppTheme.success.withOpacity(0.15)
            : AppTheme.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 11,
          color: isAccent ? AppTheme.success : AppTheme.textSecondary,
          fontWeight: isAccent ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
