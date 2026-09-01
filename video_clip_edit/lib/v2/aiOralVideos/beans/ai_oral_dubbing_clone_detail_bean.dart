import 'dart:convert';

class AiOralDubbingCloneDetailBean {
  int id;
  String date;
  int userId;
  int ttsType;
  int ttsParamId;
  int userAudioCloneId;
  String platform;
  String taskId;
  String refAudioUrl;
  String refContent;
  String content;
  int costIntegral;
  int integral;
  String title;
  dynamic audioUrl;
  int deleteTime;
  int type;
  int status;
  String createAt;
  String updateAt;

  AiOralDubbingCloneDetailBean({
    required this.id,
    required this.date,
    required this.userId,
    required this.ttsType,
    required this.ttsParamId,
    required this.userAudioCloneId,
    required this.platform,
    required this.taskId,
    required this.refAudioUrl,
    required this.refContent,
    required this.content,
    required this.costIntegral,
    required this.integral,
    required this.audioUrl,
    required this.deleteTime,
    required this.type,
    required this.status,
    required this.createAt,
    required this.updateAt,
    required this.title,
  });

  AiOralDubbingCloneDetailBean copyWith({
    int? id,
    String? date,
    int? userId,
    int? ttsType,
    int? ttsParamId,
    int? userAudioCloneId,
    String? platform,
    String? taskId,
    String? refAudioUrl,
    String? refContent,
    String? content,
    int? costIntegral,
    int? integral,
    dynamic audioUrl,
    int? deleteTime,
    int? type,
    int? status,
    String? createAt,
    String? updateAt,
    String? title,
  }) =>
      AiOralDubbingCloneDetailBean(
        id: id ?? this.id,
        date: date ?? this.date,
        userId: userId ?? this.userId,
        ttsType: ttsType ?? this.ttsType,
        ttsParamId: ttsParamId ?? this.ttsParamId,
        userAudioCloneId: userAudioCloneId ?? this.userAudioCloneId,
        platform: platform ?? this.platform,
        taskId: taskId ?? this.taskId,
        refAudioUrl: refAudioUrl ?? this.refAudioUrl,
        refContent: refContent ?? this.refContent,
        content: content ?? this.content,
        costIntegral: costIntegral ?? this.costIntegral,
        integral: integral ?? this.integral,
        audioUrl: audioUrl ?? this.audioUrl,
        deleteTime: deleteTime ?? this.deleteTime,
        type: type ?? this.type,
        status: status ?? this.status,
        createAt: createAt ?? this.createAt,
        updateAt: updateAt ?? this.updateAt,
        title: title ?? this.title,
      );

  factory AiOralDubbingCloneDetailBean.fromRawJson(String str) =>
      AiOralDubbingCloneDetailBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiOralDubbingCloneDetailBean.fromJson(Map<String, dynamic> json) =>
      AiOralDubbingCloneDetailBean(
        id: json["id"],
        title: json["title"] ?? "我的音乐",
        date: json["date"] ?? "",
        userId: json["user_id"],
        ttsType: json["tts_type"],
        ttsParamId: json["tts_param_id"],
        userAudioCloneId: json["user_audio_clone_id"],
        platform: json["platform"],
        taskId: json["task_id"] ?? "",
        refAudioUrl: json["ref_audio_url"],
        refContent: json["ref_content"],
        content: json["content"],
        costIntegral: json["cost_integral"],
        integral: json["integral"],
        audioUrl: json["audio_url"],
        deleteTime: json["delete_time"],
        type: json["type"],
        status: json["status"],
        createAt: json["create_at"] ?? "",
        updateAt: json["update_at"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "user_id": userId,
        "tts_type": ttsType,
        "tts_param_id": ttsParamId,
        "user_audio_clone_id": userAudioCloneId,
        "platform": platform,
        "task_id": taskId,
        "ref_audio_url": refAudioUrl,
        "ref_content": refContent,
        "content": content,
        "cost_integral": costIntegral,
        "integral": integral,
        "audio_url": audioUrl,
        "delete_time": deleteTime,
        "type": type,
        "status": status,
        "create_at": createAt,
        "update_at": updateAt,
        "title": title,
      };
}
