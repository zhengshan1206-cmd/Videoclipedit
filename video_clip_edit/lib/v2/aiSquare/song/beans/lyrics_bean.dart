// To parse this JSON data, do
//
//     final lyricsBean = lyricsBeanFromJson(jsonString);

import 'dart:convert';

List<LyricsBean> lyricsBeanFromJson(String str) => List<LyricsBean>.from(json.decode(str).map((x) => LyricsBean.fromJson(x)));

String lyricsBeanToJson(List<LyricsBean> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LyricsBean {
  int startTime;
  String endTime;
  String text;

  LyricsBean({
    required this.startTime,
    required this.endTime,
    required this.text,
  });

  factory LyricsBean.fromJson(Map<String, dynamic> json) => LyricsBean(
    startTime: json["start_time"],
    endTime: json["end_time"],
    text: json["text"],
  );

  Map<String, dynamic> toJson() => {
    "start_time": startTime,
    "end_time": endTime,
    "text": text,
  };
}
