// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_draw_style_case_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiDrawStyleCaseBeanImpl _$$AiDrawStyleCaseBeanImplFromJson(
        Map<String, dynamic> json) =>
    _$AiDrawStyleCaseBeanImpl(
      id: (json['id'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      prompt: json['prompt'] as String,
      miniPicUrl: json['mini_pic_url'] as String,
      picUrl: json['pic_url'] as String,
      ratio: json['ratio'] as String,
      modelId: (json['model_id'] as num).toInt(),
      model: json['model'] as String,
      labels:
          (json['labels'] as List<dynamic>).map((e) => e as String).toList(),
      activeUserName: json['active_user_name'] as String,
      activeUserAvatar: json['active_user_avatar'] as String,
      activeUserCreateDays: (json['active_user_create_days'] as num).toInt(),
      useTime: json['use_time'] as String,
      withdrawMoney: json['withdraw_money'] as String,
      withdrawMoneyTip: json['withdraw_money_tip'] as String,
    );

Map<String, dynamic> _$$AiDrawStyleCaseBeanImplToJson(
        _$AiDrawStyleCaseBeanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'prompt': instance.prompt,
      'mini_pic_url': instance.miniPicUrl,
      'pic_url': instance.picUrl,
      'ratio': instance.ratio,
      'model_id': instance.modelId,
      'model': instance.model,
      'labels': instance.labels,
      'active_user_name': instance.activeUserName,
      'active_user_avatar': instance.activeUserAvatar,
      'active_user_create_days': instance.activeUserCreateDays,
      'use_time': instance.useTime,
      'withdraw_money': instance.withdrawMoney,
      'withdraw_money_tip': instance.withdrawMoneyTip,
    };
