import 'package:json_annotation/json_annotation.dart';

part 'negoReq.g.dart';

@JsonSerializable()
class NegoReq {
  NegoReq();

  late String protoType;
  late String roomId;
  late String userId;
  late String userName;
  late bool negoPubFlag;
  late String signalType;
  late Map<String,dynamic> signalMessage;
  late Map<String,dynamic> pubStream;
  late Map<String,dynamic> subStream;
  
  factory NegoReq.fromJson(Map<String,dynamic> json) => _$NegoReqFromJson(json);
  Map<String, dynamic> toJson() => _$NegoReqToJson(this);
}
