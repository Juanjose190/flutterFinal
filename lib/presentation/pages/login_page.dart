import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/generated/app_localizations.dart';
import '../bloc/auth_cubit.dart';
import 'package:go_router/go_router.dart';
import '../../data/supabase/supabase_service.dart';
import '../widgets/blob_background.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black38;
    return Scaffold(
      body: BlobBackground(
        topLeftColor: const Color(0xFF3F51B5), // indigo
        bottomRightColor: const Color(0xFF0D47A1), // dark blue
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Login',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Card with two fields and an action button overlaid on the right
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Username',
                              labelStyle: TextStyle(
                                color: isDark ? Colors.white70 : null,
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: isDark ? Colors.white70 : null,
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: isDark ? Colors.white70 : null,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: isDark ? Colors.white70 : null,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscure = !_obscure;
                                  });
                                },
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: isDark ? Colors.white70 : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Arrow action button
                    Positioned(
                      right: -6,
                      top: 36,
                      child: BlocConsumer<AuthCubit, AuthState>(
                        listener: (context, state) {
                          if (state is Authenticated) context.go('/');
                          if (state is Unauthenticated) {
                            final msg = state.error ?? t.signInError;
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(msg)));
                          }
                        },
                        builder: (context, state) {
                          final loading = state is Authenticating;
                          final supa = SupabaseService();
                          final supaReady = supa.isReady;
                          final envError = supa.validationError;
                          return GestureDetector(
                            onTap: loading
                                ? null
                                : () {
                                    if (!supaReady) {
                                      final msg = envError ?? t.missingEnv;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(msg)),
                                      );
                                      return;
                                    }
                                    context.read<AuthCubit>().signIn(
                                      _emailController.text.trim(),
                                      _passwordController.text,
                                    );
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF29B6F6), // light blue
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Forgotpassword?', style: TextStyle(color: subTextColor)),
                const SizedBox(height: 28),
                Row(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: const BorderSide(color: Colors.redAccent),
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () => context.push('/signup'),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
