// To parse this JSON data, do
//
//     final audioResultBean = audioResultBeanFromJson(jsonString);

import 'dart:convert';

AudioResultBean audioResultBeanFromJson(String str) =>
    AudioResultBean.fromJson(json.decode(str));

String audioResultBeanToJson(AudioResultBean data) =>
    json.encode(data.toJson());

class AudioResultBean {
  String speaker;
  double startTime;
  double endTime;
  String text;
  bool selected;
  bool nameModified;
  AudioResultBean({
    required this.speaker,
    required this.startTime,
    required this.endTime,
    required this.text,
    required this.selected,
    required this.nameModified,
  });

  factory AudioResultBean.fromJson(Map<String, dynamic> json) {
    final nameModified = json["nameModified"] ?? false;
    final name = json["speaker"] ?? "";
    return AudioResultBean(
      speaker: nameModified ? name : "角色${name}",
      startTime: json["start_time"]?.toDouble(),
      endTime: json["end_time"]?.toDouble(),
      text: json["text"],
      selected: json["selected"] ?? true,
      nameModified: nameModified,
    );
  }
  String realName() {
    return nameModified ? speaker : speaker.replaceAll("角色", "");
  }

  Map<String, dynamic> toJson() => {
        "speaker": nameModified ? speaker : speaker.replaceAll("角色", ""),
        "start_time": startTime,
        "end_time": endTime,
        "text": text,
        "selected": selected,
        "nameModified": nameModified,
      };

  AudioResultBean copyWith({
    String? speaker,
    double? startTime,
    double? endTime,
    String? text,
    bool? selected,
    bool? nameModified,
  }) =>
      AudioResultBean(
        speaker: speaker ?? this.speaker,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        text: text ?? this.text,
        selected: selected ?? this.selected,
        nameModified: nameModified ?? this.nameModified,
      );
}
