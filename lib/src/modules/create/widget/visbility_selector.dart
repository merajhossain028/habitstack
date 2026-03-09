import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/create_post_provider.dart';
import '../../../utils/themes/themes.dart';

class VisibilitySelector extends ConsumerWidget {
  const VisibilitySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibility = ref.watch(createPostProvider).visibility;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Post Visibility',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildVisibilityOption(
                label: 'Public',
                icon: '🌍',
                value: 'public',
                isSelected: visibility == 'public',
                onTap: () {
                  ref.read(createPostProvider.notifier).setVisibility('public');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVisibilityOption(
                label: 'Friends Only',
                icon: '👥',
                value: 'friends',
                isSelected: visibility == 'friends',
                onTap: () {
                  ref.read(createPostProvider.notifier).setVisibility('friends');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVisibilityOption(
                label: 'Private',
                icon: '🔒',
                value: 'private',
                isSelected: visibility == 'private',
                onTap: () {
                  ref.read(createPostProvider.notifier).setVisibility('private');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVisibilityOption({
    required String label,
    required String icon,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : const Color(0xFF2D3446),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}