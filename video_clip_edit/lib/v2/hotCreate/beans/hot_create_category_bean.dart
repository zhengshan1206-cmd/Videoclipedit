import 'dart:convert';

class HotCreateCategoryBean {
  int id;
  String title;
  String iconUrl;
  int sort;
  int status;
  int deleteTime;
  String desc;
  String type;
  String createAt;
  String updateAt;

  HotCreateCategoryBean({
    required this.id,
    required this.title,
    required this.iconUrl,
    required this.sort,
    required this.status,
    required this.deleteTime,
    required this.desc,
    required this.type,
    required this.createAt,
    required this.updateAt,
  });

  HotCreateCategoryBean copyWith({
    int? id,
    String? title,
    String? iconUrl,
    int? sort,
    int? status,
    int? deleteTime,
    String? desc,
    String? type,
    String? createAt,
    String? updateAt,
  }) =>
      HotCreateCategoryBean(
        id: id ?? this.id,
        title: title ?? this.title,
        iconUrl: iconUrl ?? this.iconUrl,
        sort: sort ?? this.sort,
        status: status ?? this.status,
        deleteTime: deleteTime ?? this.deleteTime,
        desc: desc ?? this.desc,
        type: type ?? this.type,
        createAt: createAt ?? this.createAt,
        updateAt: updateAt ?? this.updateAt,
      );

  factory HotCreateCategoryBean.fromRawJson(String str) =>
      HotCreateCategoryBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HotCreateCategoryBean.fromJson(Map<String, dynamic> json) =>
      HotCreateCategoryBean(
        id: json["id"],
        title: json["title"],
        iconUrl: json["icon_url"],
        sort: json["sort"],
        status: json["status"],
        deleteTime: json["delete_time"],
        desc: json["desc"],
        type: json["type"],
        createAt: json["create_at"],
        updateAt: json["update_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "icon_url": iconUrl,
        "sort": sort,
        "status": status,
        "delete_time": deleteTime,
        "desc": desc,
        "type": type,
        "create_at": createAt,
        "update_at": updateAt,
      };
}
