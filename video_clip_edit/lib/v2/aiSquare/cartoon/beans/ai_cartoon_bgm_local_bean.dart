import 'dart:convert';

class AiCartoonBgmLocalBean {
  int id;
  String type;
  dynamic text;
  dynamic tag;
  String url;
  int urlDelete;
  dynamic remark;
  String date;
  int isDelete;
  String updatedAt;
  String createdAt;
  dynamic name;
  int userId;
  String cover;
  String duration;
  int status;
  int isRisk;
  AiCartoonBgmLocalBean({
    required this.id,
    required this.type,
    required this.text,
    required this.tag,
    required this.url,
    required this.urlDelete,
    required this.remark,
    required this.date,
    required this.isDelete,
    required this.updatedAt,
    required this.createdAt,
    required this.name,
    required this.userId,
    required this.cover,
    required this.duration,
    required this.status,
    required this.isRisk,
  });

  AiCartoonBgmLocalBean copyWith({
    int? id,
    String? type,
    dynamic text,
    dynamic tag,
    String? url,
    int? urlDelete,
    dynamic remark,
    String? date,
    int? isDelete,
    String? updatedAt,
    String? createdAt,
    dynamic name,
    int? userId,
    String? cover,
    String? duration,
    int? status,
    int? isRisk,
  }) =>
      AiCartoonBgmLocalBean(
        id: id ?? this.id,
        type: type ?? this.type,
        text: text ?? this.text,
        tag: tag ?? this.tag,
        url: url ?? this.url,
        urlDelete: urlDelete ?? this.urlDelete,
        remark: remark ?? this.remark,
        date: date ?? this.date,
        isDelete: isDelete ?? this.isDelete,
        updatedAt: updatedAt ?? this.updatedAt,
        createdAt: createdAt ?? this.createdAt,
        name: name ?? this.name,
        userId: userId ?? this.userId,
        cover: cover ?? this.cover,
        duration: duration ?? this.duration,
        status: status ?? this.status,
        isRisk: isRisk ?? this.isRisk,
      );

  factory AiCartoonBgmLocalBean.fromRawJson(String str) =>
      AiCartoonBgmLocalBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiCartoonBgmLocalBean.fromJson(Map<String, dynamic> json) =>
      AiCartoonBgmLocalBean(
        id: json["id"],
        type: json["type"],
        text: json["text"],
        tag: json["tag"],
        url: json["url"],
        urlDelete: json["url_delete"],
        remark: json["remark"],
        date: json["date"],
        isDelete: json["is_delete"],
        updatedAt: json["updated_at"],
        createdAt: json["created_at"],
        name: json["name"],
        userId: json["user_id"],
        cover: json["cover"] ?? "",
        duration: json["duration"],
        status: json["status"],
        isRisk: json["is_risk"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "text": text,
        "tag": tag,
        "url": url,
        "url_delete": urlDelete,
        "remark": remark,
        "date": date,
        "is_delete": isDelete,
        "updated_at": updatedAt,
        "created_at": createdAt,
        "name": name,
        "user_id": userId,
        "cover": cover,
        "duration": duration,
        "status": status,
        "is_risk": isRisk,
      };
}
