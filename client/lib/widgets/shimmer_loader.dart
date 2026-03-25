import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/app_theme.dart';

class ShimmerLoader extends StatelessWidget {
  final int count;

  const ShimmerLoader({super.key, this.count = 2});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: AppTheme.cardBg,
            highlightColor: AppTheme.cardBgLight,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
