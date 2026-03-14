import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/themes/themes.dart';
import '../provider/feed_provider.dart';
import '../widget/post_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0E1A),
            elevation: 0,
            floating: true,
            snap: true,
            title: const Text(
              'HabitStack',
              style: TextStyle(
                color: kPrimaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: Navigate to notifications
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Feed Content
          if (feedState.isLoading && feedState.posts.isEmpty)
            // Loading state
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              ),
            )
          else if (feedState.error != null)
            // Error state
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      feedState.error!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(feedProvider.notifier).fetchPosts();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (feedState.posts.isEmpty)
            // Empty state
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white30,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No posts yet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to share your habit!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Posts list with pull-to-refresh
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = feedState.posts[index];
                  return PostCard(
                    post: post,
                    onLike: () {
                      ref.read(feedProvider.notifier).toggleLike(post['id']);
                    },
                    onComment: () {
                      // TODO: Open comments sheet
                    },
                    onBookmark: () {
                      // TODO: Bookmark post
                    },
                  );
                }, childCount: feedState.posts.length),
              ),
            ),
        ],
      ),
    );
  }
}
