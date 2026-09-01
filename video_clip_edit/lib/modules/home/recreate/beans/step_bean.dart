// To parse this JSON data, do
//
//     final stepBean = stepBeanFromJson(jsonString);

import 'dart:convert';

StepBean stepBeanFromJson(String str) => StepBean.fromJson(json.decode(str));

String stepBeanToJson(StepBean data) => json.encode(data.toJson());

class StepBean {
  String title;
  int step;

  StepBean({
    required this.title,
    required this.step,
  });

  factory StepBean.fromJson(Map<String, dynamic> json) => StepBean(
        title: json["title"],
        step: json["step"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "step": step,
      };
}
