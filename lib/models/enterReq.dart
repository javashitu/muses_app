import 'package:json_annotation/json_annotation.dart';

part 'enterReq.g.dart';

@JsonSerializable()
class EnterReq {
  EnterReq();

  late String protoType;
  late String roomId;
  late String userId;
  late String userName;
  
  factory EnterReq.fromJson(Map<String,dynamic> json) => _$EnterReqFromJson(json);
  Map<String, dynamic> toJson() => _$EnterReqToJson(this);
}
