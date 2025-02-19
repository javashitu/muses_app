// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'negoEvent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NegoEvent _$NegoEventFromJson(Map<String, dynamic> json) => NegoEvent()
  ..protoType = json['protoType'] as String
  ..userId = json['userId'] as String
  ..userName = json['userName'] as String
  ..negoPubFlag = json['negoPubFlag'] as bool
  ..pubStream = json['pubStream'] as Map<String, dynamic>
  ..subStream = json['subStream'] as Map<String, dynamic>
  ..signalType = json['signalType'] as String
  ..signalMessage = json['signalMessage'] as Map<String, dynamic>;

Map<String, dynamic> _$NegoEventToJson(NegoEvent instance) => <String, dynamic>{
      'protoType': instance.protoType,
      'userId': instance.userId,
      'userName': instance.userName,
      'negoPubFlag': instance.negoPubFlag,
      'pubStream': instance.pubStream,
      'subStream': instance.subStream,
      'signalType': instance.signalType,
      'signalMessage': instance.signalMessage,
    };
