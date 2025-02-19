import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';

import '../common/global.dart';
import '../models/liveProgramInfo.dart';
import '../models/pubLiveRequest.dart';
import '../util/common_logger.dart';

class LiveRestClient {
  LiveRestClient.random() {
    User user = UserMock.randomUser();
    userId = user.userId;
    userName = user.userName;
  }

  late String userId;
  late String userName;

  Future<List<LiveProgramInfo>> listActiveLiveProgram(int pageNum) async {
    String path = "/muses/program/live/list/other";

    Dio dio = Dio(BaseOptions(
      baseUrl: DomainConfig.musesBizDomain,
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
    ));
    var response =
        await dio.post(path, data: {'userId': userId, 'pageNum': pageNum});
    log.info('Response status: ${response.statusCode}');
    log.info('Response body: ${response.data}');
    if (response.data["code"] != "0") {
      log.info("request failure, error code ${response.data['code']}");
    }
    List<LiveProgramInfo> liveProgramList = [];
    if (response.data["data"]["liveProgramInfoList"] == null) {
      log.info("liveProgramInfoList is null, no active live");
      return liveProgramList;
    }
    for (var item in response.data["data"]["liveProgramInfoList"]) {
      LiveProgramInfo liveProgramInfo = LiveProgramInfo.fromJson(item);
      log.info('liveProgramInfo json is : ${liveProgramInfo.toJson()}');
      liveProgramList.add(liveProgramInfo);
    }
    return liveProgramList;
  }

  Future<LiveProgramInfo> pubLive() async {
    log.info("begin pub live");

    String path = "/muses/program/live/pub";
    Dio dio = Dio(BaseOptions(
      baseUrl: DomainConfig.musesBizDomain,
      sendTimeout: const Duration(seconds: 3),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      },
    ));

    PubLiveRequest pubVideoRequest = PubLiveRequest();
    pubVideoRequest.userId = userId;
    pubVideoRequest.roomName = "$userId的直播间";
    pubVideoRequest.roomDesc = "$userId的直播间";
    pubVideoRequest.type = "mobileVideo";
    pubVideoRequest.partition = "game";
    pubVideoRequest.cover = "lol";

    Response response = await dio.post(
      path,
      data: pubVideoRequest,
    );
    log.info("pub video finished, the response $response");
    if (response.statusCode == 200) {
      log.info("pub video success,");
      return LiveProgramInfo.fromJson(response.data["data"]["liveProgramInfo"]);
    } else {
      log.info("pub video failure");
    }
    throw Exception("pub live request failure");
  }
}
