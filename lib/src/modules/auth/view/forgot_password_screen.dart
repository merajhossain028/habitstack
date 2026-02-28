import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitstack/src/modules/auth/widget/auth_grad_bg.dart';
import '../provider/auth_provider.dart';
import '../provider/form_validators.dart';
import '../widget/auth_text_field.dart';
import '../../../utils/extensions/extensions.dart';
import '../../../utils/themes/themes.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final formKey = GlobalKey<FormState>();
    bool emailSent = false;

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
                
                const SizedBox(height: 40),
                
                // Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 50,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Forgot Password?',
                  style: context.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  "No worries! Enter your email and we'll send you reset instructions.",
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Form
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      AuthTextField(
                        label: 'Email',
                        hintText: 'sarah@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: FormValidators.validateEmail,
                        onChanged: (value) => ref.read(emailProvider.notifier).state = value,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: authState.isLoading
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    try {
                                      await ref.read(authProvider.notifier)
                                          .resetPassword(ref.read(emailProvider));
                                      
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Reset link sent! Check your email.'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        context.pop();
                                      }
                                    } catch (e) {
                                      // Error handled in provider
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Send Reset Link',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}