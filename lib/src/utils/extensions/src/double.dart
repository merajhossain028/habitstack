import 'dart:math';  // ✅ Required for pow, sqrt, etc.

/// Extension for double utilities
extension DoubleExtension on double {
  /// Round to specific decimal places
  double roundTo(int decimals) {
    final mod = pow(10.0, decimals).toDouble();
    return (this * mod).round() / mod;
  }

  /// Format as currency
  String toCurrency({String symbol = '\$'}) {
    return '$symbol${toStringAsFixed(2)}';
  }

  /// Format as percentage
  String toPercentage({int decimals = 0}) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }

  /// Check if number is between min and max
  bool isBetween(double min, double max) {
    return this >= min && this <= max;
  }

  /// Clamp value between min and max
  double clampValue(double min, double max) {
    return clamp(min, max).toDouble();
  }

  /// Convert to int safely
  int toIntSafe() {
    return round();
  }

  /// Check if close to another number (within tolerance)
  bool isCloseTo(double other, {double tolerance = 0.001}) {
    return (this - other).abs() < tolerance;
  }

  /// Convert to string with max decimal places
  String toStringMaxDecimals(int maxDecimals) {
    String str = toStringAsFixed(maxDecimals);
    // Remove trailing zeros
    return str.replaceAll(RegExp(r'\.?0+$'), '');
  }
}