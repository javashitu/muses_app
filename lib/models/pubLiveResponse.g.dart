// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubLiveResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PubLiveResponse _$PubLiveResponseFromJson(Map<String, dynamic> json) =>
    PubLiveResponse()
      ..liveProgramId = json['liveProgramId'] as String
      ..liveRoomId = json['liveRoomId'] as String
      ..rtcUserId = json['rtcUserId'] as String
      ..liveAddress = json['liveAddress'] as Map<String, dynamic>
      ..liveProgramInfo = json['liveProgramInfo'] as Map<String, dynamic>;

Map<String, dynamic> _$PubLiveResponseToJson(PubLiveResponse instance) =>
    <String, dynamic>{
      'liveProgramId': instance.liveProgramId,
      'liveRoomId': instance.liveRoomId,
      'rtcUserId': instance.rtcUserId,
      'liveAddress': instance.liveAddress,
      'liveProgramInfo': instance.liveProgramInfo,
    };
