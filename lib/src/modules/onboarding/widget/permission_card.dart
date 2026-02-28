import 'package:flutter/material.dart';
import '../model/permission_type.dart';
import '../../../utils/extensions/extensions.dart';

class PermissionCard extends StatelessWidget {
  final PermissionType type;
  final bool isGranted;
  final VoidCallback onToggle;

  const PermissionCard({
    super.key,
    required this.type,
    required this.isGranted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2434),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGranted 
              ? Colors.green.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getGradientColors(),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    type.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Title and optional badge
              Expanded(
                child: Row(
                  children: [
                    Text(
                      type.title,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (type.isOptional) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'OPTIONAL',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Toggle
              Switch(
                value: isGranted,
                onChanged: (_) => onToggle(),
                activeColor: Colors.green,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Description
          Text(
            type.description,
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Additional info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              type.additionalInfo,
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (type) {
      case PermissionType.notifications:
        return [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)];
      case PermissionType.camera:
        return [const Color(0xFF3B82F6), const Color(0xFF60A5FA)];
      case PermissionType.contacts:
        return [const Color(0xFF10B981), const Color(0xFF34D399)];
    }
  }
}