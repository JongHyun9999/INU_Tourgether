import 'package:logger/logger.dart';

// Logger를 전역적으로 사용할 수 있도록 해주는 class.
class Log {
  static var logger = Logger(
    printer: PrettyPrinter(),
  );
}
