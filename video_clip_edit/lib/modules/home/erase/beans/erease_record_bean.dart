// To parse this JSON data, do
//
//     final ereaseRecordBean = ereaseRecordBeanFromJson(jsonString);

import 'dart:convert';

EreaseRecordBean ereaseRecordBeanFromJson(String str) =>
    EreaseRecordBean.fromJson(json.decode(str));

String ereaseRecordBeanToJson(EreaseRecordBean data) =>
    json.encode(data.toJson());

class EreaseRecordBean {
  int id;
  DateTime date;
  int userId;
  int eraseType;
  int costIntegral;
  String fileUrlMd5;
  String fileUrl;
  String maskImgUrl;
  dynamic errorMsg;
  String eraseArea;
  int fileType;
  String url;
  String platform;

  /// 0待处理 1处理中 2成功 3失败
  int status;
  DateTime updatedAt;
  DateTime createdAt;

  EreaseRecordBean({
    required this.id,
    required this.date,
    required this.userId,
    required this.eraseType,
    required this.costIntegral,
    required this.fileUrlMd5,
    required this.fileUrl,
    required this.maskImgUrl,
    required this.errorMsg,
    required this.eraseArea,
    required this.fileType,
    required this.url,
    required this.platform,
    required this.status,
    required this.updatedAt,
    required this.createdAt,
  });

  factory EreaseRecordBean.fromJson(Map<String, dynamic> json) =>
      EreaseRecordBean(
        id: json["id"],
        date: DateTime.parse(json["date"]),
        userId: json["user_id"],
        eraseType: json["erase_type"],
        costIntegral: json["cost_integral"],
        fileUrlMd5: json["file_url_md5"],
        fileUrl: json["file_url"] ?? "",
        maskImgUrl: json["mask_img_url"] ?? "",
        errorMsg: json["error_msg"],
        eraseArea: json["erase_area"],
        fileType: json["file_type"],
        url: json["url"] ?? "",
        platform: json["platform"],
        status: json["status"],
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "user_id": userId,
        "erase_type": eraseType,
        "cost_integral": costIntegral,
        "file_url_md5": fileUrlMd5,
        "file_url": fileUrl,
        "mask_img_url": maskImgUrl,
        "error_msg": errorMsg,
        "erase_area": eraseArea,
        "file_type": fileType,
        "url": url,
        "platform": platform,
        "status": status,
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
      };
}
