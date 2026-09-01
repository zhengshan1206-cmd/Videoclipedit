// To parse this JSON data, do
//
//     final integralPayListBean = integralPayListBeanFromJson(jsonString);

import 'dart:convert';

IntegralPayListBean integralPayListBeanFromJson(String str) =>
    IntegralPayListBean.fromJson(json.decode(str));

String integralPayListBeanToJson(IntegralPayListBean data) =>
    json.encode(data.toJson());

class IntegralPayListBean {
  int id;
  String appleVipId;
  String money;
  String mark;
  int isDefault;
  int isAgreement;
  String unitIntegralMoney;
  int integral;
  String crossedMoney;
  String desc;
  String buttonTitle;
  Pays? pays;

  IntegralPayListBean({
    required this.id,
    required this.appleVipId,
    required this.money,
    required this.mark,
    required this.isDefault,
    required this.isAgreement,
    required this.unitIntegralMoney,
    required this.integral,
    required this.crossedMoney,
    required this.desc,
    required this.buttonTitle,
    this.pays,
  });

  factory IntegralPayListBean.fromJson(Map<String, dynamic> json) =>
      IntegralPayListBean(
        id: json["id"],
        appleVipId: json["apple_vip_id"],
        money: json["money"],
        mark: json["mark"],
        isDefault: json["is_default"],
        isAgreement: json["is_agreement"],
        unitIntegralMoney: json["unit_integral_money"],
        integral: json["integral"],
        crossedMoney: json["crossed_money"],
        desc: json["desc"],
        buttonTitle: json["button_title"],
        pays: json["pays"] != null ? Pays.fromJson(json["pays"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "apple_vip_id": appleVipId,
        "money": money,
        "mark": mark,
        "is_default": isDefault,
        "is_agreement": isAgreement,
        "unit_integral_money": unitIntegralMoney,
        "integral": integral,
        "crossed_money": crossedMoney,
        "desc": desc,
        "button_title": buttonTitle,
        "pays": pays?.toJson(),
      };
}

class Pays {
  int wxpay;
  int alipay;
  int yeepay;
  int applepay;

  Pays({
    required this.wxpay,
    required this.alipay,
    required this.yeepay,
    required this.applepay,
  });

  factory Pays.fromJson(Map<String, dynamic> json) => Pays(
        wxpay: json["wxpay"] ?? 0,
        alipay: json["alipay"] ?? 0,
        yeepay: json["yeepay"] ?? 0,
        applepay: json["applepay"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "wxpay": wxpay,
        "alipay": alipay,
        "yeepay": yeepay,
        "applepay": applepay,
      };
}
