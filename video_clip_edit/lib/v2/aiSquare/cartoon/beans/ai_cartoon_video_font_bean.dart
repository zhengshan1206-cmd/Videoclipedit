import 'dart:convert';

class AiCartoonVideoFontBean {
  int id;
  String title;
  String url;

  AiCartoonVideoFontBean({
    required this.id,
    required this.title,
    required this.url,
  });

  AiCartoonVideoFontBean copyWith({
    int? id,
    String? title,
    String? url,
  }) =>
      AiCartoonVideoFontBean(
        id: id ?? this.id,
        title: title ?? this.title,
        url: url ?? this.url,
      );

  factory AiCartoonVideoFontBean.fromRawJson(String str) =>
      AiCartoonVideoFontBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiCartoonVideoFontBean.fromJson(Map<String, dynamic> json) =>
      AiCartoonVideoFontBean(
        id: json["id"],
        title: json["title"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "url": url,
      };
}
