import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> globalSnackbarKey =
    GlobalKey<ScaffoldMessengerState>();

enum SnackBarType { success, error, warning, info }

void showKSnackBar(
  String message, {
  SnackBarType type = SnackBarType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  final color = switch (type) {
    SnackBarType.success => Colors.green,
    SnackBarType.error => Colors.red,
    SnackBarType.warning => Colors.orange,
    SnackBarType.info => Colors.blue,
  };

  final icon = switch (type) {
    SnackBarType.success => Icons.check_circle,
    SnackBarType.error => Icons.error,
    SnackBarType.warning => Icons.warning,
    SnackBarType.info => Icons.info,
  };

  globalSnackbarKey.currentState?.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
    ),
  );
}
