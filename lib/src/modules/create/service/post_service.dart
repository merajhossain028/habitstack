import 'dart:io';
import '../../../api/supabase_service.dart';
import '../../../utils/logger/logger_helper.dart';

class PostService {
  final SupabaseService _supabase = SupabaseService.instance;

  /// Complete flow: Upload image → Create completion → Create post
  Future<bool> submitHabitPost({
    required String habitId,
    required File imageFile,
    required String caption,
    required String visibility, // 'public', 'friends', 'private'
  }) async {
    try {
      log.i('Starting post submission...');

      // 1. Upload image to Supabase Storage
      log.i('Uploading image...');
      final imageUrl = await _supabase.uploadImage(
        imageFile: imageFile,
        bucket: 'habits',
        path: 'completions',
      );

      if (imageUrl == null) {
        throw Exception('Image upload failed');
      }

      log.i('Image uploaded: $imageUrl');

      // 2. Create habit completion
      log.i('Creating completion...');
      final completion = await _supabase.createHabitCompletion(
        habitId: habitId,
        photoUrl: imageUrl,
        note: caption,
      );

      if (completion == null) {
        // Cleanup: delete uploaded image
        await _supabase.deleteImage(
          bucket: 'habits',
          path: imageUrl.split('/').last,
        );
        throw Exception('Completion creation failed');
      }

      log.i('Completion created: ${completion['id']}');

      // 3. Create post (if public or friends)
      if (visibility != 'private') {
        log.i('Creating post...');
        final post = await _supabase.createPost(
          habitId: habitId,
          completionId: completion['id'],
          photoUrl: imageUrl,
          content: caption,
          isPublic: visibility == 'public',
        );

        if (post == null) {
          log.w('Post creation failed, but completion exists');
        } else {
          log.i('Post created: ${post['id']}');
        }
      }

      log.i('✅ Post submission complete!');
      return true;
    } catch (e) {
      log.e('Post submission error: $e');
      return false;
    }
  }
}