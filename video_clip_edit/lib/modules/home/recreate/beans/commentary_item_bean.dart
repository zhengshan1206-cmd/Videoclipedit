// To parse this JSON data, do
//
//     final commentaryItemBean = commentaryItemBeanFromJson(jsonString);

import 'dart:convert';

import 'package:video_clip_edit/modules/home/words/beans/audio_result_bean.dart';

CommentaryItemBean commentaryItemBeanFromJson(String str) =>
    CommentaryItemBean.fromJson(json.decode(str));

String commentaryItemBeanToJson(CommentaryItemBean data) =>
    json.encode(data.toJson());

class CommentaryItemBean {
  bool talkExpanded;
  List<AudioResultBean> talk;
  Commentary commentary;

  /// 字幕文件的url
  String srtUrl;
  double duration;
  String taskId;
  String audioUrl;
  String audioLocalPath;
  double commentaryDuration;

  /// 是否选择了剧情， 默认为true
  bool talkSelected;

  CommentaryItemBean({
    required this.talk,
    required this.commentary,
    required this.talkExpanded,
    required this.duration,
    required this.talkSelected,
    required this.taskId,
    required this.audioUrl,
    required this.audioLocalPath,
    required this.commentaryDuration,
    required this.srtUrl,
  });

  factory CommentaryItemBean.fromJson(Map<String, dynamic> json) =>
      CommentaryItemBean(
        talk: List<AudioResultBean>.from(
            json["talk"].map((x) => AudioResultBean.fromJson(x))),
        commentary: Commentary.fromJson(json["commentary"]),
        talkExpanded: json["talkExpanded"] ?? false,
        duration: json["duration"] ?? 0.0,
        talkSelected: json["talkSelected"] ?? true,
        taskId: json["taskId"] ?? "",
        audioUrl: json["audioUrl"] ?? "",
        audioLocalPath: json["audioLocalPath"] ?? "",
        commentaryDuration: json["commentaryDuration"] ?? 0.0,
        srtUrl: json["srtUrl"] ?? "",
      );

  CommentaryItemBean copyWith({
    bool? expanded,
    double? duration,
    bool? talkSelected,
    Commentary? commentary,
    List<AudioResultBean>? talk,
    String? taskId,
    String? audioUrl,
    String? audioLocalPath,
    double? commentaryDuration,
    String? srtUrl,
  }) =>
      CommentaryItemBean(
        talk: talk ?? this.talk,
        commentary: commentary ?? this.commentary,
        talkExpanded: expanded ?? talkExpanded,
        duration: duration ?? this.duration,
        talkSelected: talkSelected ?? this.talkSelected,
        taskId: taskId ?? this.taskId,
        audioUrl: audioUrl ?? this.audioUrl,
        audioLocalPath: audioLocalPath ?? this.audioLocalPath,
        commentaryDuration: commentaryDuration ?? this.commentaryDuration,
        srtUrl: srtUrl ?? this.srtUrl,
      );
  Map<String, dynamic> toJson() => {
        "talk": List<dynamic>.from(talk.map((x) => x.toJson())),
        "commentary": commentary.toJson(),
        "talkExpanded": talkExpanded,
        "duration": duration,
        "talkSelected": talkSelected,
        "taskId": taskId,
        "audioUrl": audioUrl,
        "audioLocalPath": audioLocalPath,
        "commentaryDuration": commentaryDuration,
        "srtUrl": srtUrl,
      };
}

class Commentary {
  String commentary;
  double startTime;
  bool expanded;

  Commentary({
    required this.commentary,
    required this.startTime,
    required this.expanded,
  });

  factory Commentary.fromJson(Map<String, dynamic> json) => Commentary(
        commentary: json["commentary"],
        startTime: json["start_time"]?.toDouble(),
        expanded: json["expanded"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "commentary": commentary,
        "start_time": startTime,
        "expanded": expanded,
      };
}
