import 'package:flutter/material.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.system);
  // Notificador para la animación de transición entre temas
  static final ValueNotifier<double> transitionProgress = ValueNotifier(0.0);
  static final Duration transitionDuration = const Duration(milliseconds: 400);

  static void set(ThemeMode m) {
    // Iniciar animación de transición
    transitionProgress.value = 0.0;
    mode.value = m;
    _animateTransition();
  }

  static void toggle() {
    // Iniciar animación de transición
    transitionProgress.value = 0.0;
    if (mode.value == ThemeMode.dark) {
      mode.value = ThemeMode.light;
    } else {
      mode.value = ThemeMode.dark;
    }
    _animateTransition();
  }

  static void useSystem() {
    transitionProgress.value = 0.0;
    mode.value = ThemeMode.system;
    _animateTransition();
  }

  // Método para animar la transición
  static void _animateTransition() {
    const frameDuration = Duration(milliseconds: 16); // ~60fps
    final steps = (transitionDuration.inMilliseconds / frameDuration.inMilliseconds).ceil();
    final increment = 1.0 / steps;
    
    int currentStep = 0;
    
    void nextFrame() {
      currentStep++;
      transitionProgress.value = currentStep * increment;
      
      if (currentStep < steps) {
        Future.delayed(frameDuration, nextFrame);
      }
    }
    
    nextFrame();
  }
}