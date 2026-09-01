// To parse this JSON data, do
//
//     final textRiskBean = textRiskBeanFromJson(jsonString);

import 'dart:convert';

TextRiskBean textRiskBeanFromJson(String str) =>
    TextRiskBean.fromJson(json.decode(str));

String textRiskBeanToJson(TextRiskBean data) => json.encode(data.toJson());

class TextRiskBean {
  bool isRisk;
  List<String> labelName;
  String markContent;

  TextRiskBean({
    required this.isRisk,
    required this.labelName,
    required this.markContent,
  });

  factory TextRiskBean.fromJson(Map<String, dynamic> json) => TextRiskBean(
        isRisk: json["isRisk"] ?? false,
        labelName: List<String>.from((json["labelName"] ?? []).map((x) => x)),
        markContent: json["markContent"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "isRisk": isRisk,
        "labelName": List<dynamic>.from(labelName.map((x) => x)),
        "markContent": markContent,
      };
}
