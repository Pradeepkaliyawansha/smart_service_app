import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/services_provider.dart';
import '../../providers/package_builder_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final servicesState = ref.watch(servicesProvider);
    final bookings = ref.watch(allBookingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ────────────────────────────────────────────────────
              FadeInDown(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin Panel',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'Hello, ${auth.user?.name.split(' ').first ?? 'Admin'}',
                            style: const TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(authProvider.notifier).logout(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
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
              const SizedBox(height: 24),

              // ─── Stats Row ─────────────────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: '🛠️',
                        label: 'Services',
                        value: '${servicesState.services.length}',
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: bookings.when(
                        data: (b) => _StatCard(
                          icon: '📋',
                          label: 'Bookings',
                          value: '${b.length}',
                          color: AppTheme.success,
                        ),
                        loading: () => const _StatCard(
                          icon: '📋',
                          label: 'Bookings',
                          value: '...',
                          color: AppTheme.success,
                        ),
                        error: (_, __) => const _StatCard(
                          icon: '📋',
                          label: 'Bookings',
                          value: '-',
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: bookings.when(
                        data: (b) {
                          final revenue = b.fold<double>(
                            0,
                            (s, bk) => s + bk.totalPrice,
                          );
                          return _StatCard(
                            icon: '💰',
                            label: 'Revenue',
                            value: 'Rs.${(revenue / 1000).toStringAsFixed(0)}k',
                            color: const Color(0xFF4A9EFF),
                          );
                        },
                        loading: () => const _StatCard(
                          icon: '💰',
                          label: 'Revenue',
                          value: '...',
                          color: Color(0xFF4A9EFF),
                        ),
                        error: (_, __) => const _StatCard(
                          icon: '💰',
                          label: 'Revenue',
                          value: '-',
                          color: Color(0xFF4A9EFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Quick Actions ─────────────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              FadeInUp(
                delay: const Duration(milliseconds: 250),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.add_business_rounded,
                        label: 'Add Service',
                        onTap: () => context.push('/admin/add-service'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.grid_view_rounded,
                        label: 'Manage Services',
                        onTap: () => context.go('/admin/services'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.analytics_rounded,
                        label: 'Analytics',
                        onTap: () => context.go('/admin/analytics'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.list_alt_rounded,
                        label: 'All Bookings',
                        onTap: () => context.go('/admin/bookings'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Recent Bookings ───────────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 350),
                child: const Text(
                  'Recent Bookings',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              bookings.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                ),
                error: (e, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: const Text(
                    'Could not load bookings',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontFamily: 'DMSans',
                    ),
                  ),
                ),
                data: (list) => list.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: const Center(
                          child: Text(
                            'No bookings yet',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontFamily: 'DMSans',
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: list.take(5).toList().asMap().entries.map((
                          e,
                        ) {
                          final b = e.value;
                          final statusColors = {
                            'pending': AppTheme.warning,
                            'confirmed': AppTheme.success,
                            'cancelled': AppTheme.error,
                            'completed': const Color(0xFF4A9EFF),
                          };
                          final color =
                              statusColors[b.status] ?? AppTheme.textMuted;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        b.packageName,
                                        style: const TextStyle(
                                          fontFamily: 'Syne',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        b.serviceName,
                                        style: const TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Rs. ${b.totalPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontFamily: 'Syne',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        b.status.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'Syne',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
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
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 20,
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textMuted,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}
