import 'package:flutter/material.dart';

class AppTheme {
  static const _lightSeed = Color(0xFFFFCC00); // Color acento pastel para Light mode
  static const _darkSeed = Color(0xFF64D2FF);  // Lighter accent for dark

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _lightSeed,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        surface: Colors.white,
        surfaceContainerHighest: Colors.white,
        outline: const Color(0xFFD1D1D6),
        primary: const Color(0xFFFFCC00), // Color acento pastel
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F8F8), // Fondo principal actualizado
      dividerColor: const Color(0xFFD1D1D6),
      visualDensity: VisualDensity.standard,
      fontFamily: 'SF Pro Display', // fallback to system on non-iOS
      textTheme: _textTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1C1C1E),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: scheme.primary.withOpacity(0.12),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 12,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 6,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.08), // Sombras más suaves
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _darkSeed,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        surface: const Color(0xFF2C2C2E),
        surfaceContainerHighest: const Color(0xFF2C2C2E),
        outline: const Color(0xFF3A3A3C),
      ),
      scaffoldBackgroundColor: const Color(0xFF1C1C1E),
      dividerColor: const Color(0xFF3A3A3C),
      visualDensity: VisualDensity.standard,
      fontFamily: 'SF Pro Display',
      textTheme: _textTheme(Brightness.dark),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: scheme.primary.withOpacity(0.12),
        backgroundColor: const Color(0xFF2C2C2E).withOpacity(0.85),
        elevation: 12,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        color: const Color(0xFF2C2C2E),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _textTheme(Brightness b) {
    final isDark = b == Brightness.dark;
    const titleLarge = TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    );
    const titleMedium = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
    );
    const bodyLarge = TextStyle(fontSize: 16, height: 1.4);
    const bodyMedium = TextStyle(fontSize: 14, height: 1.4);
    return TextTheme(
      displayLarge: titleLarge,
      headlineLarge: titleLarge,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      bodyLarge: bodyLarge.copyWith(color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
      bodyMedium: bodyMedium.copyWith(color: isDark ? const Color(0xFFEBEBF5).withOpacity(0.6) : const Color(0xFF3A3A3C)),
      labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}