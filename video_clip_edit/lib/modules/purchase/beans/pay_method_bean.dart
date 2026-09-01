// To parse this JSON data, do
//
//     final payMethodBean = payMethodBeanFromJson(jsonString);

import 'dart:convert';

PayMethodBean payMethodBeanFromJson(String str) =>
    PayMethodBean.fromJson(json.decode(str));

String payMethodBeanToJson(PayMethodBean data) => json.encode(data.toJson());

class PayMethodBean {
  String payName;
  String icon;
  String payNameKey;

  PayMethodBean({
    required this.payName,
    required this.icon,
    required this.payNameKey,
  });

  factory PayMethodBean.fromJson(Map<String, dynamic> json) => PayMethodBean(
        payName: json["payName"],
        icon: json["icon"],
        payNameKey: json["payNameKey"],
      );

  Map<String, dynamic> toJson() => {
        "payName": payName,
        "icon": icon,
      };
}
