// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_video_square_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiVideoSquareModel _$AiVideoSquareModelFromJson(Map<String, dynamic> json){

      // dynamic multiImage = json['multi_image'];
      //
      // List multiImage1  = multiImage;

      // log("multiImage====>${multiImage1.length}");

      return AiVideoSquareModel(
            userId: (json['user_id'] as num).toInt(),
            type: $enumDecode(_$AiVideoGenerationTypeEnumMap, json['type']),
            userName: (json['user_name'] ?? "") as String,
            prompt: json['prompt'] as String?,
            negativePrompt: json['negative_prompt'] as String?,
            useTime: json['use_time'].toString(),
            withdrawMoney: (json['withdraw_money'] ?? "") as String,
            categoryIds: (json['category_ids'] ?? "") as String,
            bgmUrl: (json['bgm_url']??"") as String?,
            labels: json['labels'] == null
                ? []
                : json['labels'] is List
                ? (json['labels'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList()
                : [json['labels']],
            multiImage: json['multi_image'] == null
                ? []
                : json['multi_image'] is List
                ? (json['multi_image'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList()
                : [json['multi_image']],
            imageTail: json['image_tail'] as String?,
            cfgScale: (json['cfg_scale'] as num).toDouble(),
            mode: (json['mode'] ?? "") as String,
            aspectRatio: (json['aspect_ratio'] ?? "") as String,
            videoUrl: (json['video_url'] ?? "") as String,
            coverUrl: (json['cover_url'] ?? "") as String,
            shareVideoUrl: (json['share_video_url'] ?? "") as String,
            shareCoverUrl: (json['share_cover_url'] ?? "") as String,
            withdrawMoneyTip: (json['withdraw_money_tip'] ?? "") as String,
            activeUserName: (json['active_user_name'] ?? "") as String,
            activeUserAvatar: (json['active_user_avatar'] ?? "") as String,
            activeUserCreateDays:
            ((json['active_user_create_days'] ?? 0) as num).toInt(),
      );
}

Map<String, dynamic> _$AiVideoSquareModelToJson(AiVideoSquareModel instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'type': _$AiVideoGenerationTypeEnumMap[instance.type]!,
      'user_name': instance.userName,
      'prompt': instance.prompt,
      'negative_prompt': instance.negativePrompt,
      'use_time': instance.useTime,
      'withdraw_money': instance.withdrawMoney,
      'category_ids': instance.categoryIds,
      'labels': instance.labels,
      'multi_image': instance.multiImage,
          "bgm_url":instance.bgmUrl,
      'image_tail': instance.imageTail,
      'cfg_scale': instance.cfgScale,
      'mode': instance.mode,
      'aspect_ratio': instance.aspectRatio,
      'video_url': instance.videoUrl,
      'cover_url': instance.coverUrl,
      'share_video_url': instance.shareVideoUrl,
      'share_cover_url': instance.shareCoverUrl,
      'withdraw_money_tip': instance.withdrawMoneyTip,
      'active_user_name': instance.activeUserName,
      'active_user_avatar': instance.activeUserAvatar,
      'active_user_create_days': instance.activeUserCreateDays,
    };

const _$AiVideoGenerationTypeEnumMap = {
  AiVideoGenerationType.textToVideo: 1,
  AiVideoGenerationType.imageToVideo: 2,
  AiVideoGenerationType.embraceVideo: 3,
};
