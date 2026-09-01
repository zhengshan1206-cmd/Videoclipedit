import 'dart:convert';

import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';

class AiShowListItemBean {
  int id;
  // int materialPackId;
  String videoTitle;
  String videoUrl;
  String coverUrl;
  double duration;
  String fullVideoTitle;
  // int scale;
  // int filesize;
  // int sort;
  // int status;
  // int deleteTime;
  // int isDemo;
  DateTime createAt;
  DateTime updateAt;

  // int id;
  // String videoUrl;
  // String coverUrl;
  // num duration;
  // String fullVideoTitle;
  // DateTime createAt;
  // DateTime updateAt;
  // String videoTitle;
  // String content;

  // int materialPackId;
  // String? savePath;
  // int scale;
  // int sort;
  // int status;
  // int isDemo;

  AiShowListItemBean({
    required this.id,
    // required this.materialPackId,
    required this.videoTitle,
    required this.fullVideoTitle,
    required this.videoUrl,
    required this.coverUrl,
    required this.duration,
    // required this.scale,
    // required this.filesize,
    // required this.sort,
    // required this.status,
    // required this.deleteTime,
    // required this.isDemo,
    required this.createAt,
    required this.updateAt,
  });

  AiShowListItemBean copyWith({
    int? id,
    int? materialPackId,
    String? videoTitle,
    String? fullVideoTitle,
    String? videoUrl,
    String? coverUrl,
    double? duration,
    int? scale,
    int? filesize,
    int? sort,
    int? status,
    int? deleteTime,
    int? isDemo,
    DateTime? createAt,
    DateTime? updateAt,
  }) =>
      AiShowListItemBean(
        id: id ?? this.id,
        // materialPackId: materialPackId ?? this.materialPackId,
        videoTitle: videoTitle ?? this.videoTitle,
        fullVideoTitle: fullVideoTitle ?? this.fullVideoTitle,
        videoUrl: videoUrl ?? this.videoUrl,
        coverUrl: coverUrl ?? this.coverUrl,
        duration: duration ?? this.duration,
        // scale: scale ?? this.scale,
        // filesize: filesize ?? this.filesize,
        // sort: sort ?? this.sort,
        // status: status ?? this.status,
        // deleteTime: deleteTime ?? this.deleteTime,
        // isDemo: isDemo ?? this.isDemo,
        createAt: createAt ?? this.createAt,
        updateAt: updateAt ?? this.updateAt,
      );

  factory AiShowListItemBean.fromRawJson(String str) =>
      AiShowListItemBean.fromJson(json.decode(str));

  factory AiShowListItemBean.fromDetail(Detail detal) =>
      AiShowListItemBean.fromJson(detal.toJson());

  String toRawJson() => json.encode(toJson());

  factory AiShowListItemBean.fromJson(Map<String, dynamic> json){
    num duration =  json["duration"];
    return AiShowListItemBean(
      id: json["id"],
      // materialPackId: json["material_pack_id"],
      videoTitle: json["video_title"],
      fullVideoTitle: json["full_video_title"],
      videoUrl: json["video_url"],
      coverUrl: json["cover_url"],
      duration: duration.toDouble(),
      // scale: json["scale"],
      // filesize: json["filesize"],
      // sort: json["sort"],
      // status: json["status"],
      // deleteTime: json["delete_time"],
      // isDemo: json["is_demo"],
      createAt: DateTime.parse(json["create_at"]),
      updateAt: DateTime.parse(json["update_at"]),
    );
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        // "material_pack_id": materialPackId,
        "video_title": videoTitle,
        "full_video_title": fullVideoTitle,
        "video_url": videoUrl,
        "cover_url": coverUrl,
        "duration": duration,
        // "scale": scale,
        // "filesize": filesize,
        // "sort": sort,
        // "status": status,
        // "delete_time": deleteTime,
        // "is_demo": isDemo,
        "create_at": createAt.toIso8601String(),
        "update_at": updateAt.toIso8601String(),
      };
}
