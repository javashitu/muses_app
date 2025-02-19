// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enterReq.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnterReq _$EnterReqFromJson(Map<String, dynamic> json) => EnterReq()
  ..protoType = json['protoType'] as String
  ..roomId = json['roomId'] as String
  ..userId = json['userId'] as String
  ..userName = json['userName'] as String;

Map<String, dynamic> _$EnterReqToJson(EnterReq instance) => <String, dynamic>{
      'protoType': instance.protoType,
      'roomId': instance.roomId,
      'userId': instance.userId,
      'userName': instance.userName,
    };
