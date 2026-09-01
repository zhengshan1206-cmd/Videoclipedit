// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_draw_img_details_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiDrawImgDetailsBeanImpl _$$AiDrawImgDetailsBeanImplFromJson(
        Map<String, dynamic> json) =>
    _$AiDrawImgDetailsBeanImpl(
      id: (json['id'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      prompt: json['prompt'] as String,
      picUrl: json['pic_url'] as String,
      ratio: json['ratio'] as String,
      modelId: (json['model_id'] as num).toInt(),
      model: json['model'] as String,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$$AiDrawImgDetailsBeanImplToJson(
        _$AiDrawImgDetailsBeanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'prompt': instance.prompt,
      'pic_url': instance.picUrl,
      'ratio': instance.ratio,
      'model_id': instance.modelId,
      'model': instance.model,
      'created_at': instance.createdAt,
    };
