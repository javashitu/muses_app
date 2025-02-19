// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaveReq.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveReq _$LeaveReqFromJson(Map<String, dynamic> json) => LeaveReq()
  ..protoType = json['protoType'] as String
  ..roomId = json['roomId'] as String
  ..userId = json['userId'] as String
  ..userName = json['userName'] as String;

Map<String, dynamic> _$LeaveReqToJson(LeaveReq instance) => <String, dynamic>{
      'protoType': instance.protoType,
      'roomId': instance.roomId,
      'userId': instance.userId,
      'userName': instance.userName,
    };
