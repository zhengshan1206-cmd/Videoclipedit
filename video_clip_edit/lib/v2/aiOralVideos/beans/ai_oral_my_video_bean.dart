import 'dart:convert';

class AiOralMyVideoBean {
  int id;
  String type;
  dynamic text;
  String url;
  int urlDelete;
  String? remark;
  DateTime date;
  int isDelete;
  DateTime updatedAt;
  DateTime createdAt;
  String name;
  int userId;
  String cover;
  String duration;
  int status;
  int isRisk;

  AiOralMyVideoBean({
    required this.id,
    required this.type,
    required this.text,
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

  AiOralMyVideoBean copyWith({
    int? id,
    String? type,
    dynamic text,
    String? url,
    int? urlDelete,
    String? remark,
    DateTime? date,
    int? isDelete,
    DateTime? updatedAt,
    DateTime? createdAt,
    String? name,
    int? userId,
    String? cover,
    String? duration,
    int? status,
    int? isRisk,
  }) =>
      AiOralMyVideoBean(
        id: id ?? this.id,
        type: type ?? this.type,
        text: text ?? this.text,
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

  factory AiOralMyVideoBean.fromRawJson(String str) =>
      AiOralMyVideoBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiOralMyVideoBean.fromJson(Map<String, dynamic> json) =>
      AiOralMyVideoBean(
        id: json["id"],
        type: json["type"],
        text: json["text"],
        url: json["url"],
        urlDelete: json["url_delete"],
        remark: json["remark"],
        date: DateTime.parse(json["date"]),
        isDelete: json["is_delete"],
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
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
        "url": url,
        "url_delete": urlDelete,
        "remark": remark,
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "is_delete": isDelete,
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "name": name,
        "user_id": userId,
        "cover": cover,
        "duration": duration,
        "status": status,
        "is_risk": isRisk,
      };
}
