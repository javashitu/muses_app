import 'package:json_annotation/json_annotation.dart';

part 'liveProgramInfo.g.dart';

@JsonSerializable()
class LiveProgramInfo {
  LiveProgramInfo();

  late String createUserId;
  late String liveProgramId;
  late String liveRoomId;
  late String roomName;
  late String roomDesc;
  late String cover;
  late String type;
  late num state;
  late Map<String,dynamic> liveAddress;
  
  factory LiveProgramInfo.fromJson(Map<String,dynamic> json) => _$LiveProgramInfoFromJson(json);
  Map<String, dynamic> toJson() => _$LiveProgramInfoToJson(this);
}
