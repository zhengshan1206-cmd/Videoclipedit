import 'dart:convert';

class HotCreateNovelBean {
  int id;
  String manageCategoryId;
  String title;
  String authorName;
  String coverUrl;
  String desc;
  String maxIncome;
  int joinPeopleNum;
  dynamic tagIds;
  int fansNum;
  int sort;
  int status;
  String updatedAt;
  String createdAt;
  String? detailsText;

  HotCreateNovelBean({
    required this.id,
    required this.manageCategoryId,
    required this.title,
    required this.authorName,
    required this.coverUrl,
    required this.desc,
    required this.maxIncome,
    required this.joinPeopleNum,
    required this.tagIds,
    required this.fansNum,
    required this.sort,
    required this.status,
    required this.updatedAt,
    required this.createdAt,
    required this.detailsText,
  });

  HotCreateNovelBean copyWith({
    int? id,
    String? manageCategoryId,
    String? title,
    String? authorName,
    String? coverUrl,
    String? desc,
    String? maxIncome,
    int? joinPeopleNum,
    dynamic tagIds,
    int? fansNum,
    int? sort,
    int? status,
    String? updatedAt,
    String? createdAt,
    String? detailsText
  }) =>
      HotCreateNovelBean(
        id: id ?? this.id,
        manageCategoryId: manageCategoryId ?? this.manageCategoryId,
        title: title ?? this.title,
        authorName: authorName ?? this.authorName,
        coverUrl: coverUrl ?? this.coverUrl,
        desc: desc ?? this.desc,
        maxIncome: maxIncome ?? this.maxIncome,
        joinPeopleNum: joinPeopleNum ?? this.joinPeopleNum,
        tagIds: tagIds ?? this.tagIds,
        fansNum: fansNum ?? this.fansNum,
        sort: sort ?? this.sort,
        status: status ?? this.status,
        updatedAt: updatedAt ?? this.updatedAt,
        createdAt: createdAt ?? this.createdAt,
        detailsText: detailsText??this.detailsText,
      );

  factory HotCreateNovelBean.fromRawJson(String str) =>
      HotCreateNovelBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HotCreateNovelBean.fromJson(Map<String, dynamic> json) =>
      HotCreateNovelBean(
        id: json["id"],
        manageCategoryId: json["manage_category_id"],
        title: json["title"],
        authorName: json["author_name"],
        coverUrl: json["cover_url"],
        desc: json["desc"],
        maxIncome: json["max_income"],
        joinPeopleNum: json["join_people_num"],
        tagIds: json["tag_ids"],
        fansNum: json["fans_num"],
        sort: json["sort"],
        status: json["status"],
        updatedAt: json["updated_at"],
        createdAt: json["created_at"],
        detailsText: json["details_text"]??""
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "manage_category_id": manageCategoryId,
        "title": title,
        "author_name": authorName,
        "cover_url": coverUrl,
        "desc": desc,
        "max_income": maxIncome,
        "join_people_num": joinPeopleNum,
        "tag_ids": tagIds,
        "fans_num": fansNum,
        "sort": sort,
        "status": status,
        "updated_at": updatedAt,
        "created_at": createdAt,
        "details_text":detailsText,
      };
}
