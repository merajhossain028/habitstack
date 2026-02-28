import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitstack/src/modules/onboarding/widget/gradient_bg.dart';

import '../../../utils/extensions/extensions.dart';
import '../../../utils/themes/themes.dart';
import '../../entry_point/entry_point.dart';
import '../model/permission_type.dart';
import '../provider/onboarding_provider.dart';
import '../provider/permission_provider.dart';
import '../widget/permission_card.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      'A Couple Quick Things...',
                      style: context.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We need a few permissions to work properly',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Permission cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    for (final type in PermissionType.values)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PermissionCard(
                          type: type,
                          isGranted: permissions[type] ?? false,
                          onToggle: () {
                            ref
                                .read(permissionProvider.notifier)
                                .requestPermission(type);
                          },
                        ),
                      ),

                    // Privacy note
                    const SizedBox(height: 16),
                    _buildPrivacyNote(context),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              _buildButtons(context, ref),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'We respect your privacy. Your data is encrypted and never sold.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Primary button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                // Request required permissions if not granted
                await ref
                    .read(permissionProvider.notifier)
                    .requestAllRequired();

                // Complete onboarding
                await ref
                    .read(onboardingProvider.notifier)
                    .completeOnboarding();

                // Navigate to home
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const EntryPoint()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Allow & Continue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Skip button
          TextButton(
            onPressed: () async {
              await ref.read(onboardingProvider.notifier).skipOnboarding();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const EntryPoint()),
                  (route) => false,
                );
              }
            },
            child: Text(
              "I'll do this later",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
