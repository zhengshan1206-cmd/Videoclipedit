import 'package:get/get_core/src/get_main.dart';

class KaiGuanConfigBean {
  KaiGuan kaiGuan;
  KaiGuan tuPian;

  KaiGuanConfigBean({
    required this.kaiGuan,
    required this.tuPian,
  });

  factory KaiGuanConfigBean.fromJson(Map<String, dynamic> json) {
    Get.log(
        "=====tuPian=== ${json["tu_pian"]}   kaiGuan====${json["kai_guan"]}");
    return KaiGuanConfigBean(
      kaiGuan: KaiGuan.fromJson(json["kai_guan"]),
      tuPian: KaiGuan.fromJson(json["tu_pian"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "kai_guan": kaiGuan.toJson(),
        "tu_pian": tuPian.toJson(),
      };
}

class KaiGuan {
  String? key;
  String? name;
  int? valType;
  String valText;
  String? des;

  KaiGuan({
    this.key,
    this.name,
    this.valType,
    this.valText = "",
    this.des,
  });

  factory KaiGuan.fromJson(Map<String, dynamic>? json) {
    Get.log("开关的数据===> $json");
    if (json == null) {
      return KaiGuan();
    }
    return KaiGuan(
      key: json["key"],
      name: json["name"],
      valType: json["val_type"],
      valText: json["val_text"] ?? '',
      des: json["des"],
    );
  }

  Map<String, dynamic> toJson() => {
        "key": key,
        "name": name,
        "val_type": valType,
        "val_text": valText,
        "des": des,
      };
}
