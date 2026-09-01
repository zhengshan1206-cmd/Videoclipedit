import 'dart:convert';

class AiOpeningVideoItemBean {
  int pid;
  String materialName;
  int vipLimit;
  String desc;
  List<Detail> details;

  AiOpeningVideoItemBean({
    required this.pid,
    required this.materialName,
    required this.vipLimit,
    required this.desc,
    required this.details,
  });

  AiOpeningVideoItemBean copyWith({
    int? pid,
    String? materialName,
    int? vipLimit,
    String? desc,
    List<Detail>? details,
  }) =>
      AiOpeningVideoItemBean(
        pid: pid ?? this.pid,
        materialName: materialName ?? this.materialName,
        vipLimit: vipLimit ?? this.vipLimit,
        desc: desc ?? this.desc,
        details: details ?? this.details,
      );

  factory AiOpeningVideoItemBean.fromRawJson(String str) =>
      AiOpeningVideoItemBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiOpeningVideoItemBean.fromJson(Map<String, dynamic> json) =>
      AiOpeningVideoItemBean(
        pid: json["pid"],
        materialName: json["material_name"],
        vipLimit: json["vip_limit"],
        desc: json["desc"],
        details:
            List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "pid": pid,
        "material_name": materialName,
        "vip_limit": vipLimit,
        "desc": desc,
        "details": List<dynamic>.from(details.map((x) => x.toJson())),
      };
}

class Detail {
  String materialName;
  int vipLimit;
  int pid;
  String desc;
  int id;
  String videoTitle;
  String fullVideoTitle;
  String videoUrl;
  String coverUrl;
  double duration;
  String audioUrl;

  Detail({
    required this.materialName,
    required this.vipLimit,
    required this.pid,
    required this.desc,
    required this.id,
    required this.videoTitle,
    required this.fullVideoTitle,
    required this.videoUrl,
    required this.coverUrl,
    required this.duration,
    required this.audioUrl,
  });

  Detail copyWith({
    String? materialName,
    int? vipLimit,
    int? pid,
    String? desc,
    int? id,
    String? videoTitle,
    String? fullVideoTitle,
    String? videoUrl,
    String? coverUrl,
    double? duration,
    String? audioUrl,
  }) =>
      Detail(
        materialName: materialName ?? this.materialName,
        vipLimit: vipLimit ?? this.vipLimit,
        pid: pid ?? this.pid,
        desc: desc ?? this.desc,
        id: id ?? this.id,
        videoTitle: videoTitle ?? this.videoTitle,
        fullVideoTitle: fullVideoTitle ?? this.fullVideoTitle,
        videoUrl: videoUrl ?? this.videoUrl,
        coverUrl: coverUrl ?? this.coverUrl,
        duration: duration ?? this.duration,
        audioUrl: audioUrl ?? this.audioUrl,
      );

  factory Detail.fromRawJson(String str) => Detail.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        materialName: json["material_name"],
        vipLimit: json["vip_limit"],
        pid: json["pid"],
        desc: json["desc"],
        id: json["id"],
        videoTitle: json["video_title"],
        fullVideoTitle: json["full_video_title"],
        videoUrl: json["video_url"],
        coverUrl: json["cover_url"],
        duration: json["duration"]?.toDouble(),
        audioUrl: json["audio_url"],
      );

  Map<String, dynamic> toJson() => {
        "material_name": materialName,
        "vip_limit": vipLimit,
        "pid": pid,
        "desc": desc,
        "id": id,
        "video_title": videoTitle,
        "full_video_title": fullVideoTitle,
        "video_url": videoUrl,
        "cover_url": coverUrl,
        "duration": duration,
        "audio_url": audioUrl,
      };
}
