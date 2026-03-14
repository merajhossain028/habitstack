import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/supabase_service.dart';
import '../../../utils/logger/logger_helper.dart';

// Feed State
class FeedState {
  final List<Map<String, dynamic>> posts;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  FeedState copyWith({
    List<Map<String, dynamic>>? posts,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
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
    // Fetch posts when provider is initialized
    fetchPosts();
  }

  final SupabaseService _supabase = SupabaseService.instance;

  // Fetch posts from Supabase
  Future<void> fetchPosts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Query posts with user and habit data
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

      log.i('Feed posts fetched: ${response.length} posts');

      state = state.copyWith(
        posts: List<Map<String, dynamic>>.from(response),
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

      log.i('Feed refreshed: ${response.length} posts');

      state = state.copyWith(
        posts: List<Map<String, dynamic>>.from(response),
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

  // Toggle like (placeholder - will implement fully later)
  void toggleLike(String postId) {
    // TODO: Implement like/unlike logic
    log.i('Like toggled for post: $postId');
  }
}