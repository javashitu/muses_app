import 'package:json_annotation/json_annotation.dart';

part 'videoProgramInfo.g.dart';

@JsonSerializable()
class VideoProgramInfo {
  VideoProgramInfo();

  late String id;
  late String title;
  late String description;
  late String videoUrl;
  late String coverUrl;
  late String themes;
  late String userId;
  late String type;
  late num state;
  late num play;
  late num likes;
  late num commentCount;
  late num share;
  
  factory VideoProgramInfo.fromJson(Map<String,dynamic> json) => _$VideoProgramInfoFromJson(json);
  Map<String, dynamic> toJson() => _$VideoProgramInfoToJson(this);
}
