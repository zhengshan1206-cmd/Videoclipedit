import 'package:freezed_annotation/freezed_annotation.dart';
part 'ai_draw_img_details_bean.freezed.dart';
part 'ai_draw_img_details_bean.g.dart';

@freezed
class AiDrawImgDetailsBean with _$AiDrawImgDetailsBean {
  const factory AiDrawImgDetailsBean({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "status") required int status,
    @JsonKey(name: "prompt") required String prompt,
    @JsonKey(name: "pic_url") required String picUrl,
    @JsonKey(name: "ratio") required String ratio,
    @JsonKey(name: "model_id") required int modelId,
    @JsonKey(name: "model") required String model,
    @JsonKey(name: "created_at") required String? createdAt,
  }) = _AiDrawImgDetailsBean;

  factory AiDrawImgDetailsBean.fromJson(Map<String, dynamic> json) =>
      _$AiDrawImgDetailsBeanFromJson(json);
}
