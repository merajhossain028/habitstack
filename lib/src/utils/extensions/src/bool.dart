extension BoolExtension on bool {
  /// Convert bool to int (1 or 0)
  int get toInt => this ? 1 : 0;

  /// Toggle boolean value
  bool get toggle => !this;
}
