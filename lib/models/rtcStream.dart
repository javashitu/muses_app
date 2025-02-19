import 'package:json_annotation/json_annotation.dart';

part 'rtcStream.g.dart';

@JsonSerializable()
class RtcStream {
  RtcStream();

  late String streamId;
  late String userId;
  late bool pubFlag;
  late bool audio;
  late bool video;
  
  factory RtcStream.fromJson(Map<String,dynamic> json) => _$RtcStreamFromJson(json);
  Map<String, dynamic> toJson() => _$RtcStreamToJson(this);
}
