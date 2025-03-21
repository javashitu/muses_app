// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hangUpEvent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HangUpEvent _$HangUpEventFromJson(Map<String, dynamic> json) => HangUpEvent()
  ..protoType = json['protoType'] as String
  ..userId = json['userId'] as String
  ..userName = json['userName'] as String
  ..streamId =
      (json['streamId'] as List<dynamic>?)?.map((e) => e as String).toList()
  ..hangupReason = json['hangupReason'] as String?;

Map<String, dynamic> _$HangUpEventToJson(HangUpEvent instance) =>
    <String, dynamic>{
      'protoType': instance.protoType,
      'userId': instance.userId,
      'userName': instance.userName,
      'streamId': instance.streamId,
      'hangupReason': instance.hangupReason,
    };
