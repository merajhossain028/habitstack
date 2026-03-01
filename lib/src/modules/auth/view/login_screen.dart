import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitstack/src/modules/auth/widget/auth_grad_bg.dart';
import '../provider/auth_provider.dart';
import '../provider/form_validators.dart';
import '../widget/auth_text_field.dart';
import '../widget/social_button.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../../entry_point/entry_point.dart';
import '../../../utils/extensions/extensions.dart';
import '../../../utils/themes/themes.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final passwordVisible = ref.watch(passwordVisibilityProvider);
    final rememberMe = ref.watch(rememberMeProvider);

    // Listen to auth state changes
    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const EntryPoint()),
          (route) => false,
        );
      } else if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: AuthGradientBg(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Text('📚', style: TextStyle(fontSize: 50)),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Center(
                  child: Text(
                    'Welcome Back',
                    style: context.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Center(
                  child: Text(
                    'Ready to crush your habits today? 💪',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Form
                _LoginForm(
                  passwordVisible: passwordVisible,
                  rememberMe: rememberMe,
                  isLoading: authState.isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.white.withOpacity(0.2)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or continue with',
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.white.withOpacity(0.2)),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Social buttons
                Row(
                  children: [
                    Expanded(
                      child: SocialButton(
                        icon: '🍎',
                        label: 'Apple',
                        onPressed: authState.isLoading
                            ? () {}
                            : () => ref.read(authProvider.notifier).signInWithApple(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SocialButton(
                        icon: 'G',
                        label: 'Google',
                        onPressed: authState.isLoading
                            ? () {}
                            : () => ref.read(authProvider.notifier).signInWithGoogle(),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Demo account
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kPrimaryColor.withOpacity(0.2),
                        kSecondaryColor.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: kPrimaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Want to explore first?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Try our demo account with sample data',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: authState.isLoading
                              ? null
                              : () => ref.read(authProvider.notifier).signInAsDemo(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E2434),
                            side: BorderSide(
                              color: kPrimaryColor.withOpacity(0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Continue as Demo User',
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Signup link
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
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

class _LoginForm extends ConsumerWidget {
  final bool passwordVisible;
  final bool rememberMe;
  final bool isLoading;

  const _LoginForm({
    required this.passwordVisible,
    required this.rememberMe,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final emailController = ref.watch(emailControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);

    return Form(
      key: formKey,
      child: Column(
        children: [
          // Email or Username
          AuthTextField(
            controller: emailController,
            label: 'Email or Username',
            hintText: 'sarah@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: FormValidators.validateEmailOrUsername,
          ),
          
          const SizedBox(height: 20),
          
          // Password
          AuthTextField(
            controller: passwordController,
            label: 'Password',
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: passwordVisible,
            validator: FormValidators.validatePassword,
            suffixIcon: IconButton(
              onPressed: () {
                ref.read(passwordVisibilityProvider.notifier).state = !passwordVisible;
              },
              icon: Icon(
                passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Remember me & Forgot password
          Row(
            children: [
              Checkbox(
                value: rememberMe,
                onChanged: (value) {
                  ref.read(rememberMeProvider.notifier).state = value ?? false;
                },
                activeColor: kPrimaryColor,
                side: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              Text(
                'Remember me',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.push(const ForgotPasswordScreen());
                },
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Login button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        await ref.read(authProvider.notifier).signIn(
                              emailOrUsername: emailController.text.trim(),
                              password: passwordController.text,
                              rememberMe: rememberMe,
                            );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                disabledBackgroundColor: kPrimaryColor.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}