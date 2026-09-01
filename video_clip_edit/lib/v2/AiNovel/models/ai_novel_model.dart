import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'ai_novel_generation_model.dart';

part 'ai_novel_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AiNovelChapterModel {
  final int id;
  final String date;
  final String title;
  final String text;
  final int totalWords;

  AiNovelChapterModel({
    required this.id,
    required this.date,
    required this.text,
    required this.title,
    required this.totalWords,
  });

  factory AiNovelChapterModel.fromRawJson(String str) =>
      AiNovelChapterModel.fromJson(json.decode(str));

  factory AiNovelChapterModel.fromJson(Map<String, dynamic> json) =>
      _$AiNovelChapterModelFromJson(json);
  Map<String, dynamic> toJson() => _$AiNovelChapterModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AiNovelModel {
  int id;
  String? date;
  AiNovelStatus status;
  int? statusProcess;
  dynamic inspiration;
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
  List<AiNovelChapterModel>? chapters;

  AiNovelModel({
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
    this.chapters,
    this.isAuto,
    this.deleteTime,
    required this.createAt,
    required this.updateAt,
  });

  String? toText() {
    return "标题: ${title}\n时间: ${date}\n\n\n${getContent()}\n\n\n";
  }

  String? getContent() {
    return chapters?.map((chapter) => chapter.text).join("\n\n");
  }

  int countWords() {
    return (chapters == null || chapters!.isEmpty)
        ? 0
        : (chapters
                ?.map((chapter) => chapter.totalWords)
                .reduce((value, element) => value + element) ??
            0);
  }

  factory AiNovelModel.fromRawJson(String str) =>
      AiNovelModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiNovelModel.fromJson(Map<String, dynamic> json) =>
      _$AiNovelModelFromJson(json);
  Map<String, dynamic> toJson() => _$AiNovelModelToJson(this);
}
