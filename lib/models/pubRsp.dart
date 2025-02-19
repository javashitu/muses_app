import 'package:json_annotation/json_annotation.dart';

part 'pubRsp.g.dart';

@JsonSerializable()
class PubRsp {
  PubRsp();

  late String protoType;
  late String roomId;
  late String userId;
  late Map<String,dynamic> pubStream;
  
  factory PubRsp.fromJson(Map<String,dynamic> json) => _$PubRspFromJson(json);
  Map<String, dynamic> toJson() => _$PubRspToJson(this);
}
