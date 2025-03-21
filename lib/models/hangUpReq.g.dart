// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hangUpReq.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HangUpReq _$HangUpReqFromJson(Map<String, dynamic> json) => HangUpReq()
  ..protoType = json['protoType'] as String
  ..roomId = json['roomId'] as String
  ..userId = json['userId'] as String
  ..userName = json['userName'] as String
  ..pubStreamFlag = json['pubStreamFlag'] as bool
  ..streamId = json['streamId'] as String;

Map<String, dynamic> _$HangUpReqToJson(HangUpReq instance) => <String, dynamic>{
      'protoType': instance.protoType,
      'roomId': instance.roomId,
      'userId': instance.userId,
      'userName': instance.userName,
      'pubStreamFlag': instance.pubStreamFlag,
      'streamId': instance.streamId,
    };
