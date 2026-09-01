// To parse this JSON data, do
//
//     final vipSpecialBean = vipSpecialBeanFromJson(jsonString);

import 'dart:convert';

VipSpecialBean vipSpecialBeanFromJson(String str) =>
    VipSpecialBean.fromJson(json.decode(str));

String vipSpecialBeanToJson(VipSpecialBean data) => json.encode(data.toJson());

class VipSpecialBean {
  int countdown;
  String money;
  String crossedMoney;
  String des;
  String dayMoney;
  int id;

  VipSpecialBean({
    required this.countdown,
    required this.money,
    required this.crossedMoney,
    required this.des,
    required this.dayMoney,
    required this.id,
  });

  factory VipSpecialBean.fromJson(Map<String, dynamic> json) => VipSpecialBean(
        countdown: json["countdown"],
        money: json["money"].toString(),
        crossedMoney: json["crossed_money"].toString(),
        des: json["des"],
        dayMoney: json["day_money"].toString(),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "countdown": countdown,
        "money": money,
        "crossed_money": crossedMoney,
        "des": des,
        "day_money": dayMoney,
        "id": id,
      };
}
