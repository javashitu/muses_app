// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enterRsp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnterRsp _$EnterRspFromJson(Map<String, dynamic> json) => EnterRsp()
  ..protoType = json['protoType'] as String
  ..roomId = json['roomId'] as String
  ..userId = json['userId'] as String
  ..otherUsers = json['otherUsers'] as List<dynamic>
  ..peerConfig = json['peerConfig'] as Map<String, dynamic>
  ..constraints = json['constraints'] as Map<String, dynamic>
  ..flutterRtcMediaConf = json['flutterRtcMediaConf'] as Map<String, dynamic>
  ..userPubMap = json['userPubMap'] as Map<String, dynamic>
  ..anchorFlag = json['anchorFlag'] as bool;

Map<String, dynamic> _$EnterRspToJson(EnterRsp instance) => <String, dynamic>{
      'protoType': instance.protoType,
      'roomId': instance.roomId,
      'userId': instance.userId,
      'otherUsers': instance.otherUsers,
      'peerConfig': instance.peerConfig,
      'constraints': instance.constraints,
      'flutterRtcMediaConf': instance.flutterRtcMediaConf,
      'userPubMap': instance.userPubMap,
      'anchorFlag': instance.anchorFlag,
    };
