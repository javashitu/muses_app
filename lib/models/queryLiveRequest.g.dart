// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queryLiveRequest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueryLiveRequest _$QueryLiveRequestFromJson(Map<String, dynamic> json) =>
    QueryLiveRequest()
      ..userId = json['userId'] as String
      ..liveProgramId = json['liveProgramId'] as String;

Map<String, dynamic> _$QueryLiveRequestToJson(QueryLiveRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'liveProgramId': instance.liveProgramId,
    };
