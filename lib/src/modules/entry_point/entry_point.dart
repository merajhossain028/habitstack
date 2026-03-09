import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitstack/src/modules/create/view/create_screen.dart';
import 'package:habitstack/src/modules/entry_point/widget/custom_navbar.dart';
import 'package:habitstack/src/modules/feed/view/feed_screen.dart';

// Provider for current tab index
final currentTabProvider = StateProvider<int>((ref) => 0);

class EntryPoint extends ConsumerWidget {
  const EntryPoint({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    // List of screens for each tab
    final screens = [
      const FeedScreen(),
      const Center(child: Text('Search Screen')), // Placeholder
      const CreateScreen(),
      const Center(child: Text('Leaderboard Screen')), // Placeholder
      const Center(child: Text('Profile Screen')), // Placeholder
      // const SearchScreen(),
      // const LeaderboardScreen(),
      // const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentTab, children: screens),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentTab,
        onTap: (index) {
          ref.read(currentTabProvider.notifier).state = index;
        },
      ),
    );
  }
}
