// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queryLiveResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueryLiveResponse _$QueryLiveResponseFromJson(Map<String, dynamic> json) =>
    QueryLiveResponse()
      ..rtcUserId = json['rtcUserId'] as String
      ..liveProgramId = json['liveProgramId'] as String
      ..liveRoomId = json['liveRoomId'] as String
      ..roomName = json['roomName'] as String
      ..roomDesc = json['roomDesc'] as String
      ..cover = json['cover'] as String
      ..type = json['type'] as String
      ..state = json['state'] as num
      ..liveAddress = json['liveAddress'] as Map<String, dynamic>;

Map<String, dynamic> _$QueryLiveResponseToJson(QueryLiveResponse instance) =>
    <String, dynamic>{
      'rtcUserId': instance.rtcUserId,
      'liveProgramId': instance.liveProgramId,
      'liveRoomId': instance.liveRoomId,
      'roomName': instance.roomName,
      'roomDesc': instance.roomDesc,
      'cover': instance.cover,
      'type': instance.type,
      'state': instance.state,
      'liveAddress': instance.liveAddress,
    };
