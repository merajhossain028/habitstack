import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/supabase_service.dart';
import '../../../utils/logger/logger_helper.dart';
import '../model/auth_state.dart';

// Auth state provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// Form field providers
final nameControllerProvider = Provider.autoDispose<TextEditingController>((
  ref,
) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

final usernameControllerProvider = Provider.autoDispose<TextEditingController>((
  ref,
) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

final emailControllerProvider = Provider.autoDispose<TextEditingController>((
  ref,
) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

final passwordControllerProvider = Provider.autoDispose<TextEditingController>((
  ref,
) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});
final rememberMeProvider = StateProvider<bool>((ref) => false);
final agreeToTermsProvider = StateProvider<bool>((ref) => false);

// Password visibility
final passwordVisibilityProvider = StateProvider<bool>((ref) => true);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkAuthStatus();
    return const AuthState(status: AuthStatus.initial);
  }

  Future<void> _checkAuthStatus() async {
    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signUp({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await SupabaseService.instance.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      if (response.user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: response.user,
        );
        log.i('Signup successful: ${response.user!.email}');
      } else {
        throw Exception('Signup failed');
      }
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
      log.e('Signup error: $e');
      rethrow;
    }
  }

  Future<void> signIn({
    required String emailOrUsername,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await SupabaseService.instance.signInWithEmail(
        email: emailOrUsername,
        password: password,
      );

      if (response.user != null) {
        // Save remember me preference
        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('remember_me', true);
          await prefs.setString('user_email', emailOrUsername);
        }

        state = AuthState(
          status: AuthStatus.authenticated,
          user: response.user,
          rememberMe: rememberMe,
        );
        log.i('Login successful: ${response.user!.email}');
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
      log.e('Login error: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await SupabaseService.instance.signInWithGoogle();

      final user = SupabaseService.instance.currentUser;
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        log.i('Google login successful');
      }
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
      log.e('Google login error: $e');
      rethrow;
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await SupabaseService.instance.signInWithApple();

      final user = SupabaseService.instance.currentUser;
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        log.i('Apple login successful');
      }
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
      log.e('Apple login error: $e');
      rethrow;
    }
  }

  Future<void> signInAsDemo() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      // Demo credentials
      await signIn(
        emailOrUsername: 'demo@habitstack.com',
        password: 'demo123456',
        rememberMe: false,
      );
      log.i('Demo login successful');
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        error: 'Demo account not available',
      );
      log.e('Demo login error: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await SupabaseService.instance.resetPassword(email);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      log.i('Password reset email sent to: $email');
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
      log.e('Password reset error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await SupabaseService.instance.signOut();

      // Clear remember me
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_me');
      await prefs.remove('user_email');

      state = const AuthState(status: AuthStatus.unauthenticated);
      log.i('Logout successful');
    } catch (e) {
      log.e('Logout error: $e');
    }
  }

  void clearError() {
    state = state.copyWith(status: AuthStatus.unauthenticated, error: null);
  }
}
