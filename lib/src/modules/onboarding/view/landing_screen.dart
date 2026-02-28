import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitstack/src/modules/onboarding/widget/gradient_bg.dart';
import 'onboarding_screen.dart';
import '../../../utils/extensions/extensions.dart';
import '../../../utils/themes/themes.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Logo and branding
                    _buildBranding(context),
                    
                    const SizedBox(height: 32),
                    
                    // Preview mockup
                    _buildPreview(context),
                    
                    const Spacer(),
                    
                    // Features
                    _buildFeatures(context),
                    
                    const SizedBox(height: 32),
                    
                    // CTA Button
                    _buildCTA(context),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranding(BuildContext context) {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Center(
            child: Text('📚', style: TextStyle(fontSize: 50)),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Title
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              'HabitStack',
              style: context.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Tagline
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Social media that makes you better',
            style: context.textTheme.titleLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mock post 1
            _MockPost(
              username: '@sarah_fit',
              streak: '45 days 🔥',
              likes: '+127',
              avatar: '🟣',
            ),
            
            const Divider(height: 1, color: Colors.white10),
            
            // Mock post 2
            _MockPost(
              username: '@mike_reads',
              streak: '30 days 🔥',
              likes: '',
              avatar: '🔵',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A).withOpacity(0.6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          _FeatureItem(icon: '🎯', label: 'Track Habits'),
          _FeatureItem(icon: '👥', label: 'Stay Accountable'),
          _FeatureItem(icon: '🚀', label: 'Get Motivated'),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            context.push(const OnboardingScreen());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: kPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Get Started',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MockPost extends StatelessWidget {
  final String username;
  final String streak;
  final String likes;
  final String avatar;

  const _MockPost({
    required this.username,
    required this.streak,
    required this.likes,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColor, kSecondaryColor],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(avatar, style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (likes.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '❤️ $likes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kPrimaryColor.withOpacity(0.3),
                  kSecondaryColor.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            streak,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}