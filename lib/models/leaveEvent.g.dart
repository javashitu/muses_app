// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaveEvent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveEvent _$LeaveEventFromJson(Map<String, dynamic> json) => LeaveEvent()
  ..protoType = json['protoType'] as String
  ..userId = json['userId'] as String
  ..userName = json['userName'] as String
  ..hangUpStreamId = (json['hangUpStreamId'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList()
  ..closePeerConnectionList =
      (json['closePeerConnectionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList();

Map<String, dynamic> _$LeaveEventToJson(LeaveEvent instance) =>
    <String, dynamic>{
      'protoType': instance.protoType,
      'userId': instance.userId,
      'userName': instance.userName,
      'hangUpStreamId': instance.hangUpStreamId,
      'closePeerConnectionList': instance.closePeerConnectionList,
    };
