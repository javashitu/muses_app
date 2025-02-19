// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subReq.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubReq _$SubReqFromJson(Map<String, dynamic> json) => SubReq()
  ..protoType = json['protoType'] as String
  ..signalType = json['signalType'] as String
  ..signalMessage = json['signalMessage'] as Map<String, dynamic>
  ..roomId = json['roomId'] as String
  ..userId = json['userId'] as String
  ..pubStream = json['pubStream'] as Map<String, dynamic>
  ..subStream = json['subStream'] as Map<String, dynamic>;

Map<String, dynamic> _$SubReqToJson(SubReq instance) => <String, dynamic>{
      'protoType': instance.protoType,
      'signalType': instance.signalType,
      'signalMessage': instance.signalMessage,
      'roomId': instance.roomId,
      'userId': instance.userId,
      'pubStream': instance.pubStream,
      'subStream': instance.subStream,
    };
