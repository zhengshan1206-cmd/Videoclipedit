import 'dart:convert';

class HotCreateNovelDetailsBean {
  int id;
  int novelId;
  String title;
  String content;
  String coverUrl;
  String url;
  int status;
  int sort;
  String updatedAt;
  String createdAt;

  HotCreateNovelDetailsBean({
    required this.id,
    required this.novelId,
    required this.title,
    required this.content,
    required this.coverUrl,
    required this.url,
    required this.status,
    required this.sort,
    required this.updatedAt,
    required this.createdAt,
  });

  HotCreateNovelDetailsBean copyWith({
    int? id,
    int? novelId,
    String? title,
    String? content,
    String? coverUrl,
    dynamic url,
    int? status,
    int? sort,
    String? updatedAt,
    String? createdAt,
  }) =>
      HotCreateNovelDetailsBean(
        id: id ?? this.id,
        novelId: novelId ?? this.novelId,
        title: title ?? this.title,
        content: content ?? this.content,
        coverUrl: coverUrl ?? this.coverUrl,
        url: url ?? this.url,
        status: status ?? this.status,
        sort: sort ?? this.sort,
        updatedAt: updatedAt ?? this.updatedAt,
        createdAt: createdAt ?? this.createdAt,
      );

  factory HotCreateNovelDetailsBean.fromRawJson(String str) =>
      HotCreateNovelDetailsBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HotCreateNovelDetailsBean.fromJson(Map<String, dynamic> json) =>
      HotCreateNovelDetailsBean(
        id: json["id"],
        novelId: json["novel_id"],
        title: json["title"] ?? "",
        content: json["content"] ?? "",
        coverUrl: json["cover_url"] ?? "",
        url: json["url"] ?? "",
        status: json["status"],
        sort: json["sort"],
        updatedAt: json["updated_at"] ?? "",
        createdAt: json["created_at"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "novel_id": novelId,
        "title": title,
        "content": content,
        "cover_url": coverUrl,
        "url": url,
        "status": status,
        "sort": sort,
        "updated_at": updatedAt,
        "created_at": createdAt,
      };
}
