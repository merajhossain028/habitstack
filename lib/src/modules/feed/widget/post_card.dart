import 'package:flutter/material.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../utils/themes/themes.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onBookmark;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    // Extract data safely
    final user = post['users'];
    final habit = post['habits'];
    final userName = user?['name'] ?? 'Unknown User';
    final avatarUrl = user?['avatar_url'];
    final habitName = habit?['name'] ?? 'Habit';
    final habitIcon = habit?['icon'] ?? '📌';
    final caption = post['content'] ?? '';
    final photoUrl = post['photo_url'] ?? '';
    final likesCount = post['likes_count'] ?? 0;
    final commentsCount = post['comments_count'] ?? 0;
    final createdAt = DateTime.parse(post['created_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: User info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: kPrimaryColor.withOpacity(0.2),
                  backgroundImage: avatarUrl != null
                      ? FastCachedImageProvider(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? Text(
                          userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // Name and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        timeago.format(createdAt),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // More menu
                IconButton(
                  onPressed: () {
                    // TODO: Show options menu
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // Photo
          if (photoUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 1,
              child: FastCachedImage(
                url: photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, exception, stackTrace) {
                  return Container(
                    color: const Color(0xFF2D3446),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white30,
                        size: 48,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, progress) {
                  return Container(
                    color: const Color(0xFF2D3446),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Habit badge and streak
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Habit badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        habitIcon,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        habitName,
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Streak badge (placeholder - will fetch real streak later)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🔥',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '7 days', // TODO: Calculate real streak
                        style: TextStyle(
                          color: Colors.orange[300],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Caption
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                caption,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Actions: Like, Comment, Bookmark
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: onLike,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$likesCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Comment button
                GestureDetector(
                  onTap: onComment,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$commentsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Bookmark button
                GestureDetector(
                  onTap: onBookmark,
                  child: const Icon(
                    Icons.bookmark_border,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}