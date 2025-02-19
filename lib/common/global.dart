import 'dart:math';
import '../util/common_logger.dart';

class DomainConfig {
  static const String musesBizDomain = "http://192.168.131.24:9090";

  static const String musesEngineDomain = "http://192.168.131.24:8031";
}

class UserMock {
  static late User _user;
  static bool initFlag = false;

  static User randomUser() {
    _user = User();

    String userId = Random().nextInt(100).toString();
    String userName = "模拟用户$userId";
    _user.userId = userId;
    _user.userName = userName;
    log.info("init random user ${_user.userId}");
    return _user;
  }

  static User getUser() {
    if (!initFlag) {
      User tempUser = randomUser();
      _user = tempUser;
    }
    return _user;
  }
}

class User {
  late String userId;
  late String userName;
}
