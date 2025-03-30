import 'package:logger/logger.dart';
import '../../util/common_logger.dart';

class FuncUtils{
    static void executeQuietly(Function func) {
    log.info("quietly execute func begin ");
    try {
      func();
      log.info("quietly execute func end ");
    } catch (error, stackTrace) {
      log.info("quietly execute func error ");

      log.info(
          "execute func catch error $error \r\n and the trace $stackTrace");
    }
  }

}