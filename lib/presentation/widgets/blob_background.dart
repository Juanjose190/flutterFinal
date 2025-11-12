import 'package:flutter/material.dart';

/// A simple decorative background with large corner blobs to mimic
/// the rounded cloud shapes from the provided design.
class BlobBackground extends StatelessWidget {
  final Color topLeftColor;
  final Color bottomRightColor;
  final Widget child;
  final EdgeInsets padding;

  const BlobBackground({
    super.key,
    required this.topLeftColor,
    required this.bottomRightColor,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Respect current theme background to enable dark mode properly.
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          // Top-left blob
          Positioned(
            top: -120,
            left: -80,
            child: _blob(topLeftColor, 240),
          ),
          Positioned(
            top: 40,
            left: -60,
            child: _blob(topLeftColor.withOpacity(0.85), 160),
          ),
          // Bottom-right blob
          Positioned(
            bottom: -140,
            right: -100,
            child: _blob(bottomRightColor, 280),
          ),
          Positioned(
            bottom: 20,
            right: -60,
            child: _blob(bottomRightColor.withOpacity(0.85), 180),
          ),
          // Content
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}
