// To parse this JSON data, do
//
//     final wordsTaskCellBean = wordsTaskCellBeanFromJson(jsonString);

import 'dart:convert';

WordsTaskCellBean wordsTaskCellBeanFromJson(String str) =>
    WordsTaskCellBean.fromJson(json.decode(str));

String wordsTaskCellBeanToJson(WordsTaskCellBean data) =>
    json.encode(data.toJson());

class WordsTaskCellBean {
  int id;
  int userId;
  String fileUrlMd5;
  String title;
  String platform;
  String fileUrl;
  String otherParam;
  String ocrType;
  int fileType;
  String content;
  String requestId;
  num duration;
  int status;
  dynamic errorMsg;
  int costIntegral;
  int integral;
  int deleteTime;
  DateTime updatedAt;
  DateTime createdAt;

  WordsTaskCellBean({
    required this.id,
    required this.userId,
    required this.fileUrlMd5,
    required this.title,
    required this.platform,
    required this.fileUrl,
    required this.otherParam,
    required this.ocrType,
    required this.fileType,
    required this.content,
    required this.requestId,
    required this.duration,
    required this.status,
    required this.errorMsg,
    required this.costIntegral,
    required this.integral,
    required this.deleteTime,
    required this.updatedAt,
    required this.createdAt,
  });

  factory WordsTaskCellBean.fromJson(Map<String, dynamic> json) =>
      WordsTaskCellBean(
        id: json["id"],
        userId: json["user_id"],
        fileUrlMd5: json["file_url_md5"],
        title: json["title"],
        platform: json["platform"],
        fileUrl: json["file_url"],
        otherParam: json["other_param"],
        ocrType: json["ocr_type"],
        fileType: json["file_type"],
        content: json["content"] ?? "",
        requestId: json["request_id"],
        duration: json["duration"],
        status: json["status"],
        errorMsg: json["error_msg"],
        costIntegral: json["cost_integral"],
        integral: json["integral"],
        deleteTime: json["delete_time"],
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "file_url_md5": fileUrlMd5,
        "title": title,
        "platform": platform,
        "file_url": fileUrl,
        "other_param": otherParam,
        "ocr_type": ocrType,
        "file_type": fileType,
        "content": content,
        "request_id": requestId,
        "duration": duration,
        "status": status,
        "error_msg": errorMsg,
        "cost_integral": costIntegral,
        "integral": integral,
        "delete_time": deleteTime,
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
      };
}
