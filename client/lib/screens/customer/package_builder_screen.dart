import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/app_theme.dart';
import '../../models/service_model.dart';
import '../../providers/package_builder_provider.dart';
import '../../widgets/addon_card.dart';
import '../../widgets/price_breakdown_card.dart';
import '../../widgets/recommendation_banner.dart';

class PackageBuilderScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final ServiceModel? service;

  const PackageBuilderScreen({
    super.key,
    required this.serviceId,
    this.service,
  });

  @override
  ConsumerState<PackageBuilderScreen> createState() =>
      _PackageBuilderScreenState();
}

class _PackageBuilderScreenState extends ConsumerState<PackageBuilderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.service != null) {
        ref.read(packageBuilderProvider.notifier).setService(widget.service!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packageBuilderProvider);
    final service = state.service ?? widget.service;

    if (service == null) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppTheme.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${service.categoryIcon} ${_capitalize(service.category)}',
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Save button
                  GestureDetector(
                    onTap: () => _showSaveDialog(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: const Icon(
                        Icons.bookmark_add_outlined,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Body ────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recommendation banner
                    if (state.pricing?.recommendation != null)
                      FadeInDown(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RecommendationBanner(
                            message: state.pricing!.recommendation!,
                            isBestValue: state.pricing!.isBestValue,
                            isMostPopular: state.pricing!.isMostPopular,
                          ),
                        ),
                      ),

                    // ─── Duration Slider ──────────────────────────────────────
                    FadeInLeft(
                      child: _SectionHeader(
                        icon: '⏱️',
                        title: 'Duration',
                        subtitle: '${state.durationHours}h selected',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeInLeft(
                      delay: const Duration(milliseconds: 50),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${service.minHours}h',
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontFamily: 'DMSans',
                                    fontSize: 12,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${state.durationHours} hours',
                                    style: const TextStyle(
                                      fontFamily: 'Syne',
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${service.maxHours}h',
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontFamily: 'DMSans',
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: state.durationHours.toDouble(),
                              min: service.minHours.toDouble(),
                              max: service.maxHours.toDouble(),
                              divisions: service.maxHours - service.minHours,
                              label: '${state.durationHours}h',
                              onChanged: (v) => ref
                                  .read(packageBuilderProvider.notifier)
                                  .setDuration(v.round()),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Base cost',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontFamily: 'DMSans',
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Rs. ${(service.basePrice + service.pricePerHour * state.durationHours).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontFamily: 'Syne',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ─── Add-ons ──────────────────────────────────────────────
                    const SizedBox(height: 24),
                    FadeInLeft(
                      delay: const Duration(milliseconds: 100),
                      child: _SectionHeader(
                        icon: '⚡',
                        title: 'Add-ons',
                        subtitle:
                            '${state.selectedAddonIds.length} selected'
                            '${state.selectedAddonIds.length >= 3 ? ' — discount applied!' : ''}',
                        accentSubtitle: state.selectedAddonIds.length >= 3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.availableAddons.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: const Center(
                          child: Text(
                            'No add-ons available for this service',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontFamily: 'DMSans',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(state.availableAddons.length, (i) {
                        final addon = state.availableAddons[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: FadeInUp(
                            delay: Duration(milliseconds: i * 60),
                            child: AddonCard(
                              addon: addon,
                              isSelected: state.isAddonSelected(addon.id),
                              onToggle: () => ref
                                  .read(packageBuilderProvider.notifier)
                                  .toggleAddon(addon.id),
                            ),
                          ),
                        );
                      }),

                    // ─── Discount hint ─────────────────────────────────────
                    if (state.selectedAddonIds.length < 3 &&
                        state.availableAddons.length >= 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppTheme.textMuted,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Select ${3 - state.selectedAddonIds.length} more add-on(s) for 10% off',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontFamily: 'DMSans',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ─── Price Breakdown ───────────────────────────────────
                    const SizedBox(height: 24),
                    if (state.pricing != null)
                      FadeInUp(
                        child: PriceBreakdownCard(pricing: state.pricing!),
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // ─── Bottom CTA ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: AppTheme.background,
                border: Border(top: BorderSide(color: AppTheme.divider)),
              ),
              child: Row(
                children: [
                  // Price display
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (state.pricing != null) ...[
                          Text(
                            'Rs. ${state.pricing!.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          if (state.pricing!.hasDiscount)
                            Text(
                              'Rs. ${state.pricing!.subtotal.toStringAsFixed(0)} saved ${(state.pricing!.discountRate * 100).toInt()}%',
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 11,
                                color: AppTheme.success,
                                decoration: TextDecoration.none,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),

                  // Book button
                  GestureDetector(
                    onTap: () {
                      if (state.pricing == null) return;
                      context.push(
                        '/package-summary',
                        extra: {
                          'service': service,
                          'selectedAddons': state.selectedAddons,
                          'durationHours': state.durationHours,
                          'pricing': state.pricing,
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Book Now →',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.background,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaveDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController(
      text: '${widget.service?.name ?? ''} Package',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Save Package',
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Give your package a name to save it for later.',
              style: TextStyle(
                fontFamily: 'DMSans',
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontFamily: 'DMSans',
              ),
              decoration: InputDecoration(
                hintText: 'Package name',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.divider),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(packageBuilderProvider.notifier)
                  .savePackage(ctrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Package saved! ✅')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text(
              'Save',
              style: TextStyle(color: AppTheme.background),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _SectionHeader extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool accentSubtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.accentSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Syne',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            color: accentSubtitle ? AppTheme.success : AppTheme.textMuted,
            fontWeight: accentSubtitle ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
