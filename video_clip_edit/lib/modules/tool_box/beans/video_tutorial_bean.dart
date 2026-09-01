// To parse this JSON data, do
//
//     final videoTutorialBean = videoTutorialBeanFromJson(jsonString);

import 'dart:convert';

VideoTutorialBean videoTutorialBeanFromJson(String str) =>
    VideoTutorialBean.fromJson(json.decode(str));

String videoTutorialBeanToJson(VideoTutorialBean data) =>
    json.encode(data.toJson());

class VideoTutorialBean {
  int jumpToPosition;
  List<String> jumpTo;
  int isRead;
  int id;
  List<dynamic> sonList;

  VideoTutorialBean({
    required this.jumpToPosition,
    required this.jumpTo,
    required this.isRead,
    required this.id,
    required this.sonList,
  });

  factory VideoTutorialBean.fromJson(Map<String, dynamic> json) =>
      VideoTutorialBean(
        jumpToPosition: json["jump_to_position"],
        jumpTo: List<String>.from(json["jump_to"].map((x) => x)),
        isRead: json["is_read"],
        id: json["id"],
        sonList: List<dynamic>.from(json["son_list"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "jump_to_position": jumpToPosition,
        "jump_to": List<dynamic>.from(jumpTo.map((x) => x)),
        "is_read": isRead,
        "id": id,
        "son_list": List<dynamic>.from(sonList.map((x) => x)),
      };
}
