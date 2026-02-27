import 'package:flutter/material.dart';

// Global size variables
double topBarSize = 0;
double bottomViewPadding = 0;

/// Extension for screen size and dimensions
extension SizeExtension on BuildContext {
  // Screen dimensions (ONLY HERE)
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;
  Size get size => MediaQuery.sizeOf(this);
  
  // Responsive breakpoints
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 900;
  bool get isDesktop => width >= 900;
  
  // Responsive size helper
  double responsive({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
  
  // Safe area heights (convenience)
  double get statusBarHeight => MediaQuery.paddingOf(this).top;
  double get bottomBarHeight => MediaQuery.paddingOf(this).bottom;
  double get keyboardHeight => MediaQuery.viewInsetsOf(this).bottom;
}