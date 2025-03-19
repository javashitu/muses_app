import 'package:logger/logger.dart';

class CommonLogger {
  CommonLogger._single();

  static final CommonLogger commonLogger = CommonLogger._single();

  factory CommonLogger() => commonLogger;

  var logger = Logger(level: Level.info);

  void info(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    print(message);
    // logger.i(message, time: time, error: error, stackTrace: stackTrace);
  }
}

var log = CommonLogger();
