import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ui/widgets/theme_toggle.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<_HomeItem> _items = const [
    _HomeItem(icon: CupertinoIcons.person_2, title: 'Docentes', subtitle: 'Gestión de profesores', route: '/docentes'),
    _HomeItem(icon: CupertinoIcons.book, title: 'Materias', subtitle: 'Asignaturas y contenidos', route: '/materias'),
    _HomeItem(icon: CupertinoIcons.building_2_fill, title: 'Aulas', subtitle: 'Salas y capacidad', route: '/aulas'),
    _HomeItem(icon: CupertinoIcons.calendar, title: 'Generar horario', subtitle: 'Plan automático', route: '/generar'),
    _HomeItem(icon: CupertinoIcons.table, title: 'Ver horario', subtitle: 'Visualización detallada', route: '/horario'),
    _HomeItem(icon: CupertinoIcons.gear, title: 'Ajustes', subtitle: 'Preferencias de la app', route: '/home'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar la animación después de un breve retraso para asegurar que el widget esté montado
    Future.delayed(const Duration(milliseconds: 100), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar.large(
                title: const Text('Inicio'),
                floating: true,
                snap: true,
                actions: const [ThemeToggle()],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.98,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _items[index];
                  final selected = _selectedIndex == index;
                  
                  // Animación escalonada para cada tarjeta
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      // Retraso escalonado para cada tarjeta
                      final delay = index * 0.1;
                      final itemAnimation = CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          delay.clamp(0.0, 0.9), // Inicio retrasado según el índice
                          (delay + 0.5).clamp(0.0, 1.0), // Fin de la animación
                          curve: Curves.easeOutCubic,
                        ),
                      );
                      
                      return FadeTransition(
                        opacity: itemAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(itemAnimation),
                          child: child,
                        ),
                      );
                    },
                    child: _HomeCard(
                      item: item,
                      selected: selected,
                      onTap: () {
                        setState(() => _selectedIndex = index);
                        if (item.route != null && item.route!.isNotEmpty) {
                          context.push(item.route!);
                        }
                      },
                    ),
                  );
                },
                childCount: _items.length,
              ),
            ),
          ),
         ),
        ),
      ),
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF8F8F8), // Actualizado para Light mode
    );
  }
}

class _HomeCard extends StatelessWidget {
  final _HomeItem item;
  final bool selected;
  final VoidCallback onTap;

  const _HomeCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFD1D1D6);
    final accent = const Color(0xFFFFD60A);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? accent.withOpacity(0.8) : borderColor),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.35),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.35 : 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: accent.withOpacity(0.14),
          highlightColor: accent.withOpacity(0.06),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? accent.withOpacity(0.15)
                            : (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF2F2F7)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        color: selected ? accent : theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? Colors.white.withOpacity(0.7)
                            : const Color(0xFF1C1C1E).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: AnimatedOpacity(
                    opacity: selected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(CupertinoIcons.check_mark_circled_solid, color: accent, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
  const _HomeItem({required this.icon, required this.title, required this.subtitle, this.route});
}