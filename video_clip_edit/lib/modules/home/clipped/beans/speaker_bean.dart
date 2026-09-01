// To parse this JSON data, do
//
//     final speakerBean = speakerBeanFromJson(jsonString);

import 'dart:convert';

SpeakerBean speakerBeanFromJson(String str) =>
    SpeakerBean.fromJson(json.decode(str));

String speakerBeanToJson(SpeakerBean data) => json.encode(data.toJson());

class SpeakerBean {
  int id;
  String name;
  String headerImage;
  String title;
  String speaker;
  int needVip;
  int integral;
  String showName;
  String demoUrl;
  int isCollect;

  SpeakerBean({
    required this.id,
    required this.name,
    required this.headerImage,
    required this.title,
    required this.speaker,
    required this.needVip,
    required this.integral,
    required this.showName,
    required this.demoUrl,
    required this.isCollect,
  });

  SpeakerBean copyWith({
    int? id,
    String? name,
    String? headerImage,
    String? title,
    String? speaker,
    int? needVip,
    int? integral,
    String? showName,
    String? demoUrl,
    int? isCollect,
  }) =>
      SpeakerBean(
        id: id ?? this.id,
        name: name ?? this.name,
        headerImage: headerImage ?? this.headerImage,
        title: title ?? this.title,
        speaker: speaker ?? this.speaker,
        needVip: needVip ?? this.needVip,
        integral: integral ?? this.integral,
        showName: showName ?? this.showName,
        demoUrl: demoUrl ?? this.demoUrl,
        isCollect: isCollect ?? this.isCollect,
      );

  factory SpeakerBean.fromJson(Map<String, dynamic> json) => SpeakerBean(
        id: json["id"],
        name: json["name"],
        headerImage: json["header_image"],
        title: json["title"] ?? "",
        speaker: json["speaker"],
        needVip: json["need_vip"] ?? -1,
        integral: json["integral"] ?? -1,
        showName: json["show_name"],
        demoUrl: json["demo_url"],
        isCollect: json["isCollect"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "header_image": headerImage,
        "title": title,
        "speaker": speaker,
        "need_vip": needVip,
        "integral": integral,
        "show_name": showName,
        "demo_url": demoUrl,
        "isCollect": isCollect,
      };
}
