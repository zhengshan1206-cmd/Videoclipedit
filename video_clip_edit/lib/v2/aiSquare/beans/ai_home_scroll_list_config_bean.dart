import 'dart:convert';

class AiHomeScrollListConfigBean {
  int id;
  String title;
  String icon;

  AiHomeScrollListConfigBean({
    required this.id,
    required this.title,
    required this.icon,
  });

  AiHomeScrollListConfigBean copyWith({
    int? id,
    String? title,
    String? icon,
  }) =>
      AiHomeScrollListConfigBean(
        id: id ?? this.id,
        title: title ?? this.title,
        icon: icon ?? this.icon,
      );

  factory AiHomeScrollListConfigBean.fromRawJson(String str) =>
      AiHomeScrollListConfigBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiHomeScrollListConfigBean.fromJson(Map<String, dynamic> json) =>
      AiHomeScrollListConfigBean(
        id: json["id"],
        title: json["title"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "icon": icon,
      };
}
