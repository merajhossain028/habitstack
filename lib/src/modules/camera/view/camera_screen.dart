import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitstack/src/modules/camera/view/image_preview.dart';

import '../../../utils/themes/themes.dart';
import '../provider/camera_provider.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await ref.read(availableCamerasProvider.future);
    if (cameras.isNotEmpty) {
      await ref.read(cameraProvider.notifier).initializeCamera(cameras, 0);
    }
  }

  @override
  void dispose() {
    ref.read(cameraProvider.notifier).state.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);
    final controller = cameraState.controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          if (controller != null && cameraState.isInitialized)
            Center(child: CameraPreview(controller))
          else
            const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            ),

          // Top Controls
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),

                      // Flash button
                      IconButton(
                        onPressed: () {
                          ref.read(cameraProvider.notifier).toggleFlash();
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getFlashIcon(cameraState.flashMode),
                            color: cameraState.flashMode == FlashMode.off
                                ? Colors.white
                                : Colors.yellow,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Bottom Controls
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery button
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context, {'source': 'gallery'});
                        },
                        icon: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),

                      // Capture button
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [kPrimaryColor, kSecondaryColor],
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),

                      // Flip camera button
                      ref
                          .watch(availableCamerasProvider)
                          .when(
                            data: (cameras) => IconButton(
                              onPressed: cameras.length > 1
                                  ? () {
                                      ref
                                          .read(cameraProvider.notifier)
                                          .flipCamera(cameras);
                                    }
                                  : null,
                              icon: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.flip_camera_android,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            loading: () => const SizedBox(width: 50),
                            error: (_, __) => const SizedBox(width: 50),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFlashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  Future<void> _takePicture() async {
    final imagePath = await ref.read(cameraProvider.notifier).takePicture();

    if (imagePath != null && mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImagePreviewScreen(imagePath: imagePath),
        ),
      );

      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    }
  }
}
