import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitstack/src/modules/feed/widget/comment_sheet.dart';
import 'package:photo_view/photo_view.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../utils/share/share_helper.dart';
import '../../../utils/themes/themes.dart';
import '../provider/feed_provider.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> post;
  final bool isLiked;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.isLiked,
  });

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
    ref.read(feedProvider.notifier).toggleLike(widget.post['id']);
  }

  void _handleShare() {
    final user = widget.post['users'];
    final habit = widget.post['habits'];
    final userName = user?['name'] ?? 'Unknown User';
    final habitName = habit?['name'] ?? 'Habit';
    final habitIcon = habit?['icon'] ?? '📌';
    final caption = widget.post['content'] ?? '';

    ShareHelper.sharePost(
      habitName: habitName,
      habitIcon: habitIcon,
      userName: userName,
      streakDays: 7, // TODO: Get actual streak
      caption: caption.isNotEmpty ? caption : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.post['users'];
    final habit = widget.post['habits'];
    final userName = user?['name'] ?? 'Unknown User';
    final avatarUrl = user?['avatar_url'];
    final habitName = habit?['name'] ?? 'Habit';
    final habitIcon = habit?['icon'] ?? '📌';
    final caption = widget.post['content'] ?? '';
    final photoUrl = widget.post['photo_url'] ?? '';
    final likesCount = widget.post['likes_count'] ?? 0;
    final commentsCount = widget.post['comments_count'] ?? 0;
    final createdAt = DateTime.parse(widget.post['created_at']);

    // Watch for like state changes
    final feedState = ref.watch(feedProvider);
    final isCurrentlyLiked = feedState.likedPostIds.contains(widget.post['id']);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0E1A),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Show more options (report, etc.)
                },
                icon: const Icon(Icons.more_vert, color: Colors.white),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                    ],
                  ),
                ),

                // Photo with pinch-to-zoom
                if (photoUrl.isNotEmpty)
                  GestureDetector(
                    onDoubleTap: () {
                      if (!isCurrentlyLiked) {
                        // Only like if not already liked
                        _handleLike();
                      }
                    },
                    child: Hero(
                      tag: 'post-${widget.post['id']}',
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        color: Colors.black,
                        child: PhotoView(
                          imageProvider: FastCachedImageProvider(photoUrl),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 3,
                          initialScale: PhotoViewComputedScale.contained,
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          loadingBuilder: (context, event) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: kPrimaryColor,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white30,
                                size: 64,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Like button
                      GestureDetector(
                        onTap: _handleLike,
                        child: Row(
                          children: [
                            ScaleTransition(
                              scale: _likeAnimation,
                              child: Icon(
                                isCurrentlyLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isCurrentlyLiked
                                    ? Colors.red
                                    : Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$likesCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Comment button
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) =>
                                CommentsSheet(postId: widget.post['id']),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$commentsCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Share button
                      GestureDetector(
                        onTap: _handleShare,
                        child: const Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // Habit badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
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
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              habitName,
                              style: const TextStyle(
                                color: kPrimaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Streak badge
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
                            const Text('🔥', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              '7 days',
                              style: TextStyle(
                                color: Colors.orange[300],
                                fontSize: 14,
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            Expanded(
                              child: Text(
                                caption,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
