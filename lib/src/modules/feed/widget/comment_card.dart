import 'package:flutter/material.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../utils/themes/themes.dart';
import '../../../api/supabase_service.dart';

class CommentCard extends StatelessWidget {
  final Map<String, dynamic> comment;
  final VoidCallback onDelete;

  const CommentCard({
    super.key,
    required this.comment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final user = comment['users'];
    final userName = user?['name'] ?? 'Unknown User';
    final avatarUrl = user?['avatar_url'];
    final content = comment['content'] ?? '';
    final createdAt = DateTime.parse(comment['created_at']);
    final commentUserId = comment['user_id'];
    final currentUserId = SupabaseService.instance.currentUser?.id;

    final isOwnComment = commentUserId == currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: kPrimaryColor.withOpacity(0.2),
            backgroundImage: avatarUrl != null
                ? FastCachedImageProvider(avatarUrl)
                : null,
            child: avatarUrl == null
                ? Text(
                    userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: kPrimaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and time
                Row(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(createdAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Comment text
                Text(
                  content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Delete button (only for own comments)
          if (isOwnComment)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1A1F2E),
                    title: const Text(
                      'Delete Comment',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Are you sure you want to delete this comment?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(
                Icons.delete_outline,
                color: Colors.white.withOpacity(0.5),
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}