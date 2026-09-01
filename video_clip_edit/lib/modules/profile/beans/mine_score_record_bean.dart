import 'dart:convert';

class MineScoreRecordBean {
  int integral;
  String des;
  String createdAt;

  MineScoreRecordBean({
    required this.integral,
    required this.des,
    required this.createdAt,
  });

  MineScoreRecordBean copyWith({
    int? integral,
    String? des,
    String? createdAt,
  }) =>
      MineScoreRecordBean(
        integral: integral ?? this.integral,
        des: des ?? this.des,
        createdAt: createdAt ?? this.createdAt,
      );

  factory MineScoreRecordBean.fromRawJson(String str) =>
      MineScoreRecordBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MineScoreRecordBean.fromJson(Map<String, dynamic> json) =>
      MineScoreRecordBean(
        integral: json["integral"],
        des: json["des"],
        createdAt: json["created_at"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "integral": integral,
        "des": des,
        "created_at": createdAt,
      };
}
