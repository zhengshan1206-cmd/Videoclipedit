// To parse this JSON data, do
//
//     final aiSongTasksBean = aiSongTasksBeanFromJson(jsonString);

import 'dart:convert';

 List<AiSongTasksBean> aiSongTasksBeanFromJson(String str) => List<AiSongTasksBean>.from(json.decode(str).map((x) => AiSongTasksBean.fromJson(x)));

String aiSongTasksBeanToJson(List<AiSongTasksBean> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AiSongTasksBean {
  int id;
  String? taskId;
  int userId;
  DateTime date;
  int customMode;
  int isInstrumental;
  String prompt;
  String style;
  String title;
  int singerSex;
  int status;
  int extendStatus;
  String platform;
  int deleteTime;
  String createAt;
  DateTime updateAt;

  AiSongTasksBean({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.date,
    required this.customMode,
    required this.isInstrumental,
    required this.prompt,
    required this.style,
    required this.title,
    required this.singerSex,
    required this.status,
    required this.extendStatus,
    required this.platform,
    required this.deleteTime,
    required this.createAt,
    required this.updateAt,
  });

  factory AiSongTasksBean.fromJson(Map<String, dynamic> json) => AiSongTasksBean(
    id: json["id"],
    taskId: json["task_id"],
    userId: json["user_id"],
    date: DateTime.parse(json["date"]),
    customMode: json["custom_mode"],
    isInstrumental: json["is_instrumental"],
    prompt: json["prompt"],
    style: json["style"],
    title: json["title"],
    singerSex: json["singer_sex"],
    status: json["status"],
    extendStatus: json["extend_status"],
    platform: json["platform"],
    deleteTime: json["delete_time"],
    createAt: json["create_at"],
    updateAt: DateTime.parse(json["update_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "task_id": taskId,
    "user_id": userId,
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "custom_mode": customMode,
    "is_instrumental": isInstrumental,
    "prompt": prompt,
    "style": style,
    "title": title,
    "singer_sex": singerSex,
    "status": status,
    "extend_status": extendStatus,
    "platform": platform,
    "delete_time": deleteTime,
    "create_at": createAt,
    "update_at": updateAt.toIso8601String(),
  };
}
