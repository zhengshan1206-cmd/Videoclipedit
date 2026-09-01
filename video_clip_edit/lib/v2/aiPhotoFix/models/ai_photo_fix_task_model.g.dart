// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_photo_fix_task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiPhotoFixTaskModel _$AiPhotoFixTaskModelFromJson(Map<String, dynamic> json) =>
    AiPhotoFixTaskModel(
      id: (json['id'] as num).toInt(),
      status: $enumDecode(_$AiPhotoFixStatusEnumMap, json['status']),
      userId: (json['user_id'] as num).toInt(),
      refImageUrl: json['ref_image_url'] as String,
      imageUrl: json['image_url'] as String?,
      taskId: json['task_id'] as String?,
      date: json['date'] as String,
      type: (json['type'] as num).toInt(),
      deleteTime: (json['delete_time'] as num?)?.toInt(),
      createAt: json['create_at'] as String,
      updateAt: json['update_at'] as String,
    );

Map<String, dynamic> _$AiPhotoFixTaskModelToJson(
        AiPhotoFixTaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$AiPhotoFixStatusEnumMap[instance.status]!,
      'user_id': instance.userId,
      'task_id': instance.taskId,
      'ref_image_url': instance.refImageUrl,
      'image_url': instance.imageUrl,
      'date': instance.date,
      'type': instance.type,
      'delete_time': instance.deleteTime,
      'create_at': instance.createAt,
      'update_at': instance.updateAt,
    };

const _$AiPhotoFixStatusEnumMap = {
  AiPhotoFixStatus.taskCreated: 1,
  AiPhotoFixStatus.taskSubmitted: 2,
  AiPhotoFixStatus.generating: 3,
  AiPhotoFixStatus.done: 4,
  AiPhotoFixStatus.failed: 5,
};
