import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/themes/themes.dart';
import '../provider/comment_provider.dart';
import '../provider/feed_provider.dart';
import 'comment_card.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  final String postId;

  const CommentsSheet({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final success = await ref
        .read(commentProvider(widget.postId).notifier)
        .addComment(content);

    if (success) {
      _commentController.clear();
      _focusNode.unfocus();
      
      // Refresh feed to update comment count
      ref.read(feedProvider.notifier).refreshPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentState = ref.watch(commentProvider(widget.postId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Comments list
          Expanded(
            child: commentState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  )
                : commentState.comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white.withOpacity(0.3),
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to comment!',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: commentState.comments.length,
                        itemBuilder: (context, index) {
                          final comment = commentState.comments[index];
                          return CommentCard(
                            comment: comment,
                            onDelete: () {
                              ref
                                  .read(commentProvider(widget.postId).notifier)
                                  .deleteComment(comment['id']);
                              
                              // Refresh feed to update comment count
                              ref.read(feedProvider.notifier).refreshPosts();
                            },
                          );
                        },
                      ),
          ),

          // Comment input
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      maxLines: null,
                      maxLength: 500,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 15,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2D3446),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Send button
                  commentState.isSubmitting
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: kPrimaryColor,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: _submitComment,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: kPrimaryColor,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: kPrimaryColor.withOpacity(0.2),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}