import 'package:json_annotation/json_annotation.dart';

part 'closeReq.g.dart';

@JsonSerializable()
class CloseReq {
  CloseReq();

  late String protoType;
  late String roomId;
  late String userId;
  late String userName;
  
  factory CloseReq.fromJson(Map<String,dynamic> json) => _$CloseReqFromJson(json);
  Map<String, dynamic> toJson() => _$CloseReqToJson(this);
}
