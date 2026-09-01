
/*
  guide_pop_bean.dart
  攻略弹窗数据模型
  Created by duncy on 25/4/16.
*/

import 'dart:convert';

GuidePopBean userInfoBeanFromJson(String str) =>
    GuidePopBean.fromJson(json.decode(str));

String userInfoBeanToJson(GuidePopBean data) => json.encode(data.toJson());

class GuidePopBean {
  int? jumpType;
  String? url;
  int? isread;
  int? id;
  String? header;
  List<dynamic>? questions;
  int? promotionType;

  GuidePopBean({
    this.jumpType,
    this.url,
    this.isread,
    this.id,
    this.header,
    this.questions,
    this.promotionType,
  });
  factory GuidePopBean.fromJson(Map<String, dynamic> json) => GuidePopBean(
        //优先寻找jump_to_position,再查看com_pr里的类型
        jumpType: json["items"]["jump_to_position"] ?? json["com_pr"][0]["type"],
        url: json["items"]["jump_to"][0] ?? "",
        // url: "https://inchatcdn.beiyinapp.com/inchat/image/video/2025-04-15/364de03b66bf36a6514adc935522b4c9.mp4",
        isread: json["items"]["is_read"],
        id: json["items"]["id"],
        // header: json["com_pr"][0]["header"] ?? "",
        // questions: json["com_pr"][0]["questions"] ?? [],
        // promotionType: json["com_pr"][0]["promotion_type"],
      );
  Map<String, dynamic> toJson() => {
        "jump_type": jumpType,
        "url": url,
        "isread": isread,
        "id": id,
        // "header": header,
        // "questions": questions,
        // "promotion_type": promotionType,
      };

  // int _handleJumpType() {
  //   return 1;
  // }
      
  @override
  String toString() {
    return 'GuidePopBean{jumpType: $jumpType, url: $url, isread: $isread, id: $id}';
  }
}