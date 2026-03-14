import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/supabase_service.dart';
import '../../../utils/logger/logger_helper.dart';

// Feed State
class FeedState {
  final List<Map<String, dynamic>> posts;
  final Set<String> likedPostIds;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  const FeedState({
    this.posts = const [],
    this.likedPostIds = const {},
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  FeedState copyWith({
    List<Map<String, dynamic>>? posts,
    Set<String>? likedPostIds,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      likedPostIds: likedPostIds ?? this.likedPostIds,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
    );
  }
}

// Feed Provider
final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>(
  (ref) => FeedNotifier(),
);

class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier() : super(const FeedState()) {
    fetchPosts();
  }

  final SupabaseService _supabase = SupabaseService.instance;

  // Fetch posts from Supabase
  Future<void> fetchPosts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch posts
      final response = await _supabase.client
          .from('posts')
          .select('''
            *,
            users:user_id (
              id,
              name,
              avatar_url
            ),
            habits:habit_id (
              name,
              icon,
              color
            )
          ''')
          .eq('is_public', true)
          .order('created_at', ascending: false)
          .limit(20);

      // Fetch user's liked posts
      final likedPostIds = await _supabase.getUserLikedPosts();

      log.i('Feed posts fetched: ${response.length} posts');
      log.i('User has liked: ${likedPostIds.length} posts');

      state = state.copyWith(
        posts: List<Map<String, dynamic>>.from(response),
        likedPostIds: likedPostIds, // ✅ ADD THIS
        isLoading: false,
      );
    } catch (e) {
      log.e('Fetch posts error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load posts. Please try again.',
      );
    }
  }

  // Refresh posts (pull-to-refresh)
  Future<void> refreshPosts() async {
    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final response = await _supabase.client
          .from('posts')
          .select('''
            *,
            users:user_id (
              id,
              name,
              avatar_url
            ),
            habits:habit_id (
              name,
              icon,
              color
            )
          ''')
          .eq('is_public', true)
          .order('created_at', ascending: false)
          .limit(20);

      // Fetch user's liked posts
      final likedPostIds = await _supabase.getUserLikedPosts();

      log.i('Feed refreshed: ${response.length} posts');

      state = state.copyWith(
        posts: List<Map<String, dynamic>>.from(response),
        likedPostIds: likedPostIds,
        isRefreshing: false,
      );
    } catch (e) {
      log.e('Refresh posts error: $e');
      state = state.copyWith(
        isRefreshing: false,
        error: 'Failed to refresh posts.',
      );
    }
  }

  // Toggle like
  Future<void> toggleLike(String postId) async {
    final isLiked = state.likedPostIds.contains(postId);

    // Optimistic update - update UI immediately
    final updatedLikedIds = Set<String>.from(state.likedPostIds);
    final updatedPosts = state.posts.map((post) {
      if (post['id'] == postId) {
        final currentLikes = post['likes_count'] as int;
        return {
          ...post,
          'likes_count': isLiked ? currentLikes - 1 : currentLikes + 1,
        };
      }
      return post;
    }).toList();

    if (isLiked) {
      updatedLikedIds.remove(postId);
    } else {
      updatedLikedIds.add(postId);
    }

    // Update state optimistically
    state = state.copyWith(posts: updatedPosts, likedPostIds: updatedLikedIds);

    // Perform actual database operation
    try {
      if (isLiked) {
        await _supabase.unlikePost(postId);
        log.i('Unliked post: $postId');
      } else {
        await _supabase.likePost(postId);
        log.i('Liked post: $postId');
      }
    } catch (e) {
      log.e('Toggle like error: $e');

      // Revert optimistic update on error
      final revertedLikedIds = Set<String>.from(state.likedPostIds);
      final revertedPosts = state.posts.map((post) {
        if (post['id'] == postId) {
          final currentLikes = post['likes_count'] as int;
          return {
            ...post,
            'likes_count': isLiked ? currentLikes + 1 : currentLikes - 1,
          };
        }
        return post;
      }).toList();

      if (isLiked) {
        revertedLikedIds.add(postId);
      } else {
        revertedLikedIds.remove(postId);
      }

      state = state.copyWith(
        posts: revertedPosts,
        likedPostIds: revertedLikedIds,
      );
    }
  }
}
