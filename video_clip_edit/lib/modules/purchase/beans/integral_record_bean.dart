// To parse this JSON data, do
//
//     final integralRecordBean = integralRecordBeanFromJson(jsonString);

import 'dart:convert';

IntegralRecordBean integralRecordBeanFromJson(String str) =>
    IntegralRecordBean.fromJson(json.decode(str));

String integralRecordBeanToJson(IntegralRecordBean data) =>
    json.encode(data.toJson());

class IntegralRecordBean {
  int integral;
  String des;
  DateTime createdAt;
  int userIntegral;

  IntegralRecordBean({
    required this.integral,
    required this.des,
    required this.createdAt,
    required this.userIntegral,
  });

  factory IntegralRecordBean.fromJson(Map<String, dynamic> json) =>
      IntegralRecordBean(
        integral: json["integral"],
        des: json["des"],
        createdAt: DateTime.parse(json["created_at"]),
        userIntegral: json["user_integral"],
      );

  Map<String, dynamic> toJson() => {
        "integral": integral,
        "des": des,
        "created_at": createdAt.toIso8601String(),
        "user_integral": userIntegral,
      };
}
