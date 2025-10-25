import 'package:flutter/material.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.system);

  static void set(ThemeMode m) => mode.value = m;

  static void toggle() {
    if (mode.value == ThemeMode.dark) {
      mode.value = ThemeMode.light;
    } else {
      mode.value = ThemeMode.dark;
    }
  }

  static void useSystem() => mode.value = ThemeMode.system;
}