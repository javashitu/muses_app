// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rtcStream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RtcStream _$RtcStreamFromJson(Map<String, dynamic> json) => RtcStream()
  ..streamId = json['streamId'] as String
  ..userId = json['userId'] as String
  ..pubFlag = json['pubFlag'] as bool
  ..audio = json['audio'] as bool
  ..video = json['video'] as bool;

Map<String, dynamic> _$RtcStreamToJson(RtcStream instance) => <String, dynamic>{
      'streamId': instance.streamId,
      'userId': instance.userId,
      'pubFlag': instance.pubFlag,
      'audio': instance.audio,
      'video': instance.video,
    };
