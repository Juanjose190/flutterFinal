import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Distinct app-wide visual styles
enum ThemeStyle { defaultStyle, purpleClean }

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;
  final ThemeStyle style;
  const SettingsState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en'),
    this.style = ThemeStyle.defaultStyle,
  });
  SettingsState copyWith({ThemeMode? themeMode, Locale? locale, ThemeStyle? style}) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
        style: style ?? this.style,
      );
  @override
  List<Object> get props => [themeMode, locale, style];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());
  void setTheme(ThemeMode mode) => emit(state.copyWith(themeMode: mode));
  void setLanguage(Locale locale) => emit(state.copyWith(locale: locale));
  void setStyle(ThemeStyle style) => emit(state.copyWith(style: style));
}
