import 'package:json_annotation/json_annotation.dart';

part 'enterEvent.g.dart';

@JsonSerializable()
class EnterEvent {
  EnterEvent();

  late String protoType;
  late String userId;
  late String userName;
  
  factory EnterEvent.fromJson(Map<String,dynamic> json) => _$EnterEventFromJson(json);
  Map<String, dynamic> toJson() => _$EnterEventToJson(this);
}
