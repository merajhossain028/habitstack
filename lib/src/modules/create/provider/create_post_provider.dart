import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../service/post_service.dart';
import '../../../utils/logger/logger_helper.dart';

// State for create post
class CreatePostState {
  final String? selectedHabit;
  final String? selectedHabitId; 
  final File? image;
  final String caption;
  final String visibility;
  final String imageSource;
  final DateTime? captureTime;
  final bool isSubmitting; 
  final String? error; 

  const CreatePostState({
    this.selectedHabit,
    this.selectedHabitId,
    this.image,
    this.caption = '',
    this.visibility = 'public',
    this.imageSource = '',
    this.captureTime,
    this.isSubmitting = false, 
    this.error, 
  });

  CreatePostState copyWith({
    String? selectedHabit,
    String? selectedHabitId, 
    File? image,
    String? caption,
    String? visibility,
    String? imageSource,
    DateTime? captureTime,
    bool? isSubmitting, 
    String? error, 
  }) {
    return CreatePostState(
      selectedHabit: selectedHabit ?? this.selectedHabit,
      selectedHabitId: selectedHabitId ?? this.selectedHabitId, 
      image: image ?? this.image,
      caption: caption ?? this.caption,
      visibility: visibility ?? this.visibility,
      imageSource: imageSource ?? this.imageSource,
      captureTime: captureTime ?? this.captureTime,
      isSubmitting: isSubmitting ?? this.isSubmitting, 
      error: error, 
    );
  }

  // Helper to check if image is fresh (within 5 minutes)
  bool get isFreshCapture {
    if (imageSource != 'camera' || captureTime == null) return false;
    final now = DateTime.now();
    final difference = now.difference(captureTime!);
    return difference.inMinutes <= 5;
  }

  bool get canSubmit {
    return selectedHabitId != null && image != null && !isSubmitting;
  }
}

// Provider
final createPostProvider =
    StateNotifierProvider<CreatePostNotifier, CreatePostState>(
  (ref) => CreatePostNotifier(),
);

class CreatePostNotifier extends StateNotifier<CreatePostState> {
  CreatePostNotifier() : super(const CreatePostState());

  final PostService _postService = PostService(); 

  void selectHabit(String habit, String habitId) {
    state = state.copyWith(
      selectedHabit: habit,
      selectedHabitId: habitId,
    );
  }

  void setImageFromCamera(String path, DateTime timestamp) {
    state = state.copyWith(
      image: File(path),
      imageSource: 'camera',
      captureTime: timestamp,
    );
  }

  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      state = state.copyWith(
        image: File(image.path),
        imageSource: 'gallery',
        captureTime: null,
      );
    }
  }

  void updateCaption(String caption) {
    state = state.copyWith(caption: caption);
  }

  void setVisibility(String visibility) {
    state = state.copyWith(visibility: visibility);
  }

  Future<bool> submitPost() async {
    if (!state.canSubmit) return false;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final success = await _postService.submitHabitPost(
        habitId: state.selectedHabitId!,
        imageFile: state.image!,
        caption: state.caption,
        visibility: state.visibility,
      );

      if (success) {
        log.i('Post submitted successfully!');
        reset(); // Reset form after success
        return true;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          error: 'Failed to submit post. Please try again.',
        );
        return false;
      }
    } catch (e) {
      log.e('Submit post error: $e');
      state = state.copyWith(
        isSubmitting: false,
        error: 'An error occurred. Please try again.',
      );
      return false;
    }
  }

  void reset() {
    state = const CreatePostState();
  }
}