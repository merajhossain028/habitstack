import 'package:flutter/material.dart';

class AuthGradientBg extends StatelessWidget {
  final Widget child;

  const AuthGradientBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            Color(0xFF6366F1), // Purple
            Color(0xFF0A0E1A), // Dark navy
          ],
          stops: [0.0, 0.6],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.transparent,
              Color(0xFF0A0E1A),
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}