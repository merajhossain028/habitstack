import 'package:share_plus/share_plus.dart';
import '../../utils/logger/logger_helper.dart';

class ShareHelper {
  /// Share a post with habit achievement
  static Future<void> sharePost({
    required String habitName,
    required String habitIcon,
    required String userName,
    required int streakDays,
    String? caption,
    String? photoUrl,
  }) async {
    try {
      // Create share text
      final shareText = _buildShareText(
        habitName: habitName,
        habitIcon: habitIcon,
        userName: userName,
        streakDays: streakDays,
        caption: caption,
      );

      // Share text
      final result = await Share.share(
        shareText,
        subject: 'Check out my progress on HabitStack!',
      );

      // Log share status
      if (result.status == ShareResultStatus.success) {
        log.i('Post shared successfully');
      } else if (result.status == ShareResultStatus.dismissed) {
        log.i('Share dismissed by user');
      }
    } catch (e) {
      log.e('Share error: $e');
    }
  }

  /// Build formatted share text
  static String _buildShareText({
    required String habitName,
    required String habitIcon,
    required String userName,
    required int streakDays,
    String? caption,
  }) {
    final buffer = StringBuffer();

    // Main message
    buffer.writeln('🔥 $streakDays-Day Streak on HabitStack!');
    buffer.writeln('');
    
    // Habit info
    buffer.writeln('$habitIcon $habitName');
    
    // Caption if available
    if (caption != null && caption.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('"$caption"');
    }
    
    buffer.writeln('');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('');
    
    // Call to action
    buffer.writeln('Join me on HabitStack - the social habit tracker with photo-based accountability!');
    buffer.writeln('');
    buffer.writeln('📱 Track habits with photos');
    buffer.writeln('🔥 Build streaks with friends');
    buffer.writeln('💪 Stay accountable together');
    
    return buffer.toString();
  }

  /// Share with custom text
  static Future<void> shareText(String text) async {
    try {
      await Share.share(text);
      log.i('Text shared successfully');
    } catch (e) {
      log.e('Share text error: $e');
    }
  }

  /// Share achievement/milestone
  static Future<void> shareAchievement({
    required String habitName,
    required String habitIcon,
    required int milestone,
  }) async {
    try {
      final shareText = '''
🎉 Achievement Unlocked!

$habitIcon $habitName
$milestone days completed!

Consistency is key! 💪

Join me on HabitStack - build better habits together!
''';

      await Share.share(shareText);
      log.i('Achievement shared successfully');
    } catch (e) {
      log.e('Share achievement error: $e');
    }
  }
}