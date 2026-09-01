// To parse this JSON data, do
//
//     final preLoginConfigBean = preLoginConfigBeanFromJson(jsonString);

import 'dart:convert';

PreLoginConfigBean preLoginConfigBeanFromJson(String str) =>
    PreLoginConfigBean.fromJson(json.decode(str));

String preLoginConfigBeanToJson(PreLoginConfigBean data) =>
    json.encode(data.toJson());

class PreLoginConfigBean {
  String group;
  String key;
  String name;
  int valType;
  String valText;
  String des;

  PreLoginConfigBean({
    required this.group,
    required this.key,
    required this.name,
    required this.valType,
    required this.valText,
    required this.des,
  });

  factory PreLoginConfigBean.fromJson(Map<String, dynamic> json) =>
      PreLoginConfigBean(
        group: json["group"],
        key: json["key"],
        name: json["name"],
        valType: json["val_type"],
        valText: json["val_text"],
        des: json["des"],
      );

  Map<String, dynamic> toJson() => {
        "group": group,
        "key": key,
        "name": name,
        "val_type": valType,
        "val_text": valText,
        "des": des,
      };
}
