import 'package:json_annotation/json_annotation.dart';

part 'pubLiveResponse.g.dart';

@JsonSerializable()
class PubLiveResponse {
  PubLiveResponse();

  late String liveProgramId;
  late String liveRoomId;
  late String rtcUserId;
  late Map<String,dynamic> liveAddress;
  late Map<String,dynamic> liveProgramInfo;
  
  factory PubLiveResponse.fromJson(Map<String,dynamic> json) => _$PubLiveResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PubLiveResponseToJson(this);
}
