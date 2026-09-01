// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_cartoon_random_template_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiCartoonRandomTemplateBeanImpl _$$AiCartoonRandomTemplateBeanImplFromJson(
        Map<String, dynamic> json) =>
    _$AiCartoonRandomTemplateBeanImpl(
      category: json['category'] as String,
      text: json['text'] as String,
      scale: Scale.fromJson(json['scale'] as Map<String, dynamic>),
      style: Style.fromJson(json['style'] as Map<String, dynamic>),
      tts: Tts.fromJson(json['tts'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AiCartoonRandomTemplateBeanImplToJson(
        _$AiCartoonRandomTemplateBeanImpl instance) =>
    <String, dynamic>{
      'category': instance.category,
      'text': instance.text,
      'scale': instance.scale,
      'style': instance.style,
      'tts': instance.tts,
    };

_$ScaleImpl _$$ScaleImplFromJson(Map<String, dynamic> json) => _$ScaleImpl(
      id: (json['id'] as num).toInt(),
      scale: json['scale'] as String,
      unselect: json['unselect'] as String,
      selected: json['selected'] as String,
    );

Map<String, dynamic> _$$ScaleImplToJson(_$ScaleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scale': instance.scale,
      'unselect': instance.unselect,
      'selected': instance.selected,
    };

_$StyleImpl _$$StyleImplFromJson(Map<String, dynamic> json) => _$StyleImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$$StyleImplToJson(_$StyleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
    };

_$TtsImpl _$$TtsImplFromJson(Map<String, dynamic> json) => _$TtsImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      headerImage: json['header_image'] as String,
      title: json['title'] as String,
      speaker: json['speaker'] as String,
      needVip: (json['need_vip'] as num).toInt(),
      integral: (json['integral'] as num).toInt(),
      showName: json['show_name'] as String,
      demoUrl: json['demo_url'] as String,
      isCollect: (json['isCollect'] as num).toInt(),
      mxSpeed: (json['mx_speed'] as num).toInt(),
      mxIntonation: (json['mx_intonation'] as num).toInt(),
    );

Map<String, dynamic> _$$TtsImplToJson(_$TtsImpl instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'header_image': instance.headerImage,
      'title': instance.title,
      'speaker': instance.speaker,
      'need_vip': instance.needVip,
      'integral': instance.integral,
      'show_name': instance.showName,
      'demo_url': instance.demoUrl,
      'isCollect': instance.isCollect,
      'mx_speed': instance.mxSpeed,
      'mx_intonation': instance.mxIntonation,
    };
