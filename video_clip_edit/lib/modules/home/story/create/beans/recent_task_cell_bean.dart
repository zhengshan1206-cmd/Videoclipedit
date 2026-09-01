// To parse this JSON data, do
//
//     final recentTaskCellBean = recentTaskCellBeanFromJson(jsonString);

import 'dart:convert';

RecentTaskCellBean recentTaskCellBeanFromJson(String str) =>
    RecentTaskCellBean.fromJson(json.decode(str));

String recentTaskCellBeanToJson(RecentTaskCellBean data) =>
    json.encode(data.toJson());

class RecentTaskCellBean {
  String title;
  String date;
  String contents;

  RecentTaskCellBean({
    required this.title,
    required this.date,
    required this.contents,
  });

  factory RecentTaskCellBean.fromJson(Map<String, dynamic> json) =>
      RecentTaskCellBean(
        title: json["title"],
        date: json["date"],
        contents: json["contents"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "date": date,
        "contents": contents,
      };
}
