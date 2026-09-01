// To parse this JSON data, do
//
//     final bgmItemBean = bgmItemBeanFromJson(jsonString);

import 'dart:convert';

AiCartoonBgmBean bgmItemBeanFromJson(String str) =>
    AiCartoonBgmBean.fromJson(json.decode(str));

String bgmItemBeanToJson(AiCartoonBgmBean data) => json.encode(data.toJson());

class AiCartoonBgmBean {
  int id;
  String title;
  dynamic icon;
  String url;

  AiCartoonBgmBean({
    required this.id,
    required this.title,
    required this.icon,
    required this.url,
  });

  factory AiCartoonBgmBean.fromJson(Map<String, dynamic> json) =>
      AiCartoonBgmBean(
        id: json["id"],
        title: json["title"],
        icon: json["icon"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "icon": icon,
        "url": url,
      };
}
