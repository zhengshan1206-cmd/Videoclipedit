import 'package:freezed_annotation/freezed_annotation.dart';
part 'ai_draw_style_case_bean.freezed.dart';
part 'ai_draw_style_case_bean.g.dart';

@freezed
class AiDrawStyleCaseBean with _$AiDrawStyleCaseBean {
  const factory AiDrawStyleCaseBean({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "status") required int status,
    @JsonKey(name: "prompt") required String prompt,
    @JsonKey(name: "mini_pic_url") required String miniPicUrl,
    @JsonKey(name: "pic_url") required String picUrl,
    @JsonKey(name: "ratio") required String ratio,
    @JsonKey(name: "model_id") required int modelId,
    @JsonKey(name: "model") required String model,
    @JsonKey(name: "labels") required List<String> labels,
    @JsonKey(name: "active_user_name") required String activeUserName,
    @JsonKey(name: "active_user_avatar") required String activeUserAvatar,
    @JsonKey(name: "active_user_create_days") required int activeUserCreateDays,
    @JsonKey(name: "use_time") required String useTime,
    @JsonKey(name: "withdraw_money") required String withdrawMoney,
    @JsonKey(name: "withdraw_money_tip") required String withdrawMoneyTip,
  }) = _AiDrawStyleCaseBean;

  factory AiDrawStyleCaseBean.fromJson(Map<String, dynamic> json) =>
      _$AiDrawStyleCaseBeanFromJson(json);
}
