// To parse this JSON data, do
//
//     final bgmCategoryBean = bgmCategoryBeanFromJson(jsonString);

import 'dart:convert';

BgmCategoryBean bgmCategoryBeanFromJson(String str) =>
    BgmCategoryBean.fromJson(json.decode(str));

String bgmCategoryBeanToJson(BgmCategoryBean data) =>
    json.encode(data.toJson());

class BgmCategoryBean {
  int id;
  String title;
  int sort;
  int status;
  DateTime createAt;
  String updateAt;

  BgmCategoryBean({
    required this.id,
    required this.title,
    required this.sort,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });

  factory BgmCategoryBean.fromJson(Map<String, dynamic> json) =>
      BgmCategoryBean(
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
