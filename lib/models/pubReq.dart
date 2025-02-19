import 'package:json_annotation/json_annotation.dart';

part 'pubReq.g.dart';

@JsonSerializable()
class PubReq {
  PubReq();

  late String protoType;
  late String signalType;
  late Map<String,dynamic> signalMessage;
  late String roomId;
  late String userId;
  late Map<String,dynamic> pubStream;
  late String subStream;
  
  factory PubReq.fromJson(Map<String,dynamic> json) => _$PubReqFromJson(json);
  Map<String, dynamic> toJson() => _$PubReqToJson(this);
}
