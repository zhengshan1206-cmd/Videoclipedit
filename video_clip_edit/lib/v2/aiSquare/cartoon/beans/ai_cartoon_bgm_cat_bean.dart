// To parse this JSON data, do
//
//     final bgmCategoryBean = bgmCategoryBeanFromJson(jsonString);

import 'dart:convert';

AiCartoonBgmCatBean bgmCategoryBeanFromJson(String str) =>
    AiCartoonBgmCatBean.fromJson(json.decode(str));

String bgmCategoryBeanToJson(AiCartoonBgmCatBean data) =>
    json.encode(data.toJson());

class AiCartoonBgmCatBean {
  int id;
  String title;
  int sort;
  int status;
  DateTime createAt;
  String updateAt;

  AiCartoonBgmCatBean({
    required this.id,
    required this.title,
    required this.sort,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });

  factory AiCartoonBgmCatBean.fromJson(Map<String, dynamic> json) =>
      AiCartoonBgmCatBean(
        id: json["id"],
        title: json["title"],
        sort: json["sort"],
        status: json["status"],
        createAt: DateTime.parse(json["create_at"]),
        updateAt: json["update_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "sort": sort,
        "status": status,
        "create_at": createAt.toIso8601String(),
        "update_at": updateAt,
      };
}
