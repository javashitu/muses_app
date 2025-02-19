// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubRsp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PubRsp _$PubRspFromJson(Map<String, dynamic> json) => PubRsp()
  ..protoType = json['protoType'] as String
  ..roomId = json['roomId'] as String
  ..userId = json['userId'] as String
  ..pubStream = json['pubStream'] as Map<String, dynamic>;

Map<String, dynamic> _$PubRspToJson(PubRsp instance) => <String, dynamic>{
      'protoType': instance.protoType,
      'roomId': instance.roomId,
      'userId': instance.userId,
      'pubStream': instance.pubStream,
    };
