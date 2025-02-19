import 'package:json_annotation/json_annotation.dart';

part 'queryLiveRequest.g.dart';

@JsonSerializable()
class QueryLiveRequest {
  QueryLiveRequest();

  late String userId;
  late String liveProgramId;
  
  factory QueryLiveRequest.fromJson(Map<String,dynamic> json) => _$QueryLiveRequestFromJson(json);
  Map<String, dynamic> toJson() => _$QueryLiveRequestToJson(this);
}
