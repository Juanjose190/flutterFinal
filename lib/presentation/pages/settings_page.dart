import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/generated/app_localizations.dart';
import '../bloc/settings_cubit.dart';
import 'package:go_router/go_router.dart';
import '../widgets/blob_background.dart';
import '../widgets/glass_widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: BlobBackground(
        topLeftColor: const Color(0xFF3F51B5),
        bottomRightColor: const Color(0xFF0D47A1),
        child: Column(
          children: [
            const CurvedHeader(height: 150),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.theme,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, s) => Row(
                      children: [
                        ChoiceChip(
                          label: Text(t.light),
                          selected: s.themeMode == ThemeMode.light,
                          onSelected: (_) => context
                              .read<SettingsCubit>()
                              .setTheme(ThemeMode.light),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(t.dark),
                          selected: s.themeMode == ThemeMode.dark,
                          onSelected: (_) => context
                              .read<SettingsCubit>()
                              .setTheme(ThemeMode.dark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, s) {
                      return Row(
                        children: [
                          Expanded(
                            child: _ThemeCard(
                              selected: s.style == ThemeStyle.defaultStyle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                              ),
                              onTap: () => context
                                  .read<SettingsCubit>()
                                  .setStyle(ThemeStyle.defaultStyle),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ThemeCard(
                              selected: s.style == ThemeStyle.purpleClean,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9B73FF), Color(0xFF7C4DFF)],
                              ),
                              onTap: () => context
                                  .read<SettingsCubit>()
                                  .setStyle(ThemeStyle.purpleClean),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t.language,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, s) => Row(
                      children: [
                        ChoiceChip(
                          label: Text(t.english),
                          selected: s.locale.languageCode == 'en',
                          onSelected: (_) => context
                              .read<SettingsCubit>()
                              .setLanguage(const Locale('en')),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(t.spanish),
                          selected: s.locale.languageCode == 'es',
                          onSelected: (_) => context
                              .read<SettingsCubit>()
                              .setLanguage(const Locale('es')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final bool selected;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _ThemeCard({
    required this.selected,
    required this.gradient,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? Theme.of(context).colorScheme.primary
        : Colors.transparent;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.palette, color: Colors.white),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? Colors.green : Colors.black26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
