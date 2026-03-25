import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/app_theme.dart';
import '../../models/booking_model.dart';
import '../../providers/package_builder_provider.dart';
import '../../providers/auth_provider.dart';

class AdminBookingsScreen extends ConsumerWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(allBookingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Text(
                'All Bookings',
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
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      const Text(
                        'Failed to load',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref.refresh(allBookingsProvider),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                data: (list) => list.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('📭', style: TextStyle(fontSize: 48)),
                            SizedBox(height: 12),
                            Text(
                              'No bookings yet',
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontSize: 18,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: list.length,
                        itemBuilder: (ctx, i) {
                          final b = list[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: FadeInUp(
                              delay: Duration(milliseconds: i * 50),
                              child: _AdminBookingCard(
                                booking: b,
                                onStatusChange: (status) async {
                                  try {
                                    final api = ref.read(apiServiceProvider);
                                    await api.updateBookingStatus(b.id, status);
                                    ref.refresh(allBookingsProvider);
                                  } catch (_) {}
                                },
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
}

class _AdminBookingCard extends StatelessWidget {
  final BookingModel booking;
  final Function(String) onStatusChange;

  const _AdminBookingCard({
    required this.booking,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      'pending': AppTheme.warning,
      'confirmed': AppTheme.success,
      'cancelled': AppTheme.error,
      'completed': const Color(0xFF4A9EFF),
    };
    final Color statusColor =
        statusColors[booking.status] ?? AppTheme.textMuted;

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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            booking.serviceName,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${booking.durationHours}h',
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(width: 8),
              const Text('·', style: TextStyle(color: AppTheme.textMuted)),
              const SizedBox(width: 8),
              Text(
                '${booking.selectedAddonNames.length} add-ons',
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                'Rs. ${booking.totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Note: ${booking.notes}',
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          // Status change row
          if (booking.status == 'pending')
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onStatusChange('confirmed'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.success.withOpacity(0.3),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '✓ Confirm',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.success,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onStatusChange('cancelled'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.error.withOpacity(0.3),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '✕ Cancel',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (booking.status == 'confirmed')
            GestureDetector(
              onTap: () => onStatusChange('completed'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A9EFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF4A9EFF).withOpacity(0.3),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Mark as Completed',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A9EFF),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
