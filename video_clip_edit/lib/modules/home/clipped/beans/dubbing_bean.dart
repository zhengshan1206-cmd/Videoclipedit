// To parse this JSON data, do
//
//     final dubbingBean = dubbingBeanFromJson(jsonString);

import 'dart:convert';

DubbingBean dubbingBeanFromJson(String str) =>
    DubbingBean.fromJson(json.decode(str));

String dubbingBeanToJson(DubbingBean data) => json.encode(data.toJson());

class DubbingBean {
  int id;
  String name;
  int needVip;
  int integral;
  String showName;
  String headerImage;
  String speaker;
  String title;
  String demoUrl;
  int isCollect;
  String speakSpeed;

  DubbingBean({
    required this.id,
    required this.name,
    required this.needVip,
    required this.integral,
    required this.showName,
    required this.headerImage,
    required this.speaker,
    required this.title,
    required this.demoUrl,
    required this.isCollect,
    required this.speakSpeed,
  });

  factory DubbingBean.fromJson(Map<String, dynamic> json) => DubbingBean(
      id: json["id"] ?? -1,
      name: json["name"] ?? "",
      headerImage: json["header_image"] ?? "",
      title: json["title"] ?? "",
      speaker: json["speaker"] ?? "",
      needVip: json["need_vip"] ?? 0,
      integral: json["integral"] ?? 0,
      showName: json["show_name"] ?? "",
      demoUrl: json["demo_url"] ?? "",
      isCollect: json["isCollect"] ?? 0,
      speakSpeed: json["speak_speed"] ?? "1.00");

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "need_vip": needVip,
        "integral": integral,
        "show_name": showName,
        "header_image": headerImage,
        "speaker": speaker,
        "title": title,
        "demo_url": demoUrl,
        "isCollect": isCollect,
        "speak_speed": speakSpeed,
      };
}
