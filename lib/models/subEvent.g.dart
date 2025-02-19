// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subEvent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubEvent _$SubEventFromJson(Map<String, dynamic> json) => SubEvent()
  ..protoType = json['protoType'] as String
  ..userId = json['userId'] as String
  ..userName = json['userName'] as String
  ..subStream = json['subStream'] as Map<String, dynamic>
  ..pubStream = json['pubStream'] as Map<String, dynamic>
  ..signalType = json['signalType'] as String
  ..signalMessage = json['signalMessage'] as Map<String, dynamic>;

Map<String, dynamic> _$SubEventToJson(SubEvent instance) => <String, dynamic>{
      'protoType': instance.protoType,
      'userId': instance.userId,
      'userName': instance.userName,
      'subStream': instance.subStream,
      'pubStream': instance.pubStream,
      'signalType': instance.signalType,
      'signalMessage': instance.signalMessage,
    };
