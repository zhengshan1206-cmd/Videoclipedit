// To parse this JSON data, do
//
//     final storyExampleBean = storyExampleBeanFromJson(jsonString);

import 'dart:convert';

StoryExampleBean storyExampleBeanFromJson(String str) =>
    StoryExampleBean.fromJson(json.decode(str));

String storyExampleBeanToJson(StoryExampleBean data) =>
    json.encode(data.toJson());

class StoryExampleBean {
  int id;
  String title;
  String des;
  String icon;

  StoryExampleBean({
    required this.id,
    required this.title,
    required this.des,
    required this.icon,
  });

  factory StoryExampleBean.fromJson(Map<String, dynamic> json) =>
      StoryExampleBean(
        id: json["id"],
        title: json["title"],
        des: json["des"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "des": des,
        "icon": icon,
      };
}
