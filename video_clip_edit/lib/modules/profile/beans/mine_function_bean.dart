// To parse this JSON data, do
//
//     final mineFunctionBean = mineFunctionBeanFromJson(jsonString);

import 'dart:convert';

MineFunctionBean mineFunctionBeanFromJson(String str) =>
    MineFunctionBean.fromJson(json.decode(str));

String mineFunctionBeanToJson(MineFunctionBean data) =>
    json.encode(data.toJson());

class MineFunctionBean {
  String icon;
  String name;

  MineFunctionBean({
    required this.icon,
    required this.name,
  });

  factory MineFunctionBean.fromJson(Map<String, dynamic> json) =>
      MineFunctionBean(
        icon: json["icon"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "icon": icon,
        "name": name,
      };
}
