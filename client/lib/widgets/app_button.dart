import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class AppButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final bool outlined;

  const AppButton({
    super.key,
    required this.label,
    this.isLoading = false,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: outlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              child: _content(),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? AppTheme.primary,
              ),
              child: _content(),
            ),
    );
  }

  Widget _content() {
    if (isLoading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppTheme.background,
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(label), const SizedBox(width: 8), Icon(icon, size: 18)],
      );
    }
    return Text(label);
  }
}
