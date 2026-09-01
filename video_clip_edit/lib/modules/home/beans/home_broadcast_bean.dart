// To parse this JSON data, do
//
//     final homeBroadcastBean = homeBroadcastBeanFromJson(jsonString);

import 'dart:convert';

HomeBroadcastBean homeBroadcastBeanFromJson(String str) =>
    HomeBroadcastBean.fromJson(json.decode(str));

String homeBroadcastBeanToJson(HomeBroadcastBean data) =>
    json.encode(data.toJson());

class HomeBroadcastBean {
  String title;

  HomeBroadcastBean({
    required this.title,
  });

  factory HomeBroadcastBean.fromJson(Map<String, dynamic> json) =>
      HomeBroadcastBean(
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
      };
}
