import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Get start of day (00:00:00)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day (23:59:59)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59);
  }

  /// Get start of week (Monday)
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).startOfDay;
  }

  /// Get end of week (Sunday)
  DateTime get endOfWeek {
    final daysToSunday = 7 - weekday;
    return add(Duration(days: daysToSunday)).endOfDay;
  }

  /// Get start of month
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// Get end of month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59);
  }

  /// Format date (e.g., "Jan 23, 2026")
  String get formatDate {
    return DateFormat.yMMMd().format(this);
  }

  /// Format time (e.g., "3:45 PM")
  String get formatTime {
    return DateFormat.jm().format(this);
  }

  /// Format date and time (e.g., "Jan 23, 2026 at 3:45 PM")
  String get formatDateTime {
    return DateFormat.yMMMd().add_jm().format(this);
  }

  /// Get relative time string (e.g., "2 days ago", "in 3 hours")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      final future = difference.abs();
      if (future.inDays > 365) {
        return 'in ${(future.inDays / 365).floor()} years';
      } else if (future.inDays > 30) {
        return 'in ${(future.inDays / 30).floor()} months';
      } else if (future.inDays > 0) {
        return 'in ${future.inDays} days';
      } else if (future.inHours > 0) {
        return 'in ${future.inHours} hours';
      } else if (future.inMinutes > 0) {
        return 'in ${future.inMinutes} minutes';
      } else {
        return 'in a few seconds';
      }
    } else {
      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} years ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'just now';
      }
    }
  }

  /// Get weekday name (e.g., "Monday")
  String get weekdayName {
    return DateFormat.EEEE().format(this);
  }

  /// Get short weekday name (e.g., "Mon")
  String get weekdayShort {
    return DateFormat.E().format(this);
  }

  /// Get month name (e.g., "January")
  String get monthName {
    return DateFormat.MMMM().format(this);
  }

  /// Get short month name (e.g., "Jan")
  String get monthShort {
    return DateFormat.MMM().format(this);
  }

  /// Days between this and another date
  int daysUntil(DateTime other) {
    return other.difference(this).inDays;
  }

  /// Check if same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Copy with specific components
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}
