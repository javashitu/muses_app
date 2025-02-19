import 'package:json_annotation/json_annotation.dart';

part 'queryLiveResponse.g.dart';

@JsonSerializable()
class QueryLiveResponse {
  QueryLiveResponse();

  late String rtcUserId;
  late String liveProgramId;
  late String liveRoomId;
  late String roomName;
  late String roomDesc;
  late String cover;
  late String type;
  late num state;
  late Map<String,dynamic> liveAddress;
  
  factory QueryLiveResponse.fromJson(Map<String,dynamic> json) => _$QueryLiveResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QueryLiveResponseToJson(this);
}
