import 'dart:convert';

class AiOralVideotemBean {
  int id;
  String refVideoUrl;
  String refCoverUrl;
  String refAudioUrl;
  String videoUrl;
  String coverUrl;
  String platform;
  int userAudioTtsId;
  int status;
  int deleteTime;
  int integral;
  int costIntegral;
  DateTime createdAt;
  DateTime updatedAt;

  AiOralVideotemBean({
    required this.id,
    required this.refVideoUrl,
    required this.refCoverUrl,
    required this.refAudioUrl,
    required this.videoUrl,
    required this.coverUrl,
    required this.platform,
    required this.userAudioTtsId,
    required this.status,
    required this.deleteTime,
    required this.integral,
    required this.costIntegral,
    required this.createdAt,
    required this.updatedAt,
  });

  AiOralVideotemBean copyWith({
    int? id,
    DateTime? date,
    int? userId,
    String? refVideoUrl,
    String? refCoverUrl,
    String? refAudioUrl,
    String? videoUrl,
    String? coverUrl,
    String? platform,
    String? taskId,
    int? userAudioTtsId,
    int? status,
    int? deleteTime,
    int? integral,
    int? costIntegral,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      AiOralVideotemBean(
        id: id ?? this.id,
        refVideoUrl: refVideoUrl ?? this.refVideoUrl,
        refCoverUrl: refCoverUrl ?? this.refCoverUrl,
        refAudioUrl: refAudioUrl ?? this.refAudioUrl,
        videoUrl: videoUrl ?? this.videoUrl,
        coverUrl: coverUrl ?? this.coverUrl,
        platform: platform ?? this.platform,
        userAudioTtsId: userAudioTtsId ?? this.userAudioTtsId,
        status: status ?? this.status,
        deleteTime: deleteTime ?? this.deleteTime,
        integral: integral ?? this.integral,
        costIntegral: costIntegral ?? this.costIntegral,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory AiOralVideotemBean.fromRawJson(String str) =>
      AiOralVideotemBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiOralVideotemBean.fromJson(Map<String, dynamic> json) =>
      AiOralVideotemBean(
        id: json["id"],
        refVideoUrl: json["ref_video_url"] ?? "",
        refCoverUrl: json["ref_cover_url"] ?? "",
        refAudioUrl: json["ref_audio_url"] ?? "",
        videoUrl: json["video_url"] ?? "",
        coverUrl: json["cover_url"] ?? "",
        platform: json["platform"] ?? "",
        userAudioTtsId: json["user_audio_tts_id"] ?? 0,
        status: json["status"],
        deleteTime: json["delete_time"] ?? 0,
        integral: json["integral"] ?? 0,
        costIntegral: json["cost_integral"] ?? 0,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );
  

  ///AI漫剧
  factory AiOralVideotemBean.animeFromJson(Map<String, dynamic> json) =>
      AiOralVideotemBean(
        id: json["id"],
        refVideoUrl: "",
        refCoverUrl: "",
        refAudioUrl: "",
        videoUrl: json["video_url"] ?? "",
        coverUrl: json["cover_url"] ?? "",
        platform: "",
        userAudioTtsId: 0,
        status: json["status"],
        deleteTime: 0,
        integral: 0,
        costIntegral: 0,
        createdAt: DateTime.parse(json["create_at"]),
        updatedAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "ref_video_url": refVideoUrl,
        "ref_cover_url": refCoverUrl,
        "ref_audio_url": refAudioUrl,
        "video_url": videoUrl,
        "cover_url": coverUrl,
        "platform": platform,
        "user_audio_tts_id": userAudioTtsId,
        "status": status,
        "delete_time": deleteTime,
        "integral": integral,
        "cost_integral": costIntegral,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
