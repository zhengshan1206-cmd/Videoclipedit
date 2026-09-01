// To parse this JSON data, do
//
//     final bgmItemBean = bgmItemBeanFromJson(jsonString);

import 'dart:convert';

BgmItemBean bgmItemBeanFromJson(String str) =>
    BgmItemBean.fromJson(json.decode(str));

String bgmItemBeanToJson(BgmItemBean data) => json.encode(data.toJson());

class BgmItemBean {
  int id;
  String title;
  dynamic icon;
  String url;

  BgmItemBean({
    required this.id,
    required this.title,
    required this.icon,
    required this.url,
  });

  factory BgmItemBean.fromJson(Map<String, dynamic> json) => BgmItemBean(
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
