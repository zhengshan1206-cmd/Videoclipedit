// To parse this JSON data, do
//
//     final functionItemBean = functionItemBeanFromJson(jsonString);

import 'dart:convert';

FunctionItemBean functionItemBeanFromJson(String str) =>
    FunctionItemBean.fromJson(json.decode(str));

String functionItemBeanToJson(FunctionItemBean data) =>
    json.encode(data.toJson());

class FunctionItemBean {
  String icon;
  String title;
  String desc;

  FunctionItemBean({
    required this.icon,
    required this.title,
    required this.desc,
  });

  factory FunctionItemBean.fromJson(Map<String, dynamic> json) =>
      FunctionItemBean(
        icon: json["icon"],
        title: json["title"],
        desc: json["desc"],
      );

  Map<String, dynamic> toJson() => {
        "icon": icon,
        "title": title,
        "desc": desc,
      };
}
