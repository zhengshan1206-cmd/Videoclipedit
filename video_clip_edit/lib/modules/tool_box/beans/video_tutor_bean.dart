// To parse this JSON data, do
//
//     final videoTutorBean = videoTutorBeanFromJson(jsonString);

import 'dart:convert';

VideoTutorBean videoTutorBeanFromJson(String str) =>
    VideoTutorBean.fromJson(json.decode(str));

String videoTutorBeanToJson(VideoTutorBean data) => json.encode(data.toJson());

class VideoTutorBean {
  int id;
  String avatar;
  String nickname;
  DateTime createTime;
  String title;
  String content;
  String videoCover;
  String videoUrl;

  VideoTutorBean({
    required this.id,
    required this.avatar,
    required this.nickname,
    required this.createTime,
    required this.title,
    required this.content,
    required this.videoCover,
    required this.videoUrl,
  });

  factory VideoTutorBean.fromJson(Map<String, dynamic> json) => VideoTutorBean(
        id: json["id"],
        avatar: json["avatar"],
        nickname: json["nickname"],
        createTime: DateTime.parse(json["create_time"]),
        title: json["title"],
        content: json["content"],
        videoCover: json["video_cover"],
        videoUrl: json["video_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "avatar": avatar,
        "nickname": nickname,
        "create_time":
            "${createTime.year.toString().padLeft(4, '0')}-${createTime.month.toString().padLeft(2, '0')}-${createTime.day.toString().padLeft(2, '0')}",
        "title": title,
        "content": content,
        "video_cover": videoCover,
        "video_url": videoUrl,
      };
}
