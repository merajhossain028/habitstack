extension StringExtension on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize first letter of each word
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Convert to camelCase
  String get toCamelCase {
    if (isEmpty) return this;
    final words = split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return this;
    return words.first.toLowerCase() +
        words.skip(1).map((w) => w.capitalize).join();
  }

  /// Convert to snake_case
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }

  /// Convert to kebab-case
  String get toKebabCase {
    return toSnakeCase.replaceAll('_', '-');
  }

  /// Check if string is email
  bool get isEmail {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this);
  }

  /// Check if string is a valid URL
  bool get isUrl {
    return RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    ).hasMatch(this);
  }

  /// Check if string is numeric
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Check if string is empty or contains only whitespace
  bool get isBlank => trim().isEmpty;

  /// Convert string to int (null if invalid)
  int? get toInt => int.tryParse(this);

  /// Convert string to double (null if invalid)
  double? get toDouble => double.tryParse(this);
}

extension NullableStringExtension on String? {
  /// Check if string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Check if string is null or blank
  bool get isNullOrBlank => this == null || this!.isBlank;

  /// Get value or default
  String orDefault(String defaultValue) => this ?? defaultValue;
}
