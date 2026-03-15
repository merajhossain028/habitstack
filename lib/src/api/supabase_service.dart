import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/logger/logger_helper.dart';

/// Supabase service singleton
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance!;

  late final SupabaseClient _client;
  SupabaseClient get client => _client;

  SupabaseService._();

  /// Initialize Supabase
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );

    _instance = SupabaseService._();
    _instance!._client = Supabase.instance.client;

    log.i('Supabase initialized successfully');
  }

  // ============================================================================
  // AUTH
  // ============================================================================

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Get current session
  Session? get currentSession => _client.auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign up with email
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      log.i('Attempting signup for: $email');

      // Just signup - trigger auto-creates profile!
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user');
      }

      // Profile created automatically by database trigger!
      log.i('Signup successful, profile auto-created by trigger');

      return authResponse;
    } catch (e) {
      log.e('Signup error: $e');
      rethrow;
    }
  }

  /// Sign in with email
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      log.i('User signed in: ${response.user?.email}');
      return response;
    } catch (e) {
      log.e('Sign in error: $e');
      rethrow;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.habitstack://login-callback/',
      );

      log.i('Google sign in initiated');
      return response;
    } catch (e) {
      log.e('Google sign in error: $e');
      rethrow;
    }
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.habitstack://login-callback/',
      );

      log.i('Apple sign in initiated');
      return response;
    } catch (e) {
      log.e('Apple sign in error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      log.i('User signed out');
    } catch (e) {
      log.e('Sign out error: $e');
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      log.i('Password reset email sent to: $email');
    } catch (e) {
      log.e('Reset password error: $e');
      rethrow;
    }
  }

  /// Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      log.i('Password updated');
      return response;
    } catch (e) {
      log.e('Update password error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // USER PROFILE
  // ============================================================================

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      log.e('Get user profile error: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _client.from('users').update(updates).eq('id', userId);

      log.i('User profile updated');
    } catch (e) {
      log.e('Update user profile error: $e');
      rethrow;
    }
  }

  /// Upload avatar
  Future<String> uploadAvatar({
    required String userId,
    required String filePath,
    required List<int> fileBytes,
  }) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
      final path = 'avatars/$fileName';

      await _client.storage
          .from('profiles')
          .uploadBinary(
            path,
            Uint8List.fromList(fileBytes),
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final url = _client.storage.from('profiles').getPublicUrl(path);

      log.i('Avatar uploaded: $url');
      return url;
    } catch (e) {
      log.e('Upload avatar error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // HABITS
  // ============================================================================

  /// Get user's habits
  Future<List<Map<String, dynamic>>> getHabits(String userId) async {
    try {
      final response = await _client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      log.e('Get habits error: $e');
      rethrow;
    }
  }

  /// Create habit
  Future<Map<String, dynamic>> createHabit(
    Map<String, dynamic> habitData,
  ) async {
    try {
      final response = await _client
          .from('habits')
          .insert(habitData)
          .select()
          .single();

      log.i('Habit created: ${response['id']}');
      return response;
    } catch (e) {
      log.e('Create habit error: $e');
      rethrow;
    }
  }

  /// Update habit
  Future<void> updateHabit({
    required String habitId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      await _client.from('habits').update(updates).eq('id', habitId);

      log.i('Habit updated: $habitId');
    } catch (e) {
      log.e('Update habit error: $e');
      rethrow;
    }
  }

  /// Delete habit (soft delete)
  Future<void> deleteHabit(String habitId) async {
    try {
      await _client
          .from('habits')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', habitId);

      log.i('Habit deleted: $habitId');
    } catch (e) {
      log.e('Delete habit error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // COMPLETIONS
  // ============================================================================

  /// Get completions for habit
  Future<List<Map<String, dynamic>>> getCompletions(
    String habitId, {
    int limit = 30,
  }) async {
    try {
      final response = await _client
          .from('completions')
          .select()
          .eq('habit_id', habitId)
          .order('completed_at', ascending: false)
          .limit(limit);

      return response;
    } catch (e) {
      log.e('Get completions error: $e');
      rethrow;
    }
  }

  /// Add completion
  Future<Map<String, dynamic>> addCompletion(
    Map<String, dynamic> completionData,
  ) async {
    try {
      final response = await _client
          .from('completions')
          .insert(completionData)
          .select()
          .single();

      // Update habit stats
      await _updateHabitStats(completionData['habit_id'] as String);

      log.i('Completion added: ${response['id']}');
      return response;
    } catch (e) {
      log.e('Add completion error: $e');
      rethrow;
    }
  }

  /// Delete completion
  Future<void> deleteCompletion(String completionId) async {
    try {
      await _client.from('completions').delete().eq('id', completionId);

      log.i('Completion deleted: $completionId');
    } catch (e) {
      log.e('Delete completion error: $e');
      rethrow;
    }
  }

  /// Update habit stats (streak, total completions)
  Future<void> _updateHabitStats(String habitId) async {
    try {
      // This would be a Postgres function in Supabase
      await _client.rpc('update_habit_stats', params: {'habit_id': habitId});
    } catch (e) {
      log.w('Update habit stats error: $e');
    }
  }

  /// Upload completion photo
  Future<String> uploadCompletionPhoto({
    required String completionId,
    required List<int> fileBytes,
  }) async {
    try {
      final fileName =
          '${completionId}_${DateTime.now().millisecondsSinceEpoch}';
      final path = 'completions/$fileName.jpg';

      await _client.storage
          .from('habits')
          .uploadBinary(
            path,
            Uint8List.fromList(fileBytes),
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final url = _client.storage.from('habits').getPublicUrl(path);

      log.i('Completion photo uploaded: $url');
      return url;
    } catch (e) {
      log.e('Upload completion photo error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // FRIENDS
  // ============================================================================

  /// Get friends
  Future<List<Map<String, dynamic>>> getFriends(String userId) async {
    try {
      final response = await _client
          .from('friends')
          .select('*, friend:users!friends_friend_id_fkey(*)')
          .or('user_id.eq.$userId,friend_id.eq.$userId')
          .eq('status', 'accepted');

      return response;
    } catch (e) {
      log.e('Get friends error: $e');
      rethrow;
    }
  }

  /// Send friend request
  Future<Map<String, dynamic>> sendFriendRequest({
    required String userId,
    required String friendId,
  }) async {
    try {
      final response = await _client
          .from('friends')
          .insert({
            'user_id': userId,
            'friend_id': friendId,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      log.i('Friend request sent');
      return response;
    } catch (e) {
      log.e('Send friend request error: $e');
      rethrow;
    }
  }

  /// Accept friend request
  Future<void> acceptFriendRequest(String friendshipId) async {
    try {
      await _client
          .from('friends')
          .update({
            'status': 'accepted',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', friendshipId);

      log.i('Friend request accepted');
    } catch (e) {
      log.e('Accept friend request error: $e');
      rethrow;
    }
  }

  /// Search users
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .or('name.ilike.%$query%,email.ilike.%$query%')
          .limit(20);

      return response;
    } catch (e) {
      log.e('Search users error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // SOCIAL FEED
  // ============================================================================

  /// Get feed posts
  Future<List<Map<String, dynamic>>> getFeedPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('posts')
          .select('*, user:users(*), habit:habits(*)')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response;
    } catch (e) {
      log.e('Get feed posts error: $e');
      rethrow;
    }
  }

  /// Toggle like
  Future<void> toggleLike({
    required String userId,
    required String postId,
  }) async {
    try {
      // Check if already liked
      final existing = await _client
          .from('likes')
          .select()
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();

      if (existing != null) {
        // Unlike
        await _client
            .from('likes')
            .delete()
            .eq('user_id', userId)
            .eq('post_id', postId);

        log.i('Post unliked');
      } else {
        // Like
        await _client.from('likes').insert({
          'user_id': userId,
          'post_id': postId,
          'created_at': DateTime.now().toIso8601String(),
        });

        log.i('Post liked');
      }
    } catch (e) {
      log.e('Toggle like error: $e');
      rethrow;
    }
  }

  /// Fetch comments for a post
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final response = await _client
          .from('comments')
          .select('''
          *,
          users:user_id (
            id,
            name,
            avatar_url
          )
        ''')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      log.i('Fetched ${response.length} comments for post $postId');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log.e('Fetch comments error: $e');
      return [];
    }
  }

  /// Add a comment to a post
  Future<Map<String, dynamic>?> addComment(
    String postId,
    String content,
  ) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        log.e('User not authenticated');
        return null;
      }

      final response = await _client
          .from('comments')
          .insert({'post_id': postId, 'user_id': userId, 'content': content})
          .select('''
          *,
          users:user_id (
            id,
            name,
            avatar_url
          )
        ''')
          .single();

      log.i('Comment added to post $postId');
      return response;
    } catch (e) {
      log.e('Add comment error: $e');
      return null;
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(String commentId) async {
    try {
      await _client.from('comments').delete().eq('id', commentId);

      log.i('Comment deleted: $commentId');
      return true;
    } catch (e) {
      log.e('Delete comment error: $e');
      return false;
    }
  }

  // ============================================================================
  // REALTIME
  // ============================================================================

  /// Subscribe to habit changes
  RealtimeChannel subscribeToHabits(
    String userId,
    void Function(Map<String, dynamic>) onUpdate,
  ) {
    final channel = _client
        .channel('habits-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'habits',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();

    log.i('Subscribed to habits changes');
    return channel;
  }

  /// Subscribe to friend activity
  RealtimeChannel subscribeToFriendActivity(
    String userId,
    void Function(Map<String, dynamic>) onActivity,
  ) {
    final channel = _client
        .channel('friend-activity-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'completions',
          callback: (payload) => onActivity(payload.newRecord),
        )
        .subscribe();

    log.i('Subscribed to friend activity');
    return channel;
  }

  /// Unsubscribe from channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
    log.i('Unsubscribed from channel');
  }

  Future<String?> uploadImage({
    required File imageFile,
    required String bucket,
    required String path,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$path/$fileName';

      await _client.storage
          .from(bucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: false,
            ),
          );

      // Get public URL
      final imageUrl = _client.storage.from(bucket).getPublicUrl(filePath);

      log.i('Image uploaded successfully: $imageUrl');
      return imageUrl;
    } catch (e) {
      log.e('Image upload error: $e');
      return null;
    }
  }

  // Create habit completion with post
  Future<Map<String, dynamic>?> createHabitCompletion({
    required String habitId,
    required String photoUrl,
    String? note,
    String? location,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // 1. Create completion
      final completionResponse = await _client
          .from('completions')
          .insert({
            'habit_id': habitId,
            'user_id': userId,
            'photo_url': photoUrl,
            'note': note,
            'location': location,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      log.i('Completion created: ${completionResponse['id']}');

      // 2. Update habit stats (trigger handles this automatically)

      return completionResponse;
    } catch (e) {
      log.e('Create completion error: $e');
      return null;
    }
  }

  /// Create post
  Future<Map<String, dynamic>?> createPost({
    required String habitId,
    required String? completionId,
    required String photoUrl,
    required String content,
    required bool isPublic,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final postResponse = await _client
          .from('posts')
          .insert({
            'user_id': userId,
            'habit_id': habitId,
            'completion_id': completionId,
            'content': content,
            'photo_url': photoUrl,
            'is_public': isPublic,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      log.i('Post created: ${postResponse['id']}');
      return postResponse;
    } catch (e) {
      log.e('Create post error: $e');
      return null;
    }
  }

  /// Delete image from storage
  Future<bool> deleteImage({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);
      log.i('Image deleted: $path');
      return true;
    } catch (e) {
      log.e('Delete image error: $e');
      return false;
    }
  }

  /// Like a post
  Future<bool> likePost(String postId) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        log.e('User not authenticated');
        return false;
      }

      // Insert like
      await _client.from('likes').insert({
        'post_id': postId,
        'user_id': userId,
      });

      log.i('Post liked: $postId');
      return true;
    } catch (e) {
      log.e('Like post error: $e');
      return false;
    }
  }

  /// Unlike a post
  Future<bool> unlikePost(String postId) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        log.e('User not authenticated');
        return false;
      }

      // Delete like
      await _client
          .from('likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);

      log.i('Post unliked: $postId');
      return true;
    } catch (e) {
      log.e('Unlike post error: $e');
      return false;
    }
  }

  /// Check if user has liked a post
  Future<bool> hasUserLikedPost(String postId) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return false;

      final response = await _client
          .from('likes')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      log.e('Check like status error: $e');
      return false;
    }
  }

  /// Get user's liked post IDs
  Future<Set<String>> getUserLikedPosts() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return {};

      final response = await _client
          .from('likes')
          .select('post_id')
          .eq('user_id', userId);

      final likedPostIds = <String>{};
      for (final like in response) {
        likedPostIds.add(like['post_id'] as String);
      }

      return likedPostIds;
    } catch (e) {
      log.e('Get liked posts error: $e');
      return {};
    }
  }
}
