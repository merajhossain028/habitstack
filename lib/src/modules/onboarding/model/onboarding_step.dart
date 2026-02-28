import 'package:flutter/material.dart';
import 'package:habitstack/src/utils/extensions/extensions.dart';

class OnboardingStep {
  final int number;
  final String icon;
  final String title;
  final String subtitle;
  final String description;
  final Widget? illustration;

  const OnboardingStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    this.illustration,
  });

  static List<OnboardingStep> get steps => [
        OnboardingStep(
          number: 1,
          icon: '🔔',
          title: 'Get The Alert',
          subtitle: 'Daily random notification',
          description:
              "Just like BeReal - it's HabitStack Time! Random time each day to keep it authentic.",
          illustration: const _NotificationIllustration(),
        ),
        OnboardingStep(
          number: 2,
          icon: '📸',
          title: 'Post Your Habits',
          subtitle: 'Real progress, no filters',
          description:
              "Snap a photo of your habit in action. Keep it authentic - that's what makes it powerful.",
          illustration: const _CameraIllustration(),
        ),
        OnboardingStep(
          number: 3,
          icon: '👥',
          title: 'See Your Friends',
          subtitle: 'Unlock the feed',
          description:
              "Once you post, see what habits your friends are crushing. Everyone stays accountable.",
          illustration: const _FriendsIllustration(),
        ),
      ];
}

// Illustration widgets
class _NotificationIllustration extends StatelessWidget {
  const _NotificationIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('📚', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'HabitStack',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          'now',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Time to post! ⏰',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Show us your habits now',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CameraIllustration extends StatelessWidget {
  const _CameraIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/camera_placeholder.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '📸 Capture the moment',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _FriendsIllustration extends StatelessWidget {
  const _FriendsIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FriendRow(
            avatar: '🟣',
            username: '@sarah_fit',
            streak: '15 day streak 🔥',
          ),
          const SizedBox(height: 12),
          _FriendRow(
            avatar: '🔴',
            username: '@mike_reads',
            streak: '15 day streak 🔥',
          ),
          const SizedBox(height: 12),
          _FriendRow(
            avatar: '🔵',
            username: '@zen_emma',
            streak: '15 day streak 🔥',
          ),
        ],
      ),
    );
  }
}

class _FriendRow extends StatelessWidget {
  final String avatar;
  final String username;
  final String streak;

  const _FriendRow({
    required this.avatar,
    required this.username,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colorScheme.primary,
                context.colorScheme.secondary,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(avatar, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(username, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                streak,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}