// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_draw_config_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiDrawConfigBeanImpl _$$AiDrawConfigBeanImplFromJson(
        Map<String, dynamic> json) =>
    _$AiDrawConfigBeanImpl(
      ratios: (json['ratios'] as List<dynamic>)
          .map((e) => Ratio.fromJson(e as Map<String, dynamic>))
          .toList(),
      imgStyles: (json['imgStyles'] as List<dynamic>)
          .map((e) => ImgStyle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$AiDrawConfigBeanImplToJson(
        _$AiDrawConfigBeanImpl instance) =>
    <String, dynamic>{
      'ratios': instance.ratios,
      'imgStyles': instance.imgStyles,
    };

_$ImgStyleImpl _$$ImgStyleImplFromJson(Map<String, dynamic> json) =>
    _$ImgStyleImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      url: json['url'] as String,
      prompts:
          (json['prompts'] as List<dynamic>).map((e) => e as String).toList(),
      integralUser: (json['integral_user'] as num).toInt(),
    );

Map<String, dynamic> _$$ImgStyleImplToJson(_$ImgStyleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'prompts': instance.prompts,
      'integral_user': instance.integralUser,
    };

_$RatioImpl _$$RatioImplFromJson(Map<String, dynamic> json) => _$RatioImpl(
      id: (json['id'] as num).toInt(),
      scale: json['scale'] as String,
      pic1: json['pic1'] as String,
      pic2: json['pic2'] as String,
    );

Map<String, dynamic> _$$RatioImplToJson(_$RatioImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scale': instance.scale,
      'pic1': instance.pic1,
      'pic2': instance.pic2,
    };
