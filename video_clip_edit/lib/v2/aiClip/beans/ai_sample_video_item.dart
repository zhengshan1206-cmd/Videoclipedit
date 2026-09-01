import 'dart:convert';

class AiSampleVideoItemBean {
  String materialName;
  int id;
  int materialPackId;
  String videoTitle;
  String fullVideoTitle;
  String videoUrl;
  String coverUrl;
  double duration;
  int scale;
  int filesize;
  int sort;
  int status;
  int deleteTime;
  int isDemo;
  DateTime createAt;
  DateTime updateAt;
  String audioUrl;
  int extractAudioId;
  dynamic content;

  AiSampleVideoItemBean({
    required this.materialName,
    required this.id,
    required this.materialPackId,
    required this.videoTitle,
    required this.fullVideoTitle,
    required this.videoUrl,
    required this.coverUrl,
    required this.duration,
    required this.scale,
    required this.filesize,
    required this.sort,
    required this.status,
    required this.deleteTime,
    required this.isDemo,
    required this.createAt,
    required this.updateAt,
    required this.audioUrl,
    required this.extractAudioId,
    required this.content,
  });

  AiSampleVideoItemBean copyWith({
    String? materialName,
    int? id,
    int? materialPackId,
    String? videoTitle,
    String? fullVideoTitle,
    String? videoUrl,
    String? coverUrl,
    double? duration,
    int? scale,
    int? filesize,
    int? sort,
    int? status,
    int? deleteTime,
    int? isDemo,
    DateTime? createAt,
    DateTime? updateAt,
    String? audioUrl,
    int? extractAudioId,
    dynamic content,
  }) =>
      AiSampleVideoItemBean(
        materialName: materialName ?? this.materialName,
        id: id ?? this.id,
        materialPackId: materialPackId ?? this.materialPackId,
        videoTitle: videoTitle ?? this.videoTitle,
        fullVideoTitle: fullVideoTitle ?? this.fullVideoTitle,
        videoUrl: videoUrl ?? this.videoUrl,
        coverUrl: coverUrl ?? this.coverUrl,
        duration: duration ?? this.duration,
        scale: scale ?? this.scale,
        filesize: filesize ?? this.filesize,
        sort: sort ?? this.sort,
        status: status ?? this.status,
        deleteTime: deleteTime ?? this.deleteTime,
        isDemo: isDemo ?? this.isDemo,
        createAt: createAt ?? this.createAt,
        updateAt: updateAt ?? this.updateAt,
        audioUrl: audioUrl ?? this.audioUrl,
        extractAudioId: extractAudioId ?? this.extractAudioId,
        content: content ?? this.content,
      );

  factory AiSampleVideoItemBean.fromRawJson(String str) =>
      AiSampleVideoItemBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiSampleVideoItemBean.fromJson(Map<String, dynamic> json) =>
      AiSampleVideoItemBean(
        materialName: json["material_name"],
        id: json["id"],
        materialPackId: json["material_pack_id"],
        videoTitle: json["video_title"],
        fullVideoTitle: json["full_video_title"],
        videoUrl: json["video_url"],
        coverUrl: json["cover_url"],
        duration: json["duration"]?.toDouble(),
        scale: json["scale"],
        filesize: json["filesize"],
        sort: json["sort"],
        status: json["status"],
        deleteTime: json["delete_time"],
        isDemo: json["is_demo"],
        createAt: DateTime.parse(json["create_at"]),
        updateAt: DateTime.parse(json["update_at"]),
        audioUrl: json["audio_url"],
        extractAudioId: json["extract_audio_id"],
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "material_name": materialName,
        "id": id,
        "material_pack_id": materialPackId,
        "video_title": videoTitle,
        "full_video_title": fullVideoTitle,
        "video_url": videoUrl,
        "cover_url": coverUrl,
        "duration": duration,
        "scale": scale,
        "filesize": filesize,
        "sort": sort,
        "status": status,
        "delete_time": deleteTime,
        "is_demo": isDemo,
        "create_at": createAt.toIso8601String(),
        "update_at": updateAt.toIso8601String(),
        "audio_url": audioUrl,
        "extract_audio_id": extractAudioId,
        "content": content,
      };
}
