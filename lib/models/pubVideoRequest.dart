import 'package:json_annotation/json_annotation.dart';

part 'pubVideoRequest.g.dart';

@JsonSerializable()
class PubVideoRequest {
  PubVideoRequest();

  late String title;
  late String description;
  late String userId;
  late List themeList;
  late Map<String,dynamic> videoFileInfo;
  late String createType;
  late String programType;
  late num pubTime;
  late String relevanceId;
  
  factory PubVideoRequest.fromJson(Map<String,dynamic> json) => _$PubVideoRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PubVideoRequestToJson(this);
}
