import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../ui/theme_controller.dart';

class ThemeToggle extends StatelessWidget {
  final bool compact;
  const ThemeToggle({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) {
        final bool isDark = mode == ThemeMode.dark ||
            (mode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

        return ValueListenableBuilder<double>(
          valueListenable: ThemeController.transitionProgress,
          builder: (context, progress, _) {
            // Colores para la transición
            final containerColor = isDark 
                ? Color.lerp(theme.colorScheme.surface, theme.colorScheme.surface.withOpacity(0.24), progress)!
                : Color.lerp(theme.colorScheme.surface.withOpacity(0.24), theme.colorScheme.surface, progress)!;
            
            final iconColor = isDark
                ? Color.lerp(Colors.amber, Colors.white, progress)!
                : Color.lerp(Colors.white, Colors.amber, progress)!;
            
            final borderColor = isDark
                ? theme.colorScheme.outline.withOpacity(0.25 + (0.1 * progress))
                : theme.colorScheme.outline.withOpacity(0.35 - (0.1 * progress));
            
            return GestureDetector(
              onTap: ThemeController.toggle,
              onLongPress: ThemeController.useSystem,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 6 : 8),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: isDark 
                          ? Colors.black.withOpacity(0.2 * progress)
                          : Colors.black.withOpacity(0.05 * (1 - progress)),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
                    final scale = Tween<double>(begin: 0.8, end: 1.0).animate(fade);
                    final rotate = Tween<double>(begin: -0.5, end: 0.0).animate(fade);
                    
                    return ScaleTransition(
                      scale: scale,
                      child: RotationTransition(
                        turns: rotate,
                        child: FadeTransition(opacity: fade, child: child),
                      ),
                    );
                  },
                  child: compact
                      ? Icon(
                          isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                          key: ValueKey<bool>(isDark),
                          size: 18,
                          color: iconColor,
                        )
                      : Row(
                          key: ValueKey<bool>(isDark),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                              size: 18,
                              color: iconColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isDark ? 'Dark' : 'Light',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: iconColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            );
          }
        );
      },
    );
  }
}