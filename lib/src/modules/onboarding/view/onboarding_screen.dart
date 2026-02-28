import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitstack/src/modules/onboarding/view/permission_screen.dart';
import 'package:habitstack/src/modules/onboarding/widget/gradient_bg.dart';
import '../provider/onboarding_provider.dart';
import '../widget/onboarding_step_widget.dart';
import '../../../utils/extensions/extensions.dart';
import '../../../utils/themes/themes.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Content - Flexible to prevent overflow
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Text(
                              "Here's How It Works",
                              style: context.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "It's simple and fun! ✨",
                              style: context.textTheme.titleMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Step content
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: PageView.builder(
                          itemCount: onboardingState.steps.length,
                          onPageChanged: (index) {
                            ref.read(onboardingProvider.notifier).setPage(index);
                          },
                          itemBuilder: (context, index) {
                            return OnboardingStepWidget(
                              step: onboardingState.steps[index],
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Page indicator
                      _buildPageIndicator(context, ref, onboardingState),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              
              // Bottom button - Fixed at bottom
              Padding(
                padding: const EdgeInsets.all(24),
                child: _buildNextButton(context, ref, onboardingState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text(
            'HabitStack',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 48), // Balance
        ],
      ),
    );
  }

  Widget _buildPageIndicator(
    BuildContext context,
    WidgetRef ref,
    OnboardingState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        state.totalPages,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == state.currentPage
                ? kPrimaryColor
                : Colors.white.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(
    BuildContext context,
    WidgetRef ref,
    OnboardingState state,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (state.isLastPage) {
            context.push(const PermissionsScreen());
          } else {
            ref.read(onboardingProvider.notifier).nextPage();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          state.isLastPage ? "Let's Go!" : 'Next',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}