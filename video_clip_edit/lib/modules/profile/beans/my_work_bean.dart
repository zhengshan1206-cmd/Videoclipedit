// To parse this JSON data, do
//
//     final myWorkBean = myWorkBeanFromJson(jsonString);

import 'dart:convert';

MyWorkBean myWorkBeanFromJson(String str) =>
    MyWorkBean.fromJson(json.decode(str));

String myWorkBeanToJson(MyWorkBean data) => json.encode(data.toJson());

class MyWorkBean {
  int id;
  int userId;
  DateTime date;
  String title;
  int type;
  String fileUrl;
  String fileCoverUrl;
  bool selected;

  /// 0待处理 1处理中 2成功 3失败
  int status;
  String videoScale;
  String? fontName;
  String videoModel;
  dynamic videoSpecialEffects;
  String? bgmUrl;
  int needVideoAudio;
  DateTime updatedAt;
  DateTime createdAt;
  List<Detail>? details;

  MyWorkBean({
    required this.id,
    required this.userId,
    required this.date,
    required this.title,
    required this.type,
    required this.fileUrl,
    required this.fileCoverUrl,
    required this.status,
    required this.videoScale,
    required this.fontName,
    required this.videoModel,
    required this.videoSpecialEffects,
    required this.bgmUrl,
    required this.needVideoAudio,
    required this.updatedAt,
    required this.createdAt,
    required this.details,
    required this.selected,
  });

  factory MyWorkBean.fromJson(Map<String, dynamic> json) => MyWorkBean(
        id: json["id"],
        userId: json["user_id"],
        date: DateTime.parse(json["date"]),
        title: json["title"],
        type: json["type"],
        fileUrl: json["file_url"],
        fileCoverUrl: json["file_cover_url"],
        status: json["status"],
        videoScale: json["video_scale"],
        fontName: json["font_name"],
        videoModel: json["video_model"],
        videoSpecialEffects: json["video_special_effects"],
        bgmUrl: json["bgm_url"],
        needVideoAudio: json["need_video_audio"],
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
        selected: json["selected"] ?? false,
        details: List<Detail>.from(
            (json["details"] ?? []).map((x) => Detail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "title": title,
        "type": type,
        "file_url": fileUrl,
        "file_cover_url": fileCoverUrl,
        "status": status,
        "video_scale": videoScale,
        "font_name": fontName,
        "video_model": videoModel,
        "video_special_effects": videoSpecialEffects,
        "bgm_url": bgmUrl,
        "selected": selected,
        "need_video_audio": needVideoAudio,
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "details": List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class Detail {
  int id;
  int userId;
  int userWorkLogId;
  String fileUrl;
  String fileUrlMd5;
  int fileType;
  String fileCoverUrl;
  String? videoAudioUrl;
  String? text;
  int speakerId;
  int? volume;
  String? speechUrl;
  // OtherConfig? otherConfig;
  int status;
  int deleteTime;
  DateTime updatedAt;
  DateTime createdAt;

  Detail({
    required this.id,
    required this.userId,
    required this.userWorkLogId,
    required this.fileUrl,
    required this.fileUrlMd5,
    required this.fileType,
    required this.fileCoverUrl,
    required this.videoAudioUrl,
    required this.text,
    required this.speakerId,
    required this.volume,
    required this.speechUrl,
    // required this.otherConfig,
    required this.status,
    required this.deleteTime,
    required this.updatedAt,
    required this.createdAt,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        id: json["id"],
        userId: json["user_id"],
        userWorkLogId: json["user_work_log_id"],
        fileUrl: json["file_url"],
        fileUrlMd5: json["file_url_md5"],
        fileType: json["file_type"],
        fileCoverUrl: json["file_cover_url"],
        videoAudioUrl: json["video_audio_url"],
        text: json["text"],
        speakerId: json["speaker_id"],
        volume: json["volume"],
        speechUrl: json["speech_url"],
        // otherConfig: OtherConfig.fromJson(json["other_config"]),
        status: json["status"],
        deleteTime: json["delete_time"],
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "user_work_log_id": userWorkLogId,
        "file_url": fileUrl,
        "file_url_md5": fileUrlMd5,
        "file_type": fileType,
        "file_cover_url": fileCoverUrl,
        "video_audio_url": videoAudioUrl,
        "text": text,
        "speaker_id": speakerId,
        "volume": volume,
        "speech_url": speechUrl,
        // "other_config": otherConfig?.toJson(),
        "status": status,
        "delete_time": deleteTime,
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
      };
}

class OtherConfig {
  OtherConfig();

  factory OtherConfig.fromJson(Map<String, dynamic> json) => OtherConfig();

  Map<String, dynamic> toJson() => {};
}
