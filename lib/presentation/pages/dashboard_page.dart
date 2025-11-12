import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../bloc/auth_cubit.dart';
import '../widgets/blob_background.dart';
import '../widgets/glass_widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassContentColor = isDark ? Colors.white70 : Colors.black54;
    final authState = context.watch<AuthCubit>().state;
    final userEmail = authState is Authenticated ? authState.email : '';
    final displayName = authState is Authenticated
        ? (authState.displayName ?? userEmail)
        : '';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t.dashboardTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: BlobBackground(
        topLeftColor: const Color(0xFF3F51B5),
        bottomRightColor: const Color(0xFF0D47A1),
        child: Column(
          children: [
            CurvedHeader(
              height: 190,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.welcomeUser(displayName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/search'),
                child: Semantics(
                  button: true,
                  label: 'Open search',
                  hint:
                      'Press to search teachers, classrooms, subjects, schedules',
                  child: GlassContainer(
                    child: Row(
                      children: [
                        Icon(Icons.search, color: glassContentColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Search...',
                            style: TextStyle(color: glassContentColor),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: glassContentColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  GlassIconTile(
                    label: t.teachers,
                    icon: Icons.person_outline,
                    onTap: () => context.push('/teachers'),
                  ),
                  GlassIconTile(
                    label: t.subjects,
                    icon: Icons.menu_book_outlined,
                    onTap: () => context.push('/subjects'),
                  ),
                  GlassIconTile(
                    label: t.classrooms,
                    icon: Icons.meeting_room_outlined,
                    onTap: () => context.push('/classrooms'),
                  ),
                  GlassIconTile(
                    label: t.schedules,
                    icon: Icons.event_outlined,
                    onTap: () => context.push('/schedules'),
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
