import 'package:json_annotation/json_annotation.dart';

part 'enterRsp.g.dart';

@JsonSerializable()
class EnterRsp {
  EnterRsp();

  late String protoType;
  late String roomId;
  late String userId;
  late List otherUsers;
  late Map<String,dynamic> peerConfig;
  late Map<String,dynamic> constraints;
  late Map<String,dynamic> flutterRtcMediaConf;
  late Map<String,dynamic> userPubMap;
  late bool anchorFlag;
  
  factory EnterRsp.fromJson(Map<String,dynamic> json) => _$EnterRspFromJson(json);
  Map<String, dynamic> toJson() => _$EnterRspToJson(this);
}
