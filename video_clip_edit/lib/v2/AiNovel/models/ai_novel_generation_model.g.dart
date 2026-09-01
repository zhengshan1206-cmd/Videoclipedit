// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_novel_generation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiNovelGenerationTaskModel _$AiNovelGenerationTaskModelFromJson(
        Map<String, dynamic> json) =>
    AiNovelGenerationTaskModel(
      id: (json['id'] as num).toInt(),
      date: json['date'] as String?,
      status: $enumDecode(_$AiNovelStatusEnumMap, json['status']),
      statusProcess: (json['status_process'] as num?)?.toInt(),
      inspiration: json['inspiration'] as String?,
      unitDesign: (json['unit_design'] as num?)?.toInt(),
      chapterDetailOutline: (json['chapter_detail_outline'] as num?)?.toInt(),
      chapterNums: (json['chapter_nums'] as num?)?.toInt(),
      totalWords: (json['total_words'] as num?)?.toInt(),
      taskId: json['task_id'] as String?,
      prompt: json['prompt'] as String?,
      title: json['title'] as String?,
      isAuto: (json['is_auto'] as num?)?.toInt(),
      deleteTime: (json['delete_time'] as num?)?.toInt(),
      createAt: json['create_at'] as String,
      updateAt: json['update_at'] as String,
    );

Map<String, dynamic> _$AiNovelGenerationTaskModelToJson(
        AiNovelGenerationTaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'status': _$AiNovelStatusEnumMap[instance.status]!,
      'status_process': instance.statusProcess,
      'inspiration': instance.inspiration,
      'unit_design': instance.unitDesign,
      'chapter_detail_outline': instance.chapterDetailOutline,
      'chapter_nums': instance.chapterNums,
      'total_words': instance.totalWords,
      'task_id': instance.taskId,
      'prompt': instance.prompt,
      'title': instance.title,
      'is_auto': instance.isAuto,
      'delete_time': instance.deleteTime,
      'create_at': instance.createAt,
      'update_at': instance.updateAt,
    };

const _$AiNovelStatusEnumMap = {
  AiNovelStatus.inspirationGenerating: 1,
  AiNovelStatus.chapterUnitDesign: 2,
  AiNovelStatus.chapterOutline: 3,
  AiNovelStatus.chapterExpansion: 4,
  AiNovelStatus.done: 5,
  AiNovelStatus.failed: 6,
};
