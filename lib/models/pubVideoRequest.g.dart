// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubVideoRequest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PubVideoRequest _$PubVideoRequestFromJson(Map<String, dynamic> json) =>
    PubVideoRequest()
      ..title = json['title'] as String
      ..description = json['description'] as String
      ..userId = json['userId'] as String
      ..themeList = json['themeList'] as List<dynamic>
      ..videoFileInfo = json['videoFileInfo'] as Map<String, dynamic>
      ..createType = json['createType'] as String
      ..programType = json['programType'] as String
      ..pubTime = json['pubTime'] as num
      ..relevanceId = json['relevanceId'] as String;

Map<String, dynamic> _$PubVideoRequestToJson(PubVideoRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'userId': instance.userId,
      'themeList': instance.themeList,
      'videoFileInfo': instance.videoFileInfo,
      'createType': instance.createType,
      'programType': instance.programType,
      'pubTime': instance.pubTime,
      'relevanceId': instance.relevanceId,
    };
