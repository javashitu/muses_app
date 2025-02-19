import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:muses_app/models/index.dart';

import '../common/global.dart';
import '../util/common_logger.dart';

class VideoRestClient {
  String userId = UserMock.getUser().userId;
  String userName = UserMock.getUser().userName;
  // late String userId;
  // late String userName;

  Future<List<VideoProgramInfo>> listVideo() async {
    String path = "/muses/program/video/recommend";

    Dio dio = Dio(BaseOptions(
      baseUrl: DomainConfig.musesBizDomain,
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
    ));
    var response = await dio.post(path, data: {'userId': userId});
    log.info('Response status: ${response.statusCode}');
    log.info('Response body: ${response.data}');
    if (response.data["code"] != "0") {
      log.info("request failure, error code  ${response.data['code']}");
    }
    List<VideoProgramInfo> videoProgramList = [];
    for (var item in response.data["data"]["videoProgramInfoList"]) {
      log.info('will deserialize to videoProgramInfo json is : $item');

      VideoProgramInfo videoProgramInfo = VideoProgramInfo.fromJson(item);
      videoProgramList.add(videoProgramInfo);
    }
    return videoProgramList;
  }

  Future<String> uploadVideo(PlatformFile platformFile) async {
    String path = "/api/media/upload";
    Dio dio = Dio(BaseOptions(
      baseUrl: DomainConfig.musesEngineDomain,
      headers: {
        HttpHeaders.contentTypeHeader: "multipart/form-data",
      },
    ));

    List<int> data = platformFile.bytes!;
    var partFile = MultipartFile.fromBytes(data, filename: platformFile.name);

    FormData formData = FormData.fromMap({
      "file": partFile,
      "userId": userId,
      "userName": userName,
    });

    Response response = await dio.post(
      path,
      data: formData,
      // onSendProgress: (int sent, int total) {
      //   log.info("has send $sent $total");
      //   // 可以在这里更新UI以显示上传进度
      // },
    );

    log.info("uplaod video response is $response");
    if (response.statusCode == 200) {
      log.info("upload video request success");
      // 处理服务器响应
      UploadFileResponse uploadFileResponse =
          UploadFileResponse.fromJson(response.data["data"]);
      return uploadFileResponse.id;
    } else {
      log.info("upload video request failure");
    }
    log.info("the upload response $response");
    throw Exception("upload video request failure, no video id");
  }

  void pubVideo(String title, String desc, String videoStroeId) async {
    log.info("begin pub viddeo");

    String path = "/muses/program/video/pub";
    Dio dio = Dio(BaseOptions(
      baseUrl: DomainConfig.musesBizDomain,
      sendTimeout: const Duration(seconds: 3),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      },
    ));

    PubVideoRequest pubVideoRequest = PubVideoRequest();
    pubVideoRequest.title = title;
    pubVideoRequest.description = desc;
    pubVideoRequest.userId = userId;
    pubVideoRequest.videoFileInfo = {
      "videoStoreId": videoStroeId,
    };
    pubVideoRequest.themeList = [];
    pubVideoRequest.pubTime = 0;
    pubVideoRequest.relevanceId = "";
    pubVideoRequest.createType = "self";
    pubVideoRequest.programType = "shortVideo";

    Response response = await dio.post(
      path,
      data: pubVideoRequest,
    );
    log.info("pub video finished");

    if (response.statusCode == 200) {
      log.info("pub video success");
    } else {
      log.info("pub video failure");
    }
  }

  Future<PubLiveResponse> pubLive() async {
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
      return PubLiveResponse.fromJson(response.data["data"]);
    } else {
      log.info("pub video failure");
    }
    throw Exception("pub live request failure");
  }

  Future<QueryLiveResponse> queryLive(String liveProgramId) async {
    log.info("begin query live");

    String path = "/muses/program/live/query";
    Dio dio = Dio(BaseOptions(
      baseUrl: DomainConfig.musesBizDomain,
      sendTimeout: const Duration(seconds: 3),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      },
    ));

    QueryLiveRequest pubVideoRequest = QueryLiveRequest();
    pubVideoRequest.userId = userId;
    pubVideoRequest.liveProgramId = liveProgramId;

    Response response = await dio.post(
      path,
      data: pubVideoRequest,
    );
    log.info("query live finished, the response $response");
    if (response.statusCode == 200) {
      log.info("query live success,");
      return QueryLiveResponse.fromJson(response.data["data"]);
    } else {
      log.info("pub video failure");
    }
    throw Exception("pub video  request failure");
  }
}
