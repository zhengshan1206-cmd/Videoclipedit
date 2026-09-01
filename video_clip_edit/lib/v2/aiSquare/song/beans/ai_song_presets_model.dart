// To parse this JSON data, do
//
//     final aiSongPresetsModel = aiSongPresetsModelFromJson(jsonString);

import 'dart:convert';

AiSongPresetsModel aiSongPresetsModelFromJson(String str) => AiSongPresetsModel.fromJson(json.decode(str));

String aiSongPresetsModelToJson(AiSongPresetsModel data) => json.encode(data.toJson());

class AiSongPresetsModel {
  int customMode;
  String title;
  String prompt;
  int singerSex;
  String style;

  AiSongPresetsModel({
    required this.customMode,
    required this.title,
    required this.prompt,
    required this.singerSex,
    required this.style,
  });

  factory AiSongPresetsModel.fromJson(Map<String, dynamic> json) => AiSongPresetsModel(
    customMode: json["custom_mode"],
    title: json["title"],
    prompt: json["prompt"],
    singerSex: json["singer_sex"],
    style: json["style"],
  );

  Map<String, dynamic> toJson() => {
    "custom_mode": customMode,
    "title": title,
    "prompt": prompt,
    "singer_sex": singerSex,
    "style": style,
  };
}
