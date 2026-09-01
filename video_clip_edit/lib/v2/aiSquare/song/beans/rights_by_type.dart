// To parse this JSON data, do
//
//     final rightsByType = rightsByTypeFromJson(jsonString);

import 'dart:convert';

import 'package:get/get_core/src/get_main.dart';

RightsByType rightsByTypeFromJson(String str) =>
    RightsByType.fromJson(json.decode(str));

String rightsByTypeToJson(RightsByType data) => json.encode(data.toJson());

class RightsByType {
  int? isTest;
  int? testCount;
  int freeCount;
  int maxFreeCount;
  int freeIntegral;
  int textLength;
  int voiceLength;
  int currentIntegral;
  int configIntegral;
  String show;
  int userIntegral;
  int vipLevel;
  String vipLevelText;

  RightsByType({
    this.isTest,
    required this.testCount,
    required this.freeCount,
    required this.maxFreeCount,
    required this.freeIntegral,
    required this.textLength,
    required this.voiceLength,
    required this.currentIntegral,
    required this.configIntegral,
    required this.show,
    required this.userIntegral,
    required this.vipLevel,
    required this.vipLevelText,
  });

  factory RightsByType.fromJson(Map<String, dynamic> json) {
    Get.log("===rights_by_type=== ${json}");
    // 不同 type 返回字段不同，digital_human 等只返回 user_integral/vip_level/vip_level_text，需做空值保护
    return RightsByType(
      isTest: json["is_test"],
      testCount: json["test_count"] ?? 0,
      freeCount: json["free_count"] ?? 0,
      maxFreeCount: json["maxFreeCount"] ?? 0,
      freeIntegral: json["freeIntegral"] ?? 0,
      textLength: json["textLength"] ?? 0,
      voiceLength: json["voiceLength"] ?? 0,
      currentIntegral: json["currentIntegral"] ?? 0,
      configIntegral: json["configIntegral"] ?? 0,
      show: json["show"] ?? '',
      userIntegral: json["user_integral"] ?? 0,
      vipLevel: json["vip_level"] ?? 0,
      vipLevelText: json["vip_level_text"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "is_test": isTest,
    "test_count": testCount,
    "free_count": freeCount,
    "maxFreeCount": maxFreeCount,
    "freeIntegral": freeIntegral,
    "textLength": textLength,
    "voiceLength": voiceLength,
    "currentIntegral": currentIntegral,
    "configIntegral": configIntegral,
    "show": show,
    "user_integral": userIntegral,
    "vip_level": vipLevel,
    "vip_level_text": vipLevelText,
  };
}
