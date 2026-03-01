import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitstack/src/modules/auth/widget/auth_grad_bg.dart';

import '../../../utils/extensions/extensions.dart';
import '../../../utils/themes/themes.dart';
import '../../entry_point/entry_point.dart';
import '../provider/auth_provider.dart';
import '../provider/form_validators.dart';
import '../widget/auth_text_field.dart';
import '../widget/social_button.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appAuthState = ref.watch(authProvider);
    final passwordVisible = ref.watch(passwordVisibilityProvider);
    final agreeToTerms = ref.watch(agreeToTermsProvider);

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
            content: Text(next.error ?? 'An error occurred'),
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
                // Back button
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  'Create Account',
                  style: context.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Join the habit revolution! 🚀',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 32),

                // Form
                _SignupForm(
                  passwordVisible: passwordVisible,
                  agreeToTerms: agreeToTerms,
                  isLoading: appAuthState.isLoading,
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
                        'or sign up with',
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
                        onPressed: appAuthState.isLoading
                            ? () {}
                            : () => ref
                                  .read(authProvider.notifier)
                                  .signInWithApple(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SocialButton(
                        icon: 'G',
                        label: 'Google',
                        onPressed: appAuthState.isLoading
                            ? () {}
                            : () => ref
                                  .read(authProvider.notifier)
                                  .signInWithGoogle(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Login link
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      children: [
                        TextSpan(
                          text: 'Log In',
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
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

class _SignupForm extends ConsumerWidget {
  final bool passwordVisible;
  final bool agreeToTerms;
  final bool isLoading;

  const _SignupForm({
    required this.passwordVisible,
    required this.agreeToTerms,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();

    final nameController = ref.watch(nameControllerProvider);
    final usernameController = ref.watch(usernameControllerProvider);
    final emailController = ref.watch(emailControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);

    return Form(
      key: formKey,
      child: Column(
        children: [
          // Full Name
          AuthTextField(
            controller: nameController,
            label: 'Full Name',
            hintText: 'Sarah Johnson',
            prefixIcon: Icons.person_outline,
            validator: FormValidators.validateName,
          ),

          const SizedBox(height: 20),

          // Username
          AuthTextField(
            controller: usernameController,
            label: 'Username',
            hintText: 'sarah_fit',
            prefixIcon: Icons.alternate_email,
            validator: FormValidators.validateUsername,
          ),

          const SizedBox(height: 8),

          Text(
            'This is how others will find you',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),

          // Email
          AuthTextField(
            controller: emailController,
            label: 'Email',
            hintText: 'sarah@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: FormValidators.validateEmail,
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
                ref.read(passwordVisibilityProvider.notifier).state =
                    !passwordVisible;
              },
              icon: Icon(
                passwordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'At least 8 characters',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),

          // Terms checkbox
          Row(
            children: [
              Checkbox(
                value: agreeToTerms,
                onChanged: (value) {
                  ref.read(agreeToTermsProvider.notifier).state =
                      value ?? false;
                },
                activeColor: kPrimaryColor,
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'I agree to the ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // TODO: Open terms
                          },
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // TODO: Open privacy policy
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Create Account button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (isLoading || !agreeToTerms)
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        await ref
                            .read(authProvider.notifier)
                            .signUp(
                              name: nameController.text.trim(),
                              username: usernameController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text,
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
                      'Create Account',
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
