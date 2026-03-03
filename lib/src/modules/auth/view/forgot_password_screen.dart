import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitstack/src/modules/auth/widget/auth_grad_bg.dart';

import '../../../utils/extensions/extensions.dart';
import '../../../utils/themes/themes.dart';
import '../provider/auth_provider.dart';
import '../provider/form_validators.dart';
import '../widget/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appAuthState = ref.watch(authProvider);
    final formKey = GlobalKey<FormState>();
    final emailController = ref.watch(emailControllerProvider);

    return Scaffold(
      body: AuthGradientBg(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    48,
              ),
              child: IntrinsicHeight(
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
                            controller: emailController,
                            label: 'Email',
                            hintText: 'sarah@example.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: FormValidators.validateEmail,
                          ),

                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: appAuthState.isLoading
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        try {
                                          await ref
                                              .read(authProvider.notifier)
                                              .resetPassword(
                                                emailController.text.trim(),
                                              );

                                          if (context.mounted) {
                                            // ✅ Show detailed dialog instead of SnackBar
                                            _showSuccessDialog(
                                              context,
                                              emailController.text,
                                            );
                                          }
                                        } catch (e) {
                                          // Error handled in provider
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                disabledBackgroundColor: kPrimaryColor
                                    .withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: appAuthState.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white,
                                        ),
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

                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Success dialog with clear instructions
  void _showSuccessDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2434),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.mark_email_read_outlined, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text('Email Sent!', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password reset link sent to:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email, color: kPrimaryColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        email,
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.list_alt, color: kPrimaryColor, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Next steps:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInstruction(
                      '1',
                      'Check your email inbox',
                      Icons.inbox,
                    ),
                    const SizedBox(height: 12),
                    _buildInstruction('2', 'Click the reset link', Icons.link),
                    const SizedBox(height: 12),
                    _buildInstruction(
                      '3',
                      'Enter your new password',
                      Icons.lock_reset,
                    ),
                    const SizedBox(height: 12),
                    _buildInstruction(
                      '4',
                      'Return here to log in',
                      Icons.login,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tip box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Check spam folder if not in inbox',
                        style: TextStyle(
                          color: Colors.orange.shade200,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to login
            },
            style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
            child: const Text(
              'OK, Got It',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Helper widget for instruction steps
  Widget _buildInstruction(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimaryColor, kSecondaryColor],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: Colors.white.withOpacity(0.6), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
