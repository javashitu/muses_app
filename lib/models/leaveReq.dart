import 'package:json_annotation/json_annotation.dart';

part 'leaveReq.g.dart';

@JsonSerializable()
class LeaveReq {
  LeaveReq();

  late String protoType;
  late String roomId;
  late String userId;
  late String userName;
  
  factory LeaveReq.fromJson(Map<String,dynamic> json) => _$LeaveReqFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveReqToJson(this);
}
