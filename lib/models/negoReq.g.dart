// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'negoReq.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NegoReq _$NegoReqFromJson(Map<String, dynamic> json) => NegoReq()
  ..protoType = json['protoType'] as String
  ..roomId = json['roomId'] as String
  ..userId = json['userId'] as String
  ..userName = json['userName'] as String
  ..negoPubFlag = json['negoPubFlag'] as bool
  ..signalType = json['signalType'] as String
  ..signalMessage = json['signalMessage'] as Map<String, dynamic>
  ..pubStream = json['pubStream'] as Map<String, dynamic>
  ..subStream = json['subStream'] as Map<String, dynamic>;

Map<String, dynamic> _$NegoReqToJson(NegoReq instance) => <String, dynamic>{
      'protoType': instance.protoType,
      'roomId': instance.roomId,
      'userId': instance.userId,
      'userName': instance.userName,
      'negoPubFlag': instance.negoPubFlag,
      'signalType': instance.signalType,
      'signalMessage': instance.signalMessage,
      'pubStream': instance.pubStream,
      'subStream': instance.subStream,
    };
