// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubReq.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PubReq _$PubReqFromJson(Map<String, dynamic> json) => PubReq()
  ..protoType = json['protoType'] as String
  ..signalType = json['signalType'] as String
  ..signalMessage = json['signalMessage'] as Map<String, dynamic>
  ..roomId = json['roomId'] as String
  ..userId = json['userId'] as String
  ..pubStream = json['pubStream'] as Map<String, dynamic>
  ..subStream = json['subStream'] as String;

Map<String, dynamic> _$PubReqToJson(PubReq instance) => <String, dynamic>{
      'protoType': instance.protoType,
      'signalType': instance.signalType,
      'signalMessage': instance.signalMessage,
      'roomId': instance.roomId,
      'userId': instance.userId,
      'pubStream': instance.pubStream,
      'subStream': instance.subStream,
    };
