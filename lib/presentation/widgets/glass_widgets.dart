import 'dart:ui';
import 'package:flutter/material.dart';

/// Simple glassmorphism container with blur, soft gradient and shadow.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blur;
  final double opacity;
  final List<BoxShadow>? shadows;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blur = 18,
    this.opacity = 0.18,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultShadows =
        shadows ??
        [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                if (isDark) ...[
                  Colors.white.withOpacity(opacity * 0.6),
                  Colors.white.withOpacity(opacity * 0.45),
                ] else ...[
                  Colors.white.withOpacity(opacity + 0.06),
                  Colors.white.withOpacity(opacity),
                ],
              ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.18)
                  : Colors.white.withOpacity(0.3),
            ),
            boxShadow: defaultShadows,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Rounded icon tile following the design: gradient icon, label below.
class GlassIconTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? accent;
  // Optional asset path to render an image instead of an Icon.
  final String? assetPath;

  const GlassIconTile({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.accent,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (assetPath == null) ...[
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
            ] else ...[
              // Render provided asset image with soft rounded corners.
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(assetPath!, fit: BoxFit.cover),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Curved dark header to emulate the top sheet of the reference.
class CurvedHeader extends StatelessWidget {
  final double height;
  final Widget? child;
  const CurvedHeader({super.key, this.height = 180, this.child});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF2B244D), primary.withOpacity(0.85)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Smooth curve resembling the folded sheet from the screenshot.
    final path = Path();
    path.lineTo(0, size.height * 0.76);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.60,
      size.width * 0.50,
      size.height * 0.72,
    );
    path.quadraticBezierTo(
      size.width * 0.78,
      size.height * 0.84,
      size.width,
      size.height * 0.70,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
