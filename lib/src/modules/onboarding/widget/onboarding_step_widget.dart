import 'package:flutter/material.dart';
import '../model/onboarding_step.dart';
import '../../../utils/extensions/extensions.dart';

class OnboardingStepWidget extends StatelessWidget {
  final OnboardingStep step;

  const OnboardingStepWidget({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2434),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number badge and title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getGradientColors(step.number),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      step.number.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            step.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step.title,
                              style: context.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.subtitle,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Description
            Text(
              step.description,
              style: context.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
            
            // Illustration (if exists)
            if (step.illustration != null) ...[
              const SizedBox(height: 20),
              step.illustration!,
            ],
            
            // Special card for step 3
            if (step.number == 3) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      '👀',
                      style: TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "You can't see friends until\nYOU post first!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This keeps everyone accountable ✨',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors(int number) {
    switch (number) {
      case 1:
        return [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)];
      case 2:
        return [const Color(0xFF3B82F6), const Color(0xFF60A5FA)];
      case 3:
        return [const Color(0xFF10B981), const Color(0xFF34D399)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    }
  }
}