// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'closeReq.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CloseReq _$CloseReqFromJson(Map<String, dynamic> json) => CloseReq()
  ..protoType = json['protoType'] as String
  ..roomId = json['roomId'] as String
  ..userId = json['userId'] as String
  ..userName = json['userName'] as String;

Map<String, dynamic> _$CloseReqToJson(CloseReq instance) => <String, dynamic>{
      'protoType': instance.protoType,
      'roomId': instance.roomId,
      'userId': instance.userId,
      'userName': instance.userName,
    };
