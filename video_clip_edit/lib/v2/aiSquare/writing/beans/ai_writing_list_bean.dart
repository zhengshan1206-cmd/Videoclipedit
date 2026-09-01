// To parse this JSON data, do
//
//     final creatorBean = creatorBeanFromJson(jsonString);

import 'dart:convert';

AiWritingListBean creatorBeanFromJson(String str) =>
    AiWritingListBean.fromJson(json.decode(str));

String creatorBeanToJson(AiWritingListBean data) => json.encode(data.toJson());

class AiWritingListBean {
  String id;
  String title;
  String icon;
  String background;
  String background2;
  int hotNum;
  String des;
  int isHot;

  AiWritingListBean({
    required this.id,
    required this.title,
    required this.icon,
    required this.background,
    required this.background2,
    required this.hotNum,
    required this.des,
    required this.isHot,
  });

  factory AiWritingListBean.fromJson(Map<String, dynamic> json) => AiWritingListBean(
    id: json["id"],
    title: json["title"],
    icon: json["icon"],
    background: json["background"],
    background2: json["background_2"],
    hotNum: json["hot_num"],
    des: json["des"],
    isHot: json["is_hot"],
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
