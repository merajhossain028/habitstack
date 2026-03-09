import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/create_post_provider.dart';

class CaptionInput extends ConsumerStatefulWidget {
  const CaptionInput({super.key});

  @override
  ConsumerState<CaptionInput> createState() => _CaptionInputState();
}

class _CaptionInputState extends ConsumerState<CaptionInput> {
  final TextEditingController _controller = TextEditingController();
  static const int maxLength = 280;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caption = ref.watch(createPostProvider).caption;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3446),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji icon
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Icon(
                  Icons.emoji_emotions_outlined,
                  color: Colors.white.withOpacity(0.5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Text field with WHITE background
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white, // ✅ WHITE BACKGROUND
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLength: maxLength,
                    maxLines: 4,
                    minLines: 1,
                    style: const TextStyle(
                      color: Colors.black, // ✅ BLACK TEXT
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'How did it go? Share your thoughts...',
                      hintStyle: TextStyle(
                        color: Colors.grey[600], // ✅ GREY HINT
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      ref
                          .read(createPostProvider.notifier)
                          .updateCaption(value);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Character count
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${caption.length}/$maxLength',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
