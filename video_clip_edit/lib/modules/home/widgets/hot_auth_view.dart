// To parse this JSON data, do
//
//     final hotAuthBean = hotAuthBeanFromJson(jsonString);

import 'dart:convert';

HotAuthBean hotAuthBeanFromJson(String str) =>
    HotAuthBean.fromJson(json.decode(str));

String hotAuthBeanToJson(HotAuthBean data) => json.encode(data.toJson());

class HotAuthBean {
  int id;
  int dramaId;
  String dramaName;
  String title;
  String coverUrl;
  String describe;
  String maxIncome;
  int joinPeopleNum;
  dynamic tagIds;
  // List<AdvertiserListElement> platformList;
  // List<AdvertiserListElement> advertiserList;
  int fansNum;
  int status;
  int episodeStatus;
  dynamic promotionType;
  dynamic relatTypes;
  DateTime? updatedAt;
  DateTime? createdAt;
  String url;
  List<Detail> detail;

  HotAuthBean({
    required this.id,
    required this.dramaId,
    required this.dramaName,
    required this.title,
    required this.coverUrl,
    required this.describe,
    required this.maxIncome,
    required this.joinPeopleNum,
    required this.tagIds,
    // required this.platformList,
    // required this.advertiserList,
    required this.fansNum,
    required this.status,
    required this.episodeStatus,
    required this.promotionType,
    required this.relatTypes,
    required this.updatedAt,
    required this.createdAt,
    required this.url,
    required this.detail,
  });

  factory HotAuthBean.fromJson(Map<String, dynamic> json) => HotAuthBean(
        id: json["id"],
        dramaId: json["drama_id"] ?? 0,
        dramaName: json["drama_name"],
        title: json["title"] ?? "",
        coverUrl: json["cover_url"],
        describe: json["describe"] ?? "",
        maxIncome:
            json["max_income"] == null ? "0" : json["max_income"].toString(),
        joinPeopleNum: json["join_people_num"],
        tagIds: json["tag_ids"],
        // platformList: List<AdvertiserListElement>.from(json["platform_list"]
        //     .map((x) => AdvertiserListElement.fromJson(x))),
        // advertiserList: List<AdvertiserListElement>.from(json["advertiser_list"]
        //     .map((x) => AdvertiserListElement.fromJson(x))),
        fansNum: json["fans_num"],
        status: json["status"],
        episodeStatus: json["episode_status"] ?? -1,
        promotionType: json["promotion_type"],
        relatTypes: json["relat_types"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        url: json["url"],
        detail:
            List<Detail>.from(json["detail"].map((x) => Detail.fromJson(x))),
      );

  @override
  String toString() {
    return 'HotAuthBean{id: $id, dramaId: $dramaId, dramaName: $dramaName, title: $title, coverUrl: $coverUrl, describe: $describe, maxIncome: $maxIncome, joinPeopleNum: $joinPeopleNum, tagIds: $tagIds, fansNum: $fansNum, status: $status, episodeStatus: $episodeStatus, promotionType: $promotionType, relatTypes: $relatTypes, updatedAt: $updatedAt, createdAt: $createdAt, url: $url, detail: $detail}';
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "drama_id": dramaId,
        "drama_name": dramaName,
        "title": title,
        "cover_url": coverUrl,
        "describe": describe,
        "max_income": maxIncome,
        "join_people_num": joinPeopleNum,
        "tag_ids": tagIds,
        // "platform_list":
        //     List<dynamic>.from(platformList.map((x) => x.toJson())),
        // "advertiser_list":
        //     List<dynamic>.from(advertiserList.map((x) => x.toJson())),
        "fans_num": fansNum,
        "status": status,
        "episode_status": episodeStatus,
        "promotion_type": promotionType,
        "relat_types": relatTypes,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "url": url,
        "detail": List<dynamic>.from(detail.map((x) => x.toJson())),
      };
}

class AdvertiserListElement {
  int id;
  String name;
  String icon;
  int status;

  AdvertiserListElement({
    required this.id,
    required this.name,
    required this.icon,
    required this.status,
  });

  factory AdvertiserListElement.fromJson(Map<String, dynamic> json) =>
      AdvertiserListElement(
        id: json["id"],
        name: json["name"],
        icon: json["icon"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon": icon,
        "status": status,
      };
}

class Detail {
  num id;
  num dramaId;
  String title;
  String coverUrl;
  String url;
  num duration;
  num sort;
  DateTime? updatedAt;
  DateTime? createdAt;

  Detail({
    required this.id,
    required this.dramaId,
    required this.title,
    required this.coverUrl,
    required this.url,
    required this.duration,
    required this.sort,
    required this.updatedAt,
    required this.createdAt,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        id: json["id"],
        dramaId: json["drama_id"] ?? 0,
        title: json["title"] ?? "",
        coverUrl: json["cover_url"],
        url: json["url"] ?? "",
        duration: json["duration"],
        sort: json["sort"],
        updatedAt: (json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"])),
        createdAt: (json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"])),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "drama_id": dramaId,
        "title": title,
        "cover_url": coverUrl,
        "url": url,
        "duration": duration,
        "sort": sort,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
      };
}
