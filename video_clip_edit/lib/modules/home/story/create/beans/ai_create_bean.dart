// To parse this JSON data, do
//
//     final aiCreateBean = aiCreateBeanFromJson(jsonString);

import 'dart:convert';

AiCreateBean aiCreateBeanFromJson(String str) =>
    AiCreateBean.fromJson(json.decode(str));

String aiCreateBeanToJson(AiCreateBean data) => json.encode(data.toJson());

class AiCreateBean {
  String token;
  String sketch;
  String ask;
  int status;
  String answer;
  DateTime createTime;
  DateTime answerStartTime;
  DateTime answerEndTime;

  AiCreateBean({
    required this.token,
    required this.sketch,
    required this.ask,
    required this.status,
    required this.answer,
    required this.createTime,
    required this.answerStartTime,
    required this.answerEndTime,
  });

  factory AiCreateBean.fromJson(Map<String, dynamic> json) => AiCreateBean(
        token: json["token"],
        sketch: json["sketch"],
        ask: json["ask"],
        status: json["status"],
        answer: json["answer"],
        createTime: DateTime.parse(json["create_time"]),
        answerStartTime: DateTime.parse(json["answer_start_time"]),
        answerEndTime: DateTime.parse(json["answer_end_time"]),
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "sketch": sketch,
        "ask": ask,
        "status": status,
        "answer": answer,
        "create_time": createTime.toIso8601String(),
        "answer_start_time": answerStartTime.toIso8601String(),
        "answer_end_time": answerEndTime.toIso8601String(),
      };
}
