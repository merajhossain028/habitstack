import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../api/supabase_service.dart';
import '../../../utils/logger/logger_helper.dart';
import '../model/auth_state.dart';

// Auth state provider
final authProvider = NotifierProvider<AuthNotifier, AppAuthState>(
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

class AuthNotifier extends Notifier<AppAuthState> {
  @override
  AppAuthState build() {
    _checkAuthStatus();
    return const AppAuthState(status: AuthStatus.initial);
  }

  Future<void> _checkAuthStatus() async {
    final user = SupabaseService.instance.currentUser;
    if (user != null) {
      state = AppAuthState(status: AuthStatus.authenticated, user: user);
    } else {
      state = const AppAuthState(status: AuthStatus.unauthenticated);
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
      log.i('Attempting signup for: $email');

      final response = await SupabaseService.instance.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      if (response.user != null) {
        state = AppAuthState(
          status: AuthStatus.authenticated,
          user: response.user,
        );
        log.i('Signup successful: ${response.user!.email}');
      } else {
        throw Exception('Signup failed - no user returned');
      }
    } on AuthApiException catch (e) {
      // ✅ Handle Supabase-specific errors
      String errorMsg;

      switch (e.code) {
        case 'over_email_send_rate_limit':
          errorMsg = 'Please wait 45 seconds before trying again.';
          break;
        case 'email_exists':
        case 'user_already_exists':
          errorMsg =
              'This email is already registered. Try logging in instead.';
          break;
        case 'invalid_credentials':
          errorMsg = 'Invalid email or password.';
          break;
        case 'weak_password':
          errorMsg = 'Password is too weak. Use at least 8 characters.';
          break;
        default:
          errorMsg = e.message ?? 'Signup failed. Please try again.';
      }

      state = AppAuthState(status: AuthStatus.error, error: errorMsg);
      log.e('Signup error: ${e.code} - ${e.message}');
      rethrow;
    } on SocketException catch (e) {
      state = AppAuthState(
        status: AuthStatus.error,
        error: 'No internet connection. Please check your network.',
      );
      log.e('Network error: $e');
      rethrow;
    } catch (e) {
      final errorMsg = e.toString().contains('already registered')
          ? 'Email already registered. Try logging in instead.'
          : 'Signup failed: ${e.toString()}';

      state = AppAuthState(status: AuthStatus.error, error: errorMsg);
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

        state = AppAuthState(
          status: AuthStatus.authenticated,
          user: response.user,
          rememberMe: rememberMe,
        );
        log.i('Login successful: ${response.user!.email}');
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      state = AppAuthState(status: AuthStatus.error, error: e.toString());
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
        state = AppAuthState(status: AuthStatus.authenticated, user: user);
        log.i('Google login successful');
      }
    } catch (e) {
      state = AppAuthState(status: AuthStatus.error, error: e.toString());
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
        state = AppAuthState(status: AuthStatus.authenticated, user: user);
        log.i('Apple login successful');
      }
    } catch (e) {
      state = AppAuthState(status: AuthStatus.error, error: e.toString());
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
      state = AppAuthState(
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
      state = AppAuthState(status: AuthStatus.error, error: e.toString());
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

      state = const AppAuthState(status: AuthStatus.unauthenticated);
      log.i('Logout successful');
    } catch (e) {
      log.e('Logout error: $e');
    }
  }

  void clearError() {
    state = state.copyWith(status: AuthStatus.unauthenticated, error: null);
  }
}
