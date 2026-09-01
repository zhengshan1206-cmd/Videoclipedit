import 'dart:convert';

class AiTweetsVideoDetalsInfoBean {
  int id;
  String coverUrl;
  String videoUrl;
  dynamic prompt;
  String title;
  String sys;
  int type;
  String jumpUrl;
  int showFor;
  String packageId;
  String versionId;
  String versionIdRight;
  String spreadId;
  int status;
  int orderNum;
  DateTime updatedAt;
  DateTime createdAt;
  String appFramework;
  String withdrawMoney;
  int useTime;
  int activeUserId;
  String labels;
  String shareUrl;
  String shareCoverUrl;

  AiTweetsVideoDetalsInfoBean({
    required this.id,
    required this.coverUrl,
    required this.videoUrl,
    required this.prompt,
    required this.title,
    required this.sys,
    required this.type,
    required this.jumpUrl,
    required this.showFor,
    required this.packageId,
    required this.versionId,
    required this.versionIdRight,
    required this.spreadId,
    required this.status,
    required this.orderNum,
    required this.updatedAt,
    required this.createdAt,
    required this.appFramework,
    required this.withdrawMoney,
    required this.useTime,
    required this.activeUserId,
    required this.labels,
    required this.shareUrl,
    required this.shareCoverUrl,
  });

  AiTweetsVideoDetalsInfoBean copyWith({
    int? id,
    String? coverUrl,
    String? videoUrl,
    dynamic prompt,
    String? title,
    String? sys,
    int? type,
    String? jumpUrl,
    int? showFor,
    String? packageId,
    String? versionId,
    String? versionIdRight,
    String? spreadId,
    int? status,
    int? orderNum,
    DateTime? updatedAt,
    DateTime? createdAt,
    String? appFramework,
    String? withdrawMoney,
    int? useTime,
    int? activeUserId,
    String? labels,
    String? shareUrl,
    String? shareCoverUrl,
  }) =>
      AiTweetsVideoDetalsInfoBean(
        id: id ?? this.id,
        coverUrl: coverUrl ?? this.coverUrl,
        videoUrl: videoUrl ?? this.videoUrl,
        prompt: prompt ?? this.prompt,
        title: title ?? this.title,
        sys: sys ?? this.sys,
        type: type ?? this.type,
        jumpUrl: jumpUrl ?? this.jumpUrl,
        showFor: showFor ?? this.showFor,
        packageId: packageId ?? this.packageId,
        versionId: versionId ?? this.versionId,
        versionIdRight: versionIdRight ?? this.versionIdRight,
        spreadId: spreadId ?? this.spreadId,
        status: status ?? this.status,
        orderNum: orderNum ?? this.orderNum,
        updatedAt: updatedAt ?? this.updatedAt,
        createdAt: createdAt ?? this.createdAt,
        appFramework: appFramework ?? this.appFramework,
        withdrawMoney: withdrawMoney ?? this.withdrawMoney,
        useTime: useTime ?? this.useTime,
        activeUserId: activeUserId ?? this.activeUserId,
        labels: labels ?? this.labels,
        shareUrl: shareUrl ?? this.shareUrl,
        shareCoverUrl: shareCoverUrl ?? this.shareCoverUrl,
      );

  factory AiTweetsVideoDetalsInfoBean.fromRawJson(String str) =>
      AiTweetsVideoDetalsInfoBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiTweetsVideoDetalsInfoBean.fromJson(Map<String, dynamic> json) =>
      AiTweetsVideoDetalsInfoBean(
        id: json["id"],
        coverUrl: json["cover_url"],
        videoUrl: json["video_url"],
        prompt: json["prompt"],
        title: json["title"],
        sys: json["sys"],
        type: json["type"],
        jumpUrl: json["jump_url"],
        showFor: json["show_for"],
        packageId: json["package_id"],
        versionId: json["version_id"],
        versionIdRight: json["version_id_right"],
        spreadId: json["spread_id"],
        status: json["status"],
        orderNum: json["order_num"],
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
        appFramework: json["app_framework"],
        withdrawMoney: json["withdraw_money"],
        useTime: json["use_time"],
        activeUserId: json["active_user_id"],
        labels: json["labels"],
        shareUrl: json["share_url"],
        shareCoverUrl: json["share_cover_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cover_url": coverUrl,
        "video_url": videoUrl,
        "prompt": prompt,
        "title": title,
        "sys": sys,
        "type": type,
        "jump_url": jumpUrl,
        "show_for": showFor,
        "package_id": packageId,
        "version_id": versionId,
        "version_id_right": versionIdRight,
        "spread_id": spreadId,
        "status": status,
        "order_num": orderNum,
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "app_framework": appFramework,
        "withdraw_money": withdrawMoney,
        "use_time": useTime,
        "active_user_id": activeUserId,
        "labels": labels,
        "share_url": shareUrl,
        "share_cover_url": shareCoverUrl,
      };
}
