import 'package:json_annotation/json_annotation.dart';

part 'negoEvent.g.dart';

@JsonSerializable()
class NegoEvent {
  NegoEvent();

  late String protoType;
  late String userId;
  late String userName;
  late bool negoPubFlag;
  late Map<String,dynamic> pubStream;
  late Map<String,dynamic> subStream;
  late String signalType;
  late Map<String,dynamic> signalMessage;
  
  factory NegoEvent.fromJson(Map<String,dynamic> json) => _$NegoEventFromJson(json);
  Map<String, dynamic> toJson() => _$NegoEventToJson(this);
}
