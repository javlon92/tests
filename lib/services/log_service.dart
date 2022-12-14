import 'package:logger/logger.dart';

import 'http_service.dart';

class Log {
  const Log._();
  static final Logger _logger = Logger(
    printer: PrettyPrinter(),
    filter: DevelopmentFilter(),
  );

  static void d(String message) {
    if (Network.isTester) _logger.d(message);
  }

  static void i(String message) {
    if (Network.isTester) _logger.i(message);
  }

  static void w(String message) {
    if (Network.isTester) _logger.w(message);
  }

  static void e(String message) {
    if (Network.isTester) _logger.e(message);
  }
}