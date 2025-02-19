// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubLiveRequest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PubLiveRequest _$PubLiveRequestFromJson(Map<String, dynamic> json) =>
    PubLiveRequest()
      ..userId = json['userId'] as String
      ..roomName = json['roomName'] as String
      ..roomDesc = json['roomDesc'] as String
      ..cover = json['cover'] as String
      ..partition = json['partition'] as String
      ..type = json['type'] as String;

Map<String, dynamic> _$PubLiveRequestToJson(PubLiveRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'roomName': instance.roomName,
      'roomDesc': instance.roomDesc,
      'cover': instance.cover,
      'partition': instance.partition,
      'type': instance.type,
    };
