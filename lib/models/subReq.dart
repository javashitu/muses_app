import 'package:json_annotation/json_annotation.dart';

part 'subReq.g.dart';

@JsonSerializable()
class SubReq {
  SubReq();

  late String protoType;
  late String signalType;
  late Map<String,dynamic> signalMessage;
  late String roomId;
  late String userId;
  late Map<String,dynamic> pubStream;
  late Map<String,dynamic> subStream;
  
  factory SubReq.fromJson(Map<String,dynamic> json) => _$SubReqFromJson(json);
  Map<String, dynamic> toJson() => _$SubReqToJson(this);
}
