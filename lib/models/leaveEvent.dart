import 'package:json_annotation/json_annotation.dart';

part 'leaveEvent.g.dart';

@JsonSerializable()
class LeaveEvent {
  LeaveEvent();

  late String protoType;
  late String userId;
  late String userName;
  List<String>? hangUpStreamId;
  List<String>? closePeerConnectionList;
  
  factory LeaveEvent.fromJson(Map<String,dynamic> json) => _$LeaveEventFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveEventToJson(this);
}
