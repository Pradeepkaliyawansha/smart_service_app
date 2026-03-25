import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/app_theme.dart';
import '../../models/booking_model.dart';
import '../../providers/package_builder_provider.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(myBookingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Text(
                'My Bookings',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 28,
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
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text(
                        'Could not load bookings',
                        style: const TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.refresh(myBookingsProvider),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                data: (bookings) => bookings.isEmpty
                    ? const _EmptyBookings()
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: bookings.length,
                        itemBuilder: (ctx, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: FadeInUp(
                            delay: Duration(milliseconds: i * 60),
                            child: _BookingCard(booking: bookings[i]),
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

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text(
            'No bookings yet',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse services and build your first package',
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

class _BookingCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      'pending': AppTheme.warning,
      'confirmed': AppTheme.success,
      'cancelled': AppTheme.error,
      'completed': const Color(0xFF4A9EFF),
    };
    final statusColor = statusColors[booking.status] ?? AppTheme.textMuted;

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
                  booking.packageName,
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            booking.serviceName,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                icon: Icons.access_time_rounded,
                label: '${booking.durationHours}h',
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.extension_rounded,
                label: '${booking.selectedAddonNames.length} add-ons',
              ),
              if (booking.eventDate != null) ...[
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  label:
                      '${booking.eventDate!.day}/${booking.eventDate!.month}',
                ),
              ],
              const Spacer(),
              Text(
                'Rs. ${booking.totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          if (booking.discountAmount > 0) ...[
            const SizedBox(height: 6),
            Text(
              'Saved Rs. ${booking.discountAmount.toStringAsFixed(0)} with bundle discount',
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11,
                color: AppTheme.success,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textMuted),
          const SizedBox(width: 4),
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
