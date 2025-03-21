import 'package:json_annotation/json_annotation.dart';

part 'hangUpEvent.g.dart';

@JsonSerializable()
class HangUpEvent {
  HangUpEvent();

  late String protoType;
  late String userId;
  late String userName;
  List<String>? streamId;
  String? hangupReason;
  
  factory HangUpEvent.fromJson(Map<String,dynamic> json) => _$HangUpEventFromJson(json);
  Map<String, dynamic> toJson() => _$HangUpEventToJson(this);
}
