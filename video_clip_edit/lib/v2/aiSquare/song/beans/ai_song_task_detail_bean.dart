// To parse this JSON data, do
//
//     final aiSongTaskDetailBean = aiSongTaskDetailBeanFromJson(jsonString);

import 'dart:convert';

List<AiSongTaskDetailBean> aiSongTaskDetailBeanFromJson(String str) => List<AiSongTaskDetailBean>.from(json.decode(str).map((x) => AiSongTaskDetailBean.fromJson(x)));

String aiSongTaskDetailBeanToJson(List<AiSongTaskDetailBean> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AiSongTaskDetailBean {
  int id;
  String prompt;
  String aprompt;
  String lyrics;
  String style;
  String coverUrl;
  String createAt;
  dynamic lyricsRequestId;
  String audioUrl;
  int status;
  String duration;
  String title;
  int isInstrumental;
  int customMode;
  int singerSex;
  bool isSelect=false;
  String withdrawMoney;
  String useTime;


  @override
  String toString() {
    return 'AiSongTaskDetailBean{id: $id, prompt: $prompt, aprompt: $aprompt, lyrics: $lyrics, style: $style, coverUrl: $coverUrl, createAt: $createAt, lyricsRequestId: $lyricsRequestId, audioUrl: $audioUrl, status: $status, duration: $duration, title: $title, isInstrumental: $isInstrumental, customMode: $customMode, singerSex: $singerSex, isSelect: $isSelect, withdrawMoney: $withdrawMoney, useTime: $useTime}';
  }

  AiSongTaskDetailBean({
    required this.id,
    required this.prompt,
    required this.aprompt,
    required this.lyrics,
    required this.style,
    required this.coverUrl,
    required this.createAt,
    required this.lyricsRequestId,
    required this.audioUrl,
    required this.status,
    required this.duration,
    required this.title,
    required this.isInstrumental,
    required this.customMode,
    required this.singerSex,
    required this.withdrawMoney,
    required this.useTime,
  });


  factory AiSongTaskDetailBean.fromJson(Map<String, dynamic> json) => AiSongTaskDetailBean(
    id: json["id"],
    prompt: json["prompt"]??"",
    aprompt: json["aprompt"]??"",
    lyrics: json["lyrics"]??"",
    style: json["style"]??"",
    coverUrl: json["cover_url"]??"",
    createAt: json["create_at"]??"",
    lyricsRequestId: json["lyrics_request_id"]??"",
    audioUrl: json["audio_url"]??"",
    status: json["status"]??"",
    duration: json["duration"]??"",
    title: json["title"]??"",
    isInstrumental: json["is_instrumental"]??"",
    customMode: json["custom_mode"]??"",
    singerSex: json["singer_sex"]??"",
      withdrawMoney: json["withdraw_money"]??"",
      useTime: json["use_time"]??""
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "prompt": prompt,
    "aprompt": aprompt,
    "lyrics": lyrics,
    "style": style,
    "cover_url": coverUrl,
    "create_at": createAt,
    "lyrics_request_id": lyricsRequestId,
    "audio_url": audioUrl,
    "status": status,
    "duration": duration,
    "title": title,
    "is_instrumental": isInstrumental,
    "custom_mode": customMode,
    "singer_sex": singerSex,
    "withdraw_money": customMode,
    "use_time": singerSex,
  };
}
