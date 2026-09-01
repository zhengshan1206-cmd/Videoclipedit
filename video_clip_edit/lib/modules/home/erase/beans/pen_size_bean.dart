// To parse this JSON data, do
//
//     final penSizeBean = penSizeBeanFromJson(jsonString);

import 'dart:convert';

PenSizeBean penSizeBeanFromJson(String str) =>
    PenSizeBean.fromJson(json.decode(str));

String penSizeBeanToJson(PenSizeBean data) => json.encode(data.toJson());

class PenSizeBean {
  double penSize;
  double radius;
  bool selected;

  PenSizeBean({
    required this.penSize,
    required this.radius,
    required this.selected,
  });

  factory PenSizeBean.fromJson(Map<String, dynamic> json) => PenSizeBean(
        penSize: json["penSize"],
        radius: json["radius"],
        selected: json["selected"],
      );

  Map<String, dynamic> toJson() => {
        "penSize": penSize,
        "radius": radius,
        "selected": selected,
      };
}
