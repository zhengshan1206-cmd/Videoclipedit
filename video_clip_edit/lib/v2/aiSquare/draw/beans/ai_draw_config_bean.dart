import 'package:freezed_annotation/freezed_annotation.dart';
part 'ai_draw_config_bean.freezed.dart';
part 'ai_draw_config_bean.g.dart';

@freezed
class AiDrawConfigBean with _$AiDrawConfigBean {
  const factory AiDrawConfigBean({
    @JsonKey(name: "ratios") required List<Ratio> ratios,
    @JsonKey(name: "imgStyles") required List<ImgStyle> imgStyles,
  }) = _AiDrawConfigBean;

  factory AiDrawConfigBean.fromJson(Map<String, dynamic> json) =>
      _$AiDrawConfigBeanFromJson(json);
}

@freezed
class ImgStyle with _$ImgStyle {
  const factory ImgStyle({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "title") required String title,
    @JsonKey(name: "url") required String url,
    @JsonKey(name: "prompts") required List<String> prompts,
    @JsonKey(name: "integral_user") required int integralUser,
  }) = _ImgStyle;

  factory ImgStyle.fromJson(Map<String, dynamic> json) =>
      _$ImgStyleFromJson(json);
}

@freezed
class Ratio with _$Ratio {
  const factory Ratio({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "scale") required String scale,
    @JsonKey(name: "pic1") required String pic1,
    @JsonKey(name: "pic2") required String pic2,
  }) = _Ratio;

  factory Ratio.fromJson(Map<String, dynamic> json) => _$RatioFromJson(json);
}
