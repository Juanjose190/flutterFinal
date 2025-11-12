import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/generated/app_localizations.dart';
import '../bloc/auth_cubit.dart';
import 'package:go_router/go_router.dart';
import '../widgets/gradient_background.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _loginCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _subscribe = true;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final whiteBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white, width: 1.5),
    );

    return Scaffold(
      body: GradientBackground(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              border: whiteBorder,
              enabledBorder: whiteBorder,
              focusedBorder: whiteBorder,
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: const TextStyle(color: Colors.white60),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('YOURLOGO', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.menu, color: Colors.white),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'First name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: t.email),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _loginCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Your login'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordCtrl,
                style: const TextStyle(color: Colors.white),
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: t.password,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _subscribe,
                    onChanged: (v) => setState(() => _subscribe = v ?? true),
                  ),
                  const Text('Subscribe to newsletter', style: TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 8),
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is Authenticated) context.go('/');
                  if (state is Unauthenticated) {
                    final msg = state.error ?? t.signInError;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                  }
                },
                builder: (context, state) {
                  final loading = state is Authenticating;
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: loading
                          ? null
                          : () {
                              context.read<AuthCubit>().signUp(
                                    email: _emailCtrl.text.trim(),
                                    password: _passwordCtrl.text,
                                    fullName: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
                                    login: _loginCtrl.text.trim().isEmpty ? null : _loginCtrl.text.trim(),
                                  );
                            },
                      child: loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Sign Up'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Sign In', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
