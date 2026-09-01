import 'dart:convert';

class AiOralCloneBean {
  int id;
  int userId;
  dynamic taskId;
  String title;
  String coverUrl;
  dynamic refAudioUrl;
  String? audioUrl;
  dynamic refContent;
  String content;
  String duration;
  int status;
  int integral;
  int costIntegral;
  int deleteTime;
  DateTime createdAt;
  DateTime updatedAt;

  AiOralCloneBean({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.title,
    required this.coverUrl,
    required this.refAudioUrl,
    required this.audioUrl,
    required this.refContent,
    required this.content,
    required this.duration,
    required this.status,
    required this.integral,
    required this.costIntegral,
    required this.deleteTime,
    required this.createdAt,
    required this.updatedAt,
  });

  AiOralCloneBean copyWith({
    int? id,
    int? userId,
    dynamic taskId,
    String? title,
    String? coverUrl,
    dynamic refAudioUrl,
    String? audioUrl,
    dynamic refContent,
    String? content,
    String? duration,
    int? status,
    int? integral,
    int? costIntegral,
    int? deleteTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      AiOralCloneBean(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        taskId: taskId ?? this.taskId,
        title: title ?? this.title,
        coverUrl: coverUrl ?? this.coverUrl,
        refAudioUrl: refAudioUrl ?? this.refAudioUrl,
        audioUrl: audioUrl ?? this.audioUrl,
        refContent: refContent ?? this.refContent,
        content: content ?? this.content,
        duration: duration ?? this.duration,
        status: status ?? this.status,
        integral: integral ?? this.integral,
        costIntegral: costIntegral ?? this.costIntegral,
        deleteTime: deleteTime ?? this.deleteTime,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory AiOralCloneBean.fromRawJson(String str) =>
      AiOralCloneBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiOralCloneBean.fromJson(Map<String, dynamic> json) =>
      AiOralCloneBean(
        id: json["id"],
        userId: json["user_id"],
        taskId: json["task_id"],
        title: json["title"],
        coverUrl: json["cover_url"],
        refAudioUrl: json["ref_audio_url"],
        audioUrl: json["audio_url"],
        refContent: json["ref_content"],
        content: json["content"] ?? "",
        duration: json["duration"],
        status: json["status"],
        integral: json["integral"],
        costIntegral: json["cost_integral"],
        deleteTime: json["delete_time"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "task_id": taskId,
        "title": title,
        "cover_url": coverUrl,
        "ref_audio_url": refAudioUrl,
        "audio_url": audioUrl,
        "ref_content": refContent,
        "content": content,
        "duration": duration,
        "status": status,
        "integral": integral,
        "cost_integral": costIntegral,
        "delete_time": deleteTime,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
