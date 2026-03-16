import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/supabase_service.dart';
import '../../../utils/logger/logger_helper.dart';

// Comment State
class CommentState {
  final List<Map<String, dynamic>> comments;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const CommentState({
    this.comments = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  CommentState copyWith({
    List<Map<String, dynamic>>? comments,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

// Comment Provider Family (one instance per post)
final commentProvider = StateNotifierProvider.family<CommentNotifier, CommentState, String>(
  (ref, postId) => CommentNotifier(postId),
);

class CommentNotifier extends StateNotifier<CommentState> {
  final String postId;
  final SupabaseService _supabase = SupabaseService.instance;

  CommentNotifier(this.postId) : super(const CommentState()) {
    fetchComments();
  }

  // Fetch comments for the post
  Future<void> fetchComments() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final comments = await _supabase.getComments(postId);

      state = state.copyWith(
        comments: comments,
        isLoading: false,
      );
    } catch (e) {
      log.e('Fetch comments error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load comments',
      );
    }
  }

  // Add a new comment
  Future<bool> addComment(String content) async {
    if (content.trim().isEmpty) return false;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final newComment = await _supabase.addComment(postId, content.trim());

      if (newComment != null) {
        // Add new comment to the list
        final updatedComments = [...state.comments, newComment];

        state = state.copyWith(
          comments: updatedComments,
          isSubmitting: false,
        );

        log.i('Comment added successfully');
        return true;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          error: 'Failed to add comment',
        );
        return false;
      }
    } catch (e) {
      log.e('Add comment error: $e');
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to add comment',
      );
      return false;
    }
  }

  // Delete a comment
  Future<void> deleteComment(String commentId) async {
    try {
      final success = await _supabase.deleteComment(commentId);

      if (success) {
        // Remove comment from the list
        final updatedComments = state.comments
            .where((comment) => comment['id'] != commentId)
            .toList();

        state = state.copyWith(comments: updatedComments);
        log.i('Comment deleted successfully');
      }
    } catch (e) {
      log.e('Delete comment error: $e');
    }
  }
}