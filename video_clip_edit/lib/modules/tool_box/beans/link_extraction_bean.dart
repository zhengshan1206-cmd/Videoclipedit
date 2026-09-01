// To parse this JSON data, do
//
//     final linkExtractionBean = linkExtractionBeanFromJson(jsonString);

import 'dart:convert';

LinkExtractionBean linkExtractionBeanFromJson(String str) =>
    LinkExtractionBean.fromJson(json.decode(str));

String linkExtractionBeanToJson(LinkExtractionBean data) =>
    json.encode(data.toJson());

class LinkExtractionBean {
  Author author;
  String title;
  String videoUrl;
  String musicUrl;
  String coverUrl;
  dynamic images;

  LinkExtractionBean({
    required this.author,
    required this.title,
    required this.videoUrl,
    required this.musicUrl,
    required this.coverUrl,
    required this.images,
  });

  factory LinkExtractionBean.fromJson(Map<String, dynamic> json) =>
      LinkExtractionBean(
        author: Author.fromJson(json["author"]),
        title: json["title"],
        videoUrl: json["video_url"],
        musicUrl: json["music_url"],
        coverUrl: json["cover_url"],
        images: json["images"],
      );

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
