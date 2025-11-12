import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A simple reusable gradient background that fills the available space.
/// Wrap screen content with this to match the brand look.
class GradientBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GradientBackground({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.brandGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
