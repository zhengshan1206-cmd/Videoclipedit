// To parse this JSON data, do
//
//     final extractionRecordBean = extractionRecordBeanFromJson(jsonString);

import 'dart:convert';

ExtractionRecordBean extractionRecordBeanFromJson(String str) =>
    ExtractionRecordBean.fromJson(json.decode(str));

String extractionRecordBeanToJson(ExtractionRecordBean data) =>
    json.encode(data.toJson());

class ExtractionRecordBean {
  int id;
  DateTime date;
  int userId;
  String shareUrlMd5;
  String shareUrl;
  Content? content;
  dynamic deleteTime;
  DateTime createAt;
  String updateAt;

  ExtractionRecordBean({
    required this.id,
    required this.date,
    required this.userId,
    required this.shareUrlMd5,
    required this.shareUrl,
    required this.content,
    required this.deleteTime,
    required this.createAt,
    required this.updateAt,
  });

  factory ExtractionRecordBean.fromJson(Map<String, dynamic> json) {
    print(
        "json[content]:${json["content"]} --- == {}:${json["content"].isEmpty}");
    return ExtractionRecordBean(
      id: json["id"],
      date: DateTime.parse(json["date"]),
      userId: json["user_id"],
      shareUrlMd5: json["share_url_md5"],
      shareUrl: json["share_url"],
      content: (json["content"] == null || json["content"].isEmpty)
          ? null
          : Content.fromJson(json["content"]),
      deleteTime: json["delete_time"],
      createAt: DateTime.parse(json["create_at"]),
      updateAt: json["update_at"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "user_id": userId,
        "share_url_md5": shareUrlMd5,
        "share_url": shareUrl,
        "content": content?.toJson() ?? {},
        "delete_time": deleteTime,
        "create_at": createAt.toIso8601String(),
        "update_at": updateAt,
      };
}

class Content {
  Author author;
  String title;
  String videoUrl;
  String musicUrl;
  String coverUrl;
  dynamic images;

  Content({
    required this.author,
    required this.title,
    required this.videoUrl,
    required this.musicUrl,
    required this.coverUrl,
    required this.images,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      author: Author.fromJson(json["author"]),
      title: json["title"],
      videoUrl: json["video_url"],
      musicUrl: json["music_url"],
      coverUrl: json["cover_url"],
      images: json["images"],
    );
  }

  Map<String, dynamic> toJson() => {
        "author": author.toJson(),
        "title": title,
        "video_url": videoUrl,
        "music_url": musicUrl,
        "cover_url": coverUrl,
        "images": images,
      };
}

class Author {
  String uid;
  String name;
  String avatar;

  Author({
    required this.uid,
    required this.name,
    required this.avatar,
  });

  factory Author.fromJson(Map<String, dynamic> json) => Author(
        uid: json["uid"],
        name: json["name"],
        avatar: json["avatar"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "avatar": avatar,
      };
}
