extension IterableExtension<T> on Iterable<T> {
  /// Get first element or null if empty
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null if empty
  T? get lastOrNull => isEmpty ? null : last;

  /// Group by a key
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keyFunction(element);
      (map[key] ??= []).add(element);
    }
    return map;
  }

  /// Sum of all elements (for num types)
  num sum() {
    num total = 0;
    for (final element in this) {
      if (element is num) {
        total += element;
      }
    }
    return total;
  }

  /// Average of all elements (for num types)
  double average() {
    if (isEmpty) return 0;
    return sum() / length;
  }

  /// Separate into chunks of specified size
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    final list = toList();
    for (var i = 0; i < list.length; i += size) {
      chunks.add(
        list.sublist(i, i + size > list.length ? list.length : i + size),
      );
    }
    return chunks;
  }

  /// Get unique elements
  List<T> get unique => toSet().toList();

  /// Filter not null
  Iterable<T> whereNotNull() sync* {
    for (final element in this) {
      if (element != null) yield element;
    }
  }
}
