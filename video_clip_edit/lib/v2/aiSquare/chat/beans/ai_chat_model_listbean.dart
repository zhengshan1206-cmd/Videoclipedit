// To parse this JSON data, do
//
//     final aiChatModelListBean = aiChatModelListBeanFromJson(jsonString);

import 'dart:convert';

AiChatModelListBean aiChatModelListBeanFromJson(String str) =>
    AiChatModelListBean.fromJson(json.decode(str));

String aiChatModelListBeanToJson(AiChatModelListBean data) =>
    json.encode(data.toJson());

class AiChatModelListBean {
  int id;
  String title;
  String desc;
  String modelName;
  int needVip;
  int isDefault;
  // bool isSelect;
  AiChatModelListBean({
    required this.id,
    required this.title,
    required this.desc,
    required this.modelName,
    required this.needVip,
    required this.isDefault,
    // required this.isSelect,
  });

  factory AiChatModelListBean.fromJson(Map<String, dynamic> json) =>
      AiChatModelListBean(
        id: json["id"],
        title: json["title"],
        // isSelect:json["isSelect"]?? false,
        desc: json["desc"],
        modelName: json["model_name"],
        needVip: json["need_vip"],
        isDefault: json["is_default"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "desc": desc,
        "model_name": modelName,
        "need_vip": needVip,
        "is_default": isDefault,
      };
}
