// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubEvent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PubEvent _$PubEventFromJson(Map<String, dynamic> json) => PubEvent()
  ..protoType = json['protoType'] as String
  ..userId = json['userId'] as String
  ..userName = json['userName'] as String
  ..signalType = json['signalType'] as String
  ..signalMessage = json['signalMessage'] as Map<String, dynamic>
  ..pubStream = json['pubStream'] as Map<String, dynamic>;

Map<String, dynamic> _$PubEventToJson(PubEvent instance) => <String, dynamic>{
      'protoType': instance.protoType,
      'userId': instance.userId,
      'userName': instance.userName,
      'signalType': instance.signalType,
      'signalMessage': instance.signalMessage,
      'pubStream': instance.pubStream,
    };
