import 'package:json_annotation/json_annotation.dart';

part 'uploadFileResponse.g.dart';

@JsonSerializable()
class UploadFileResponse {
  UploadFileResponse();

  late String id;
  
  factory UploadFileResponse.fromJson(Map<String,dynamic> json) => _$UploadFileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UploadFileResponseToJson(this);
}
