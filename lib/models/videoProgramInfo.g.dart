// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'videoProgramInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoProgramInfo _$VideoProgramInfoFromJson(Map<String, dynamic> json) =>
    VideoProgramInfo()
      ..id = json['id'] as String
      ..title = json['title'] as String
      ..description = json['description'] as String
      ..videoUrl = json['videoUrl'] as String
      ..coverUrl = json['coverUrl'] as String
      ..themes = json['themes'] as String
      ..userId = json['userId'] as String
      ..type = json['type'] as String
      ..state = json['state'] as num
      ..play = json['play'] as num
      ..likes = json['likes'] as num
      ..commentCount = json['commentCount'] as num
      ..share = json['share'] as num;

Map<String, dynamic> _$VideoProgramInfoToJson(VideoProgramInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'videoUrl': instance.videoUrl,
      'coverUrl': instance.coverUrl,
      'themes': instance.themes,
      'userId': instance.userId,
      'type': instance.type,
      'state': instance.state,
      'play': instance.play,
      'likes': instance.likes,
      'commentCount': instance.commentCount,
      'share': instance.share,
    };
