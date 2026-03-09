import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/create_post_provider.dart';
import '../../camera/view/camera_screen.dart';
import '../../../utils/themes/themes.dart';

class CameraControls extends ConsumerWidget {
  const CameraControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Flip/Retake Button (Left)
        _buildControlButton(
          icon: Icons.refresh_rounded,
          onTap: () {
            // Reset/retake photo
            ref.read(createPostProvider.notifier).reset();
          },
        ),

        // Camera Button (Center - Large)
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CameraScreen(),
              ),
            );

            if (result != null && result is Map) {
              if (result['source'] == 'camera') {
                ref.read(createPostProvider.notifier).setImageFromCamera(
                      result['path'],
                      result['timestamp'],
                    );
              } else if (result['source'] == 'gallery') {
                ref.read(createPostProvider.notifier).pickImageFromGallery();
              }
            }
          },
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [kPrimaryColor, kSecondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),

        // Gallery Button (Right)
        _buildControlButton(
          icon: Icons.photo_library_outlined,
          onTap: () {
            ref.read(createPostProvider.notifier).pickImageFromGallery();
          },
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF2D3446),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}