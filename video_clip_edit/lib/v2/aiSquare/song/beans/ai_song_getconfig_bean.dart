// To parse this JSON data, do
//
//     final aiSongGetconfigBean = aiSongGetconfigBeanFromJson(jsonString);

import 'dart:convert';

List<AiSongGetconfigBean> aiSongGetconfigBeanFromJson(String str) => List<AiSongGetconfigBean>.from(json.decode(str).map((x) => AiSongGetconfigBean.fromJson(x)));

String aiSongGetconfigBeanToJson(List<AiSongGetconfigBean> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AiSongGetconfigBean {
  List<Mode> mode;
  List<Style> style;
  List<Mode> singer;

  AiSongGetconfigBean({
    required this.mode,
    required this.style,
    required this.singer,
  });

  factory AiSongGetconfigBean.fromJson(Map<String, dynamic> json) => AiSongGetconfigBean(
    mode: List<Mode>.from(json["mode"].map((x) => Mode.fromJson(x))),
    style: List<Style>.from(json["style"].map((x) => Style.fromJson(x))),
    singer: List<Mode>.from(json["singer"].map((x) => Mode.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "mode": List<dynamic>.from(mode.map((x) => x.toJson())),
    "style": List<dynamic>.from(style.map((x) => x.toJson())),
    "singer": List<dynamic>.from(singer.map((x) => x.toJson())),
  };
}

class Mode {
  int id;
  String name;
  String tag;
  bool  isSelect=false;

  Mode({
    required this.id,
    required this.name,
    required this.tag,
  });

  factory Mode.fromJson(Map<String, dynamic> json) => Mode(
    id: json["id"],
    name: json["name"],
    tag: json["tag"],
  );

  @override
  String toString() {
    return 'Mode{id: $id, name: $name, tag: $tag,isSelect: $isSelect}';
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "tag": tag,
  };
}

class Style {
  String title;
  List<Mode> items;

  Style({
    required this.title,
    required this.items,
  });

  @override
  String toString() {
    return 'Style{title: $title, items: $items}';
  }

  factory Style.fromJson(Map<String, dynamic> json) => Style(
    title: json["title"],
    items: List<Mode>.from(json["items"].map((x) => Mode.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}
