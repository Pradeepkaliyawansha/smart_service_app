import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/app_theme.dart';
import '../../providers/package_builder_provider.dart';
import '../../providers/services_provider.dart';
import '../../models/booking_model.dart';

class AdminAnalyticsScreen extends ConsumerWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(allBookingsProvider);
    final services = ref.watch(servicesProvider).services;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Text(
                'Analytics',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: bookings.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
                error: (_, __) => const Center(
                  child: Text(
                    'Failed to load analytics',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
                data: (list) => _AnalyticsContent(
                  bookings: list,
                  serviceCount: services.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  final List<BookingModel> bookings;
  final int serviceCount;

  const _AnalyticsContent({required this.bookings, required this.serviceCount});

  @override
  Widget build(BuildContext context) {
    final totalRevenue = bookings.fold<double>(0, (s, b) => s + b.totalPrice);
    final totalDiscount = bookings.fold<double>(
      0,
      (s, b) => s + b.discountAmount,
    );
    final pendingCount = bookings.where((b) => b.status == 'pending').length;
    final confirmedCount = bookings
        .where((b) => b.status == 'confirmed')
        .length;
    final completedCount = bookings
        .where((b) => b.status == 'completed')
        .length;

    // Revenue by service
    final Map<String, double> revenueByService = {};
    for (final b in bookings) {
      revenueByService[b.serviceName] =
          (revenueByService[b.serviceName] ?? 0) + b.totalPrice;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Revenue + Discount Cards ─────────────────────────────────────
          FadeInUp(
            child: Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: '💰',
                    label: 'Total Revenue',
                    value: 'Rs. ${totalRevenue.toStringAsFixed(0)}',
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: '🎁',
                    label: 'Discounts Given',
                    value: 'Rs. ${totalDiscount.toStringAsFixed(0)}',
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 80),
            child: Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: '🛠️',
                    label: 'Services',
                    value: '$serviceCount',
                    color: const Color(0xFF4A9EFF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: '📋',
                    label: 'Total Bookings',
                    value: '${bookings.length}',
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── Booking Status Pie Chart ──────────────────────────────────────
          FadeInUp(
            delay: const Duration(milliseconds: 150),
            child: _SectionTitle('Booking Status'),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 180),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: bookings.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No booking data yet',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontFamily: 'DMSans',
                          ),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        SizedBox(
                          height: 140,
                          width: 140,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 40,
                              sections: [
                                if (pendingCount > 0)
                                  PieChartSectionData(
                                    value: pendingCount.toDouble(),
                                    color: AppTheme.warning,
                                    title: '$pendingCount',
                                    radius: 28,
                                    titleStyle: const TextStyle(
                                      fontFamily: 'Syne',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                if (confirmedCount > 0)
                                  PieChartSectionData(
                                    value: confirmedCount.toDouble(),
                                    color: AppTheme.success,
                                    title: '$confirmedCount',
                                    radius: 28,
                                    titleStyle: const TextStyle(
                                      fontFamily: 'Syne',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                if (completedCount > 0)
                                  PieChartSectionData(
                                    value: completedCount.toDouble(),
                                    color: const Color(0xFF4A9EFF),
                                    title: '$completedCount',
                                    radius: 28,
                                    titleStyle: const TextStyle(
                                      fontFamily: 'Syne',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LegendItem(
                                color: AppTheme.warning,
                                label: 'Pending',
                                count: pendingCount,
                              ),
                              const SizedBox(height: 10),
                              _LegendItem(
                                color: AppTheme.success,
                                label: 'Confirmed',
                                count: confirmedCount,
                              ),
                              const SizedBox(height: 10),
                              _LegendItem(
                                color: const Color(0xFF4A9EFF),
                                label: 'Completed',
                                count: completedCount,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Revenue by Service Bar Chart ─────────────────────────────────
          if (revenueByService.isNotEmpty) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 250),
              child: _SectionTitle('Revenue by Service'),
            ),
            const SizedBox(height: 12),
            FadeInUp(
              delay: const Duration(milliseconds: 280),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Column(
                  children: revenueByService.entries.map((e) {
                    final maxRevenue = revenueByService.values.reduce(
                      (a, b) => a > b ? a : b,
                    );
                    final pct = maxRevenue > 0 ? e.value / maxRevenue : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  e.key,
                                  style: const TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 13,
                                    color: AppTheme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                'Rs. ${e.value.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 7,
                              backgroundColor: AppTheme.background,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ─── Top Add-ons ───────────────────────────────────────────────────
          FadeInUp(
            delay: const Duration(milliseconds: 330),
            child: _SectionTitle('Most Chosen Add-ons'),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            delay: const Duration(milliseconds: 360),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Builder(
                builder: (ctx) {
                  final addonCounts = <String, int>{};
                  for (final b in bookings) {
                    for (final name in b.selectedAddonNames) {
                      addonCounts[name] = (addonCounts[name] ?? 0) + 1;
                    }
                  }
                  if (addonCounts.isEmpty) {
                    return const Center(
                      child: Text(
                        'No add-on data yet',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    );
                  }
                  final sorted = addonCounts.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  final top = sorted.take(5).toList();
                  return Column(
                    children: top.asMap().entries.map((e) {
                      final rank = e.key + 1;
                      final item = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: rank == 1
                                    ? AppTheme.primary.withOpacity(0.2)
                                    : AppTheme.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '$rank',
                                  style: TextStyle(
                                    fontFamily: 'Syne',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: rank == 1
                                        ? AppTheme.primary
                                        : AppTheme.textMuted,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.key,
                                style: const TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${item.value}x',
                                style: const TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          '$count',
          style: const TextStyle(
            fontFamily: 'Syne',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Syne',
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
