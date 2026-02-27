import 'package:logger/logger.dart';

/// Global logger instance
final log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// Production logger (minimal logging)
final prodLog = Logger(
  printer: SimplePrinter(colors: false),
  level: Level.warning,
);
