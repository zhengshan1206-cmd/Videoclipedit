import 'package:freezed_annotation/freezed_annotation.dart';
part 'ai_cartoon_random_template_bean.freezed.dart';
part 'ai_cartoon_random_template_bean.g.dart';

@freezed
class AiCartoonRandomTemplateBean with _$AiCartoonRandomTemplateBean {
  const factory AiCartoonRandomTemplateBean({
    @JsonKey(name: "category") required String category,
    @JsonKey(name: "text") required String text,
    @JsonKey(name: "scale") required Scale scale,
    @JsonKey(name: "style") required Style style,
    @JsonKey(name: "tts") required Tts tts,
  }) = _AiCartoonRandomTemplateBean;

  factory AiCartoonRandomTemplateBean.fromJson(Map<String, dynamic> json) =>
      _$AiCartoonRandomTemplateBeanFromJson(json);
}

@freezed
class Scale with _$Scale {
  const factory Scale({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "scale") required String scale,
    @JsonKey(name: "unselect") required String unselect,
    @JsonKey(name: "selected") required String selected,
  }) = _Scale;

  factory Scale.fromJson(Map<String, dynamic> json) => _$ScaleFromJson(json);
}

@freezed
class Style with _$Style {
  const factory Style({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "title") required String title,
    @JsonKey(name: "url") required String url,
  }) = _Style;

  factory Style.fromJson(Map<String, dynamic> json) => _$StyleFromJson(json);
}

@freezed
class Tts with _$Tts {
  const factory Tts({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "name") required String name,
    @JsonKey(name: "header_image") required String headerImage,
    @JsonKey(name: "title") required String title,
    @JsonKey(name: "speaker") required String speaker,
    @JsonKey(name: "need_vip") required int needVip,
    @JsonKey(name: "integral") required int integral,
    @JsonKey(name: "show_name") required String showName,
    @JsonKey(name: "demo_url") required String demoUrl,
    @JsonKey(name: "isCollect") required int isCollect,
    @JsonKey(name: "mx_speed") required int mxSpeed,
    @JsonKey(name: "mx_intonation") required int mxIntonation,
  }) = _Tts;

  factory Tts.fromJson(Map<String, dynamic> json) => _$TtsFromJson(json);
}
