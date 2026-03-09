import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/create_post_provider.dart';

class CameraPreviewBox extends ConsumerWidget {
  const CameraPreviewBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createState = ref.watch(createPostProvider);
    final image = createState.image;

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF2D3446),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Image or Placeholder
          if (image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Take a photo or select from gallery',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Timestamp Badge
          if (image != null)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      createState.imageSource == 'camera'
                          ? Icons.camera_alt
                          : Icons.photo_library,
                      size: 16,
                      color: createState.isFreshCapture
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      createState.imageSource == 'camera'
                          ? (createState.isFreshCapture
                                ? 'Just now'
                                : 'Recently')
                          : 'From gallery',
                      style: TextStyle(
                        color: createState.isFreshCapture
                            ? Colors.green
                            : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Remove button
          if (image != null)
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  ref.read(createPostProvider.notifier).reset();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
