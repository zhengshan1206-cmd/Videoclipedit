// To parse this JSON data, do
//
//     final homeBannerBean = homeBannerBeanFromJson(jsonString);

import 'dart:convert';

HomeBannerBean homeBannerBeanFromJson(String str) =>
    HomeBannerBean.fromJson(json.decode(str));

String homeBannerBeanToJson(HomeBannerBean data) => json.encode(data.toJson());

class HomeBannerBean {
  int id;
  String title;
  String imgUrl;
  String jumpUrl;
  String jumpParam;
  int type;
  String des;

  HomeBannerBean({
    required this.id,
    required this.title,
    required this.imgUrl,
    required this.jumpUrl,
    required this.jumpParam,
    required this.type,
    required this.des,
  });

  factory HomeBannerBean.fromJson(Map<String, dynamic> json) => HomeBannerBean(
        id: json["id"],
        title: json["title"],
        imgUrl: json["img_url"],
        jumpUrl: json["jump_url"],
        jumpParam: json["jump_param"],
        type: json["type"],
        des: json["des"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "img_url": imgUrl,
        "jump_url": jumpUrl,
        "jump_param": jumpParam,
        "type": type,
        "des": des,
      };
}
