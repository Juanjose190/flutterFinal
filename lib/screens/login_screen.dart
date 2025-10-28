import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/widgets/glass_card.dart';
import '../ui/widgets/theme_toggle.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _remember = true;
  bool _pressed = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _login() {
    setState(() => _pressed = true);
    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) setState(() => _pressed = false);
      context.go('/home');
    });
  }

  InputDecoration _decoration(ColorScheme cs, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: cs.surfaceContainerHighest.withOpacity(0.45),
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: cs.primary, width: 1.2),
      ),
    );
  }

  Widget _gradientButton(ColorScheme cs) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _login,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: _pressed ? 0.98 : 1.0,
          curve: Curves.easeOut,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary.withOpacity(0.95),
                  cs.primary.withOpacity(0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.arrow_right_circle_fill,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo(ColorScheme cs) {
    return Hero(
      tag: 'app-logo',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.primary.withOpacity(0.9),
                cs.primary.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.2),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(CupertinoIcons.calendar, color: Colors.white),
        ),
      ),
    );
  }

  Widget _form(ColorScheme cs) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _logo(cs),
                  const SizedBox(width: 12),
                  const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration(
                  cs,
                  'Correo electrónico',
                  CupertinoIcons.envelope,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passController,
                focusNode: _passFocus,
                obscureText: true,
                decoration: _decoration(cs, 'Contraseña', CupertinoIcons.lock),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CupertinoSwitch(
                    value: _remember,
                    onChanged: (v) => setState(() => _remember = v),
                  ),
                  const SizedBox(width: 8),
                  const Text('Remember me'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _gradientButton(cs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _illustration(bool isDark) {
    final colors = isDark
        ? [const Color(0xFF1C1C1E), const Color(0xFF2C2C2E)]
        : [const Color(0xFFF5F6F7), const Color(0xFFE0E0E0)];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors[0], colors[1]],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 80,
            top: 120,
            child: Opacity(
              opacity: 0.15,
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0A84FF),
                ),
              ),
            ),
          ),
          Positioned(
            left: 120,
            bottom: 100,
            child: Opacity(
              opacity: 0.12,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF7D73FF),
                ),
              ),
            ),
          ),
          Center(
            child: Opacity(
              opacity: 0.25,
              child: const Icon(CupertinoIcons.waveform_path_ecg, size: 140),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final left = _form(cs);
              final right = _illustration(isDark);
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOut,
                opacity: _loaded ? 1 : 0,
                child: isWide
                    ? Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: left,
                            ),
                          ),
                          Expanded(flex: 5, child: right),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).padding.top + 24,
                            ),
                            SizedBox(height: 240, child: right),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: left,
                            ),
                          ],
                        ),
                      ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: const ThemeToggle(compact: true),
          ),
        ],
      ),
    );
  }
}
