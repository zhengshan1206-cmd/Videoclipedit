import 'dart:convert';

class AiSqureTabBean {
  int id;
  String title;
  String icon;

  AiSqureTabBean({
    required this.id,
    required this.title,
    required this.icon,
  });

  AiSqureTabBean copyWith({
    int? id,
    String? title,
    String? icon,
  }) =>
      AiSqureTabBean(
        id: id ?? this.id,
        title: title ?? this.title,
        icon: icon ?? this.icon,
      );

  factory AiSqureTabBean.fromRawJson(String str) =>
      AiSqureTabBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiSqureTabBean.fromJson(Map<String, dynamic> json) => AiSqureTabBean(
        id: json["id"],
        title: json["title"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "icon": icon,
      };
}
