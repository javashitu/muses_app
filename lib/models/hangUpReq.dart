import 'package:json_annotation/json_annotation.dart';

part 'hangUpReq.g.dart';

@JsonSerializable()
class HangUpReq {
  HangUpReq();

  late String protoType;
  late String roomId;
  late String userId;
  late String userName;
  late bool pubStreamFlag;
  late String streamId;
  
  factory HangUpReq.fromJson(Map<String,dynamic> json) => _$HangUpReqFromJson(json);
  Map<String, dynamic> toJson() => _$HangUpReqToJson(this);
}
