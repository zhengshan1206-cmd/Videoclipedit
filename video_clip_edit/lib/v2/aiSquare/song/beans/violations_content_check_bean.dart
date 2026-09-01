// To parse this JSON data, do
//
//     final violationsContentCheckBean = violationsContentCheckBeanFromJson(jsonString);

import 'dart:convert';

ViolationsContentCheckBean violationsContentCheckBeanFromJson(String str) => ViolationsContentCheckBean.fromJson(json.decode(str));

String violationsContentCheckBeanToJson(ViolationsContentCheckBean data) => json.encode(data.toJson());

class ViolationsContentCheckBean {
  bool isRisk;
  List<dynamic> labelName;
  String markContent;

  ViolationsContentCheckBean({
    required this.isRisk,
    required this.labelName,
    required this.markContent,
  });

  factory ViolationsContentCheckBean.fromJson(Map<String, dynamic> json) => ViolationsContentCheckBean(
    isRisk: json["isRisk"] ?? false,
    labelName: List<dynamic>.from(json["labelName"]??[].map((x) => x)),
    markContent: json["markContent"]??"",
  );

  Map<String, dynamic> toJson() => {
    "isRisk": isRisk ,
    "labelName": List<dynamic>.from(labelName.map((x) => x)),
    "markContent": markContent,
  };
}