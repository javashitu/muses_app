// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enterEvent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnterEvent _$EnterEventFromJson(Map<String, dynamic> json) => EnterEvent()
  ..protoType = json['protoType'] as String
  ..userId = json['userId'] as String
  ..userName = json['userName'] as String;

Map<String, dynamic> _$EnterEventToJson(EnterEvent instance) =>
    <String, dynamic>{
      'protoType': instance.protoType,
      'userId': instance.userId,
      'userName': instance.userName,
    };
