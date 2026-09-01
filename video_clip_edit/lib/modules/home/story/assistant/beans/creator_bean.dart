// To parse this JSON data, do
//
//     final creatorBean = creatorBeanFromJson(jsonString);

import 'dart:convert';

CreatorBean creatorBeanFromJson(String str) =>
    CreatorBean.fromJson(json.decode(str));

String creatorBeanToJson(CreatorBean data) => json.encode(data.toJson());

class CreatorBean {
  String id;
  String title;
  String icon;
  String background;
  String background2;
  int hotNum;
  String des;
  int isHot;

  CreatorBean({
    required this.id,
    required this.title,
    required this.icon,
    required this.background,
    required this.background2,
    required this.hotNum,
    required this.des,
    required this.isHot,
  });

  factory CreatorBean.fromJson(Map<String, dynamic> json) => CreatorBean(
        id: json["id"],
        title: json["title"],
        icon: json["icon"],
        background: json["background"],
        background2: json["background_2"],
        hotNum: json["hot_num"],
        des: json["des"],
        isHot: json["is_hot"],
      );
  factory CreatorBean.fromIdAndTitle({
    required String id,
    String? title,
  }) =>
      CreatorBean(
        id: id,
        title: title ?? "",
        icon: "",
        background: "",
        background2: "",
        hotNum: 0,
        des: "",
        isHot: 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "icon": icon,
        "background": background,
        "background_2": background2,
        "hot_num": hotNum,
        "des": des,
        "is_hot": isHot,
      };
}
