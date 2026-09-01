import 'dart:convert';

class AiOralAudioBean {
  String icon;
  String title;
  int index;
  AiOralAudioBean({
    required this.icon,
    required this.title,
    required this.index,
  });

  AiOralAudioBean copyWith({
    String? icon,
    String? title,
    int? index,
  }) =>
      AiOralAudioBean(
        icon: icon ?? this.icon,
        title: title ?? this.title,
        index: index??this.index,
      );

  factory AiOralAudioBean.fromRawJson(String str) =>
      AiOralAudioBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiOralAudioBean.fromJson(Map<String, dynamic> json) =>
      AiOralAudioBean(
        icon: json["icon"],
        title: json["title"],
        index: json["index"]
      );

  Map<String, dynamic> toJson() => {
        "icon": icon,
        "title": title,
         "index":index,
      };
}
