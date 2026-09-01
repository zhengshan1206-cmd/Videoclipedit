// To parse this JSON data, do
//
//     final questionInfoBean = questionInfoBeanFromJson(jsonString);

import 'dart:convert';

QuestionInfoBean questionInfoBeanFromJson(String str) =>
    QuestionInfoBean.fromJson(json.decode(str));

String questionInfoBeanToJson(QuestionInfoBean data) =>
    json.encode(data.toJson());

class QuestionInfoBean {
  int isMoney;
  String token;
  String? copywriting;
  int? needIntegral;

  QuestionInfoBean({
    required this.isMoney,
    required this.token,
    required this.copywriting,
    required this.needIntegral,
  });

  factory QuestionInfoBean.fromJson(Map<String, dynamic> json) =>
      QuestionInfoBean(
        isMoney: json["is_money"],
        token: json["token"],
        copywriting: json["copywriting"],
        needIntegral: json["need_integral"],
      );

  Map<String, dynamic> toJson() => {
        "is_money": isMoney,
        "token": token,
        "copywriting": copywriting,
        "need_integral": needIntegral,
      };
}
