import 'package:json_annotation/json_annotation.dart';

part 'subEvent.g.dart';

@JsonSerializable()
class SubEvent {
  SubEvent();

  late String protoType;
  late String userId;
  late String userName;
  late Map<String,dynamic> subStream;
  late Map<String,dynamic> pubStream;
  late String signalType;
  late Map<String,dynamic> signalMessage;
  
  factory SubEvent.fromJson(Map<String,dynamic> json) => _$SubEventFromJson(json);
  Map<String, dynamic> toJson() => _$SubEventToJson(this);
}
