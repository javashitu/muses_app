import 'package:json_annotation/json_annotation.dart';

part 'pubEvent.g.dart';

@JsonSerializable()
class PubEvent {
  PubEvent();

  late String protoType;
  late String userId;
  late String userName;
  late String signalType;
  late Map<String,dynamic> signalMessage;
  late Map<String,dynamic> pubStream;
  
  factory PubEvent.fromJson(Map<String,dynamic> json) => _$PubEventFromJson(json);
  Map<String, dynamic> toJson() => _$PubEventToJson(this);
}
