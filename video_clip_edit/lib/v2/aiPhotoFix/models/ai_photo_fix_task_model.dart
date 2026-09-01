import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_photo_fix_task_model.g.dart';

@JsonEnum(valueField: 'code')
enum AiPhotoFixStatus {
  // 1 已创建
  taskCreated(1),
  // 2 已提交
  taskSubmitted(2),
  // 3 生成中
  generating(3),
  // 4 成功
  done(4),
  // 5 失败
  failed(5);

  // // 6 失败
  // deleted(6);

  final int code;
  const AiPhotoFixStatus(this.code);
}

const kAiHdPhotoFixTaskType = 1;
const kAiOldPhotoFixTaskType = 2;

@JsonSerializable(fieldRename: FieldRename.snake)
class AiPhotoFixTaskModel {
  int id;
  AiPhotoFixStatus status;
  int userId;
  String? taskId;
  String refImageUrl;
  String? imageUrl;
  String date;
  int type;
  int? deleteTime;
  String createAt;
  String updateAt;

  AiPhotoFixTaskModel({
    required this.id,
    required this.status,
    required this.userId,
    required this.refImageUrl,
    this.imageUrl,
    this.taskId,
    required this.date,
    required this.type,
    this.deleteTime,
    required this.createAt,
    required this.updateAt,
  });

  bool get isDeleted => (deleteTime != null && deleteTime! > 0);

  factory AiPhotoFixTaskModel.fromRawJson(String str) =>
      AiPhotoFixTaskModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiPhotoFixTaskModel.fromJson(Map<String, dynamic> json) => _$AiPhotoFixTaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$AiPhotoFixTaskModelToJson(this);
}
