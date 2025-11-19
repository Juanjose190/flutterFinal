import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/perf_monitor.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class Unauthenticated extends AuthState {
  final String? error;
  const Unauthenticated([this.error]);
  @override
  List<Object?> get props => [error];
}

class Authenticating extends AuthState {}

class Authenticated extends AuthState {
  final String email;
  final String? displayName;
  const Authenticated(this.email, {this.displayName});
  @override
  List<Object?> get props => [email, displayName];
}

class AuthCubit extends Cubit<AuthState> with ChangeNotifier {
  AuthCubit() : super(const Unauthenticated());

  Future<void> signIn(String email, String password) async {
    emit(Authenticating());
    try {
      final res = await PerformanceMonitor.time(
        'auth.signInWithPassword',
        Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        ),
      );
      if (res.user != null) {
        // Attempt to fetch a friendly display name from user_roles
        String? name;
        try {
          final client = Supabase.instance.client;
          final uid = res.user!.id;
          // Prefer cached display name to avoid query
          final prefs = await SharedPreferences.getInstance();
          name = prefs.getString('display_name_$uid');
          if (name == null) {
            final row = await PerformanceMonitor.time(
              'auth.fetchDisplayName',
              client
                  .from('user_roles')
                  .select('full_name')
                  .eq('user_id', uid)
                  .maybeSingle(),
            );
            name = row == null ? null : (row['full_name'] as String?);
            if (name != null) {
              await prefs.setString('display_name_$uid', name);
            }
          }
          // Fallback to auth metadata if available
          name ??= res.user!.userMetadata?['full_name'] as String?;
        } catch (_) {
          // Ignore lookup errors; we can still log in
        }
        emit(Authenticated(res.user!.email ?? email, displayName: name));
      } else {
        emit(const Unauthenticated('Invalid credentials'));
      }
    } on AuthApiException catch (e) {
      emit(Unauthenticated(e.message));
    } on AuthException catch (e) {
      emit(Unauthenticated(e.message));
    } catch (e) {
      emit(Unauthenticated(e.toString()));
    }
    notifyListeners();
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
    String? login,
  }) async {
    emit(Authenticating());
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          if (fullName != null) 'full_name': fullName,
          if (login != null) 'login': login,
        },
      );
      if (res.user != null) {
        // Try to upsert into user_roles so the app can show a friendly name
        try {
          final client = Supabase.instance.client;
          final uid = res.user!.id;
          final payload = {
            'user_id': uid,
            'email': res.user!.email ?? email,
            'full_name': fullName ?? login ?? email,
          };
          // Upsert on email to avoid duplicates
          await PerformanceMonitor.time(
            'auth.upsertUserRole',
            client.from('user_roles').upsert(payload, onConflict: 'email'),
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'display_name_${uid}',
            fullName ?? login ?? email,
          );
        } catch (_) {
          // Non-blocking: sign up succeeds even if the profile insert fails
        }
        emit(
          Authenticated(
            res.user!.email ?? email,
            displayName: fullName ?? login,
          ),
        );
      } else {
        emit(const Unauthenticated('Could not sign up'));
      }
    } on AuthApiException catch (e) {
      emit(Unauthenticated(e.message));
    } on AuthException catch (e) {
      emit(Unauthenticated(e.message));
    } catch (e) {
      emit(Unauthenticated(e.toString()));
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    emit(const Unauthenticated());
    notifyListeners();
  }
}
