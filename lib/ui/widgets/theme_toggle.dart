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

        return GestureDetector(
          onTap: ThemeController.toggle,
          onLongPress: ThemeController.useSystem,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic,
            padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 6 : 8),
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surface.withOpacity(0.24) : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(isDark ? 0.25 : 0.35)),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (child, animation) {
                final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
                final scale = Tween<double>(begin: 0.92, end: 1.0).animate(fade);
                return FadeTransition(opacity: fade, child: ScaleTransition(scale: scale, child: child));
              },
              child: compact
                  ? Icon(
                      isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                      key: ValueKey<bool>(isDark),
                      size: 18,
                      color: isDark ? theme.colorScheme.onSurface : theme.colorScheme.primary,
                    )
                  : Row(
                      key: ValueKey<bool>(isDark),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                          size: 18,
                          color: isDark ? theme.colorScheme.onSurface : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isDark ? 'Dark' : 'Light',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? theme.colorScheme.onSurface : theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}