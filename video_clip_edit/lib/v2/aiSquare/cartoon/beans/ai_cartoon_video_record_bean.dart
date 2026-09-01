import 'dart:convert';

class AiCartoonVideoRecordBean {
  int id;
  String videoTitle;
  int orderId;
  int status;
  String videoTemplate;
  int isAutoVideo;
  int createAt;
  int updateAt;
  String platform;
  String text;
  String videoUrl;
  String imgUrl;
  String scale;
  String workId;
  String jumpUrl;

  int materialPlatformId;///跳转平台
  int jumpForm;///跳转形式
  String promotionUrl;///跳转链接
  String promotionKey;///跳转关键词

  AiCartoonVideoRecordBean({
    required this.id,
    required this.videoTitle,
    required this.orderId,
    required this.status,
    required this.videoTemplate,
    required this.isAutoVideo,
    required this.createAt,
    required this.updateAt,
    required this.platform,
    required this.text,
    required this.videoUrl,
    required this.imgUrl,
    required this.scale,
    required this.workId,
    required this.jumpUrl,
    required this.materialPlatformId,
    required this.jumpForm,
    required this.promotionUrl,
    required this.promotionKey,
  });

  AiCartoonVideoRecordBean copyWith({
    int? id,
    String? videoTitle,
    int? orderId,
    int? status,
    String? videoTemplate,
    int? isAutoVideo,
    int? createAt,
    int? updateAt,
    String? platform,
    String? text,
    String? videoUrl,
    String? imgUrl,
    String? scale,
    String? workId,
    String? jumpUrl,
    int? materialPlatformId,
    int? jumpForm,
    String? promotionUrl,
    String? promotionKey,
  }) =>
      AiCartoonVideoRecordBean(
        id: id ?? this.id,
        videoTitle: videoTitle ?? this.videoTitle,
        orderId: orderId ?? this.orderId,
        status: status ?? this.status,
        videoTemplate: videoTemplate ?? this.videoTemplate,
        isAutoVideo: isAutoVideo ?? this.isAutoVideo,
        createAt: createAt ?? this.createAt,
        updateAt: updateAt ?? this.updateAt,
        platform: platform ?? this.platform,
        text: text ?? this.text,
        videoUrl: videoUrl ?? this.videoUrl,
        imgUrl: imgUrl ?? this.imgUrl,
        scale: scale ?? this.scale,
        workId: workId ?? this.workId,
        jumpUrl: jumpUrl ?? this.jumpUrl,
        materialPlatformId: materialPlatformId?? this.materialPlatformId,
        jumpForm: jumpForm?? this.jumpForm,
        promotionUrl: promotionUrl??this.promotionUrl,
           promotionKey: promotionKey??this.promotionKey
      );

  factory AiCartoonVideoRecordBean.fromRawJson(String str) =>
      AiCartoonVideoRecordBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiCartoonVideoRecordBean.fromJson(Map<String, dynamic> json) =>
      AiCartoonVideoRecordBean(
        id: json["id"],
        videoTitle: json["video_title"],
        orderId: json["order_id"],
        status: json["status"],
        videoTemplate: json["video_template"],
        isAutoVideo: json["is_auto_video"],
        createAt: json["create_at"],
        updateAt: json["update_at"],
        platform: json["platform"],
        text: json["text"],
        videoUrl: json["video_url"],
        imgUrl: json["img_url"],
        scale: json["scale"],
        workId: json["work_id"],
        jumpUrl: json["jump_url"] ?? "",
        materialPlatformId: json["material_platform_id"]??0,
        jumpForm: json["jump_form"]??0,
        promotionUrl: json["promotion_url"]??"",
           promotionKey:json["promotion_key"]??"",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "video_title": videoTitle,
        "order_id": orderId,
        "status": status,
        "video_template": videoTemplate,
        "is_auto_video": isAutoVideo,
        "create_at": createAt,
        "update_at": updateAt,
        "platform": platform,
        "text": text,
        "video_url": videoUrl,
        "img_url": imgUrl,
        "scale": scale,
        "work_id": workId,
        "jump_url": jumpUrl,
        "material_platform_id":materialPlatformId,
        "jump_form":jumpForm,
        "promotion_url":promotionUrl,
        "promotion_key":promotionKey,
      };
}
