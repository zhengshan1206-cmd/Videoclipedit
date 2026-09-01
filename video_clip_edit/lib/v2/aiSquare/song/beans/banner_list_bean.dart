// To parse this JSON data, do
//
//     final bannerListBean = bannerListBeanFromJson(jsonString);

import 'dart:convert';

List<BannerListBean> bannerListBeanFromJson(String str) => List<BannerListBean>.from(json.decode(str).map((x) => BannerListBean.fromJson(x)));

String bannerListBeanToJson(List<BannerListBean> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BannerListBean {
  int id;
  String prompt;
  String aprompt;
  String lyrics;
  String style;
  String coverUrl;
  String audioUrl;
  int status;
  DateTime createAt;
  String duration;
  String title;
  int isInstrumental;
  int customMode;
  int singerSex;

  BannerListBean({
    required this.id,
    required this.prompt,
    required this.aprompt,
    required this.lyrics,
    required this.style,
    required this.coverUrl,
    required this.audioUrl,
    required this.status,
    required this.createAt,
    required this.duration,
    required this.title,
    required this.isInstrumental,
    required this.customMode,
    required this.singerSex,
  });

  factory BannerListBean.fromJson(Map<String, dynamic> json) => BannerListBean(
    id: json["id"],
    prompt: json["prompt"],
    aprompt: json["aprompt"],
    lyrics: json["lyrics"],
    style: json["style"],
    coverUrl: json["cover_url"],
    audioUrl: json["audio_url"],
    status: json["status"],
    createAt: DateTime.parse(json["create_at"]),
    duration: json["duration"],
    title: json["title"],
    isInstrumental: json["is_instrumental"],
    customMode: json["custom_mode"],
    singerSex: json["singer_sex"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "prompt": prompt,
    "aprompt": aprompt,
    "lyrics": lyrics,
    "style": style,
    "cover_url": coverUrl,
    "audio_url": audioUrl,
    "status": status,
    "create_at": createAt.toIso8601String(),
    "duration": duration,
    "title": title,
    "is_instrumental": isInstrumental,
    "custom_mode": customMode,
    "singer_sex": singerSex,
  };
}
