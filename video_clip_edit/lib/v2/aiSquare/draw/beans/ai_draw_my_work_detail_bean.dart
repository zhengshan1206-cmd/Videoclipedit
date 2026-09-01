import 'dart:convert';

class AiMyWorkDetailItemBean {
  int id;
  int status;
  String prompt;
  String picUrl;
  String ratio;
  int modelId;
  String model;
  String activeUserName;
  String activeUserAvatar;
  int activeUserCreateDays;
  String createdAt;

  AiMyWorkDetailItemBean({
    required this.id,
    required this.status,
    required this.prompt,
    required this.picUrl,
    required this.ratio,
    required this.modelId,
    required this.model,
    required this.activeUserName,
    required this.activeUserAvatar,
    required this.activeUserCreateDays,
    required this.createdAt,
  });

  AiMyWorkDetailItemBean copyWith({
    int? id,
    int? status,
    String? prompt,
    String? picUrl,
    String? ratio,
    int? modelId,
    String? model,
    String? activeUserName,
    String? activeUserAvatar,
    int? activeUserCreateDays,
    String? createdAt,
  }) =>
      AiMyWorkDetailItemBean(
        id: id ?? this.id,
        status: status ?? this.status,
        prompt: prompt ?? this.prompt,
        picUrl: picUrl ?? this.picUrl,
        ratio: ratio ?? this.ratio,
        modelId: modelId ?? this.modelId,
        model: model ?? this.model,
        activeUserName: activeUserName ?? this.activeUserName,
        activeUserAvatar: activeUserAvatar ?? this.activeUserAvatar,
        activeUserCreateDays: activeUserCreateDays ?? this.activeUserCreateDays,
        createdAt: createdAt ?? this.createdAt,
      );

  factory AiMyWorkDetailItemBean.fromRawJson(String str) =>
      AiMyWorkDetailItemBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiMyWorkDetailItemBean.fromJson(Map<String, dynamic> json) =>
      AiMyWorkDetailItemBean(
        id: json["id"],
        status: json["status"],
        prompt: json["prompt"],
        picUrl: json["pic_url"],
        ratio: json["ratio"],
        modelId: json["model_id"],
        model: json["model"],
        activeUserName: json["active_user_name"],
        activeUserAvatar: json["active_user_avatar"],
        activeUserCreateDays: json["active_user_create_days"],
        createdAt: json["created_at"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "prompt": prompt,
        "pic_url": picUrl,
        "ratio": ratio,
        "model_id": modelId,
        "model": model,
        "active_user_name": activeUserName,
        "active_user_avatar": activeUserAvatar,
        "active_user_create_days": activeUserCreateDays,
        "created_at": createdAt,
      };
}
