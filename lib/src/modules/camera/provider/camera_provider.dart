import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Available cameras provider
final availableCamerasProvider = FutureProvider<List<CameraDescription>>((
  ref,
) async {
  return await availableCameras();
});

// Camera state
class CameraState {
  final CameraController? controller;
  final bool isInitialized;
  final FlashMode flashMode;
  final int currentCameraIndex;

  const CameraState({
    this.controller,
    this.isInitialized = false,
    this.flashMode = FlashMode.off,
    this.currentCameraIndex = 0,
  });

  CameraState copyWith({
    CameraController? controller,
    bool? isInitialized,
    FlashMode? flashMode,
    int? currentCameraIndex,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      flashMode: flashMode ?? this.flashMode,
      currentCameraIndex: currentCameraIndex ?? this.currentCameraIndex,
    );
  }
}

// Camera provider
final cameraProvider = StateNotifierProvider<CameraNotifier, CameraState>(
  (ref) => CameraNotifier(),
);

class CameraNotifier extends StateNotifier<CameraState> {
  CameraNotifier() : super(const CameraState());

  Future<void> initializeCamera(
    List<CameraDescription> cameras,
    int cameraIndex,
  ) async {
    if (cameras.isEmpty) return;

    final camera = cameras[cameraIndex];
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      await controller.setFlashMode(state.flashMode);

      state = state.copyWith(
        controller: controller,
        isInitialized: true,
        currentCameraIndex: cameraIndex,
      );
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<void> toggleFlash() async {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return;

    FlashMode newMode;
    switch (state.flashMode) {
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      case FlashMode.always:
        newMode = FlashMode.off;
        break;
      default:
        newMode = FlashMode.off;
    }

    await controller.setFlashMode(newMode);
    state = state.copyWith(flashMode: newMode);
  }

  Future<void> flipCamera(List<CameraDescription> cameras) async {
    if (cameras.length < 2) return;

    final newIndex = state.currentCameraIndex == 0 ? 1 : 0;

    await state.controller?.dispose();

    await initializeCamera(cameras, newIndex);
  }

  Future<String?> takePicture() async {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return null;

    try {
      final image = await controller.takePicture();
      return image.path;
    } catch (e) {
      print('Take picture error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    state.controller?.dispose();
    super.dispose();
  }
}
