import 'package:json_annotation/json_annotation.dart';

part 'pubLiveRequest.g.dart';

@JsonSerializable()
class PubLiveRequest {
  PubLiveRequest();

  late String userId;
  late String roomName;
  late String roomDesc;
  late String cover;
  late String partition;
  late String type;
  
  factory PubLiveRequest.fromJson(Map<String,dynamic> json) => _$PubLiveRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PubLiveRequestToJson(this);
}
