import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_novel_generation_model.g.dart';

@JsonEnum(valueField: 'code')
enum AiNovelStatus {
  // 1 灵感生成
  inspirationGenerating(1),
  // 2 章节单元设计
  chapterUnitDesign(2),
  // 3 章节细纲
  chapterOutline(3),
  // 4 章节扩写
  chapterExpansion(4),
  // 5 处理完成
  done(5),
  // 6 失败
  failed(6);

  final int code;
  const AiNovelStatus(this.code);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AiNovelGenerationTaskModel {
  int id;
  String? date;
  AiNovelStatus status;
  int? statusProcess;
  String? inspiration;
  int? unitDesign;
  int? chapterDetailOutline;
  int? chapterNums;
  int? totalWords;
  String? taskId;
  String? prompt;
  String? title;
  int? isAuto;
  int? deleteTime;
  String createAt;
  String updateAt;

  AiNovelGenerationTaskModel({
    required this.id,
    this.date,
    required this.status,
    this.statusProcess,
    this.inspiration,
    this.unitDesign,
    this.chapterDetailOutline,
    this.chapterNums,
    this.totalWords,
    this.taskId,
    this.prompt,
    this.title,
    this.isAuto,
    this.deleteTime,
    required this.createAt,
    required this.updateAt,
  });

  bool get isDeleted => (deleteTime != null);

  factory AiNovelGenerationTaskModel.fromRawJson(String str) =>
      AiNovelGenerationTaskModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiNovelGenerationTaskModel.fromJson(Map<String, dynamic> json) => _$AiNovelGenerationTaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$AiNovelGenerationTaskModelToJson(this);
}
