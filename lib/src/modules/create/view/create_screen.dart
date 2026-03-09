import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitstack/src/api/supabase_service.dart';
import 'package:habitstack/src/modules/create/widget/visbility_selector.dart';

import '../../../utils/themes/themes.dart';
import '../provider/create_post_provider.dart';
import '../widget/camera_controls.dart';
import '../widget/camera_preview_box.dart';
import '../widget/caption_input.dart';
import '../widget/habit_selector.dart';

class CreateScreen extends ConsumerWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createState = ref.watch(createPostProvider);
    debugPrint('Current User ID: ${SupabaseService.instance.currentUser?.id}');
    debugPrint('Current Email: ${SupabaseService.instance.currentUser?.email}');
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        leading: IconButton(
          onPressed: createState.isSubmitting
              ? null
              : () {
                  ref.read(createPostProvider.notifier).reset();
                },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Post Your Habit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: createState.isSubmitting
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(kPrimaryColor),
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: createState.canSubmit
                        ? () => _submitPost(context, ref)
                        : null,
                    style: TextButton.styleFrom(
                      backgroundColor: createState.canSubmit
                          ? kPrimaryColor
                          : Colors.grey.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Post',
                      style: TextStyle(
                        color: createState.canSubmit
                            ? Colors.white
                            : Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error message
            if (createState.error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        createState.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Habit Selector
            const HabitSelector(),

            const SizedBox(height: 24),

            // Camera Preview
            const CameraPreviewBox(),

            const SizedBox(height: 24),

            // Camera Controls
            const CameraControls(),

            const SizedBox(height: 24),

            // Caption Input
            const CaptionInput(),

            const SizedBox(height: 24),

            // Visibility Selector
            const VisibilitySelector(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPost(BuildContext context, WidgetRef ref) async {
    // Show loading
    final success = await ref.read(createPostProvider.notifier).submitPost();

    if (success && context.mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Habit posted successfully! 🎉'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Navigate back to feed (optional)
      // Navigator.pop(context);
    }
  }
}
