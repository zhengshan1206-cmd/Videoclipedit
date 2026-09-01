import 'dart:convert';

class NewToolBoxCategoryBean {
  int id;
  int postionId;
  String title;
  String icon;
  String mark;
  int style;

  NewToolBoxCategoryBean({
    required this.id,
    required this.postionId,
    required this.title,
    required this.icon,
    required this.mark,
    required this.style,
  });

  NewToolBoxCategoryBean copyWith({
    int? id,
    int? postionId,
    String? title,
    String? icon,
    String? mark,
    int? style,
  }) =>
      NewToolBoxCategoryBean(
        id: id ?? this.id,
        postionId: postionId ?? this.postionId,
        title: title ?? this.title,
        icon: icon ?? this.icon,
        mark: mark ?? this.mark,
        style: style ?? this.style,
      );

  factory NewToolBoxCategoryBean.fromRawJson(String str) =>
      NewToolBoxCategoryBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NewToolBoxCategoryBean.fromJson(Map<String, dynamic> json) =>
      NewToolBoxCategoryBean(
        id: json["id"],
        postionId: json["postion_id"],
        title: json["title"],
        icon: json["icon"],
        mark: json["mark"],
        style: json["style"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "postion_id": postionId,
        "title": title,
        "icon": icon,
        "mark": mark,
        "style": style,
      };
}
