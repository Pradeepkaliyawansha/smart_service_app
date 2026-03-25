import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class RecommendationBanner extends StatelessWidget {
  final String message;
  final bool isBestValue;
  final bool isMostPopular;

  const RecommendationBanner({
    super.key,
    required this.message,
    this.isBestValue = false,
    this.isMostPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isBestValue
        ? const Color(0xFF4A9EFF)
        : isMostPopular
        ? AppTheme.warning
        : AppTheme.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isBestValue
                ? Icons.star_rounded
                : isMostPopular
                ? Icons.local_fire_department_rounded
                : Icons.lightbulb_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
