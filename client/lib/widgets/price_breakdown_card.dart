import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/price_calculation_model.dart';

class PriceBreakdownCard extends StatelessWidget {
  final PriceCalculation pricing;

  const PriceBreakdownCard({super.key, required this.pricing});

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
          const Row(
            children: [
              Text('💳', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text(
                'Price Breakdown',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _row('Base price', pricing.basePrice),
          _row('Duration cost', pricing.durationCost),
          if (pricing.addonsCost > 0) _row('Add-ons total', pricing.addonsCost),
          const Divider(color: AppTheme.divider, height: 20),
          _row('Subtotal', pricing.subtotal),
          if (pricing.hasDiscount) ...[
            _discountRow(),
            const Divider(color: AppTheme.divider, height: 20),
          ],
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: pricing.totalPrice),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (_, value, __) => Text(
                  'Rs. ${value.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            'Rs. ${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 13,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _discountRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_offer_rounded,
                color: AppTheme.success,
                size: 13,
              ),
              const SizedBox(width: 4),
              Text(
                pricing.discountReason ?? 'Discount applied',
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
          Text(
            '- Rs. ${pricing.discountAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }
}
