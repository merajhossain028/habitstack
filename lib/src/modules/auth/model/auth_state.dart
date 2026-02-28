import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final supabase.User? user;
  final String? error;
  final bool rememberMe;

  const AuthState({
    required this.status,
    this.user,
    this.error,
    this.rememberMe = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    supabase.User? user,
    String? error,
    bool? rememberMe,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get hasError => status == AuthStatus.error;
}