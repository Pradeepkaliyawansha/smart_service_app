import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/addon_model.dart';

class AddonCard extends StatelessWidget {
  final AddonModel addon;
  final bool isSelected;
  final VoidCallback onToggle;

  const AddonCard({
    super.key,
    required this.addon,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.1)
              : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withOpacity(0.15)
                    : AppTheme.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(addon.icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        addon.name,
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      if (addon.isPopular) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '🔥 Popular',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    addon.description,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Price + toggle
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+Rs.${addon.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.divider,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppTheme.background,
                          size: 14,
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
