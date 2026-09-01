// To parse this JSON data, do
//
//     final vipTypeBean = vipTypeBeanFromJson(jsonString);

import 'dart:convert';

import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';

VipTypeBean vipTypeBeanFromJson(String str) =>
    VipTypeBean.fromJson(json.decode(str));

String vipTypeBeanToJson(VipTypeBean data) => json.encode(data.toJson());

class VipTypeBean {
  int id;
  String appleVipId;
  String money;
  String firstCheapMoney;
  String crossedMoney;
  String des;
  String title;
  String illustrate;
  int isDefault;
  int isAgreement;
  int isOpenWeb;
  String webDes;
  String dayMoney;
  String monthMoney;
  DateTime vipEndTime;
  int day;
  int isFirstFree;
  int integral;
  String subscribePeriodDes;
  int isSubscribe;
  String pagePath;
  String subscribeMoney;
  int subscribeIntegral;
  String subscribeVipEndTime;
  int vipLevel;
  int vipListStyle;
  int orderNum;
  String buttonTitle;
  String mark;

  VipTypeBean({
    required this.id,
    required this.appleVipId,
    required this.money,
    required this.firstCheapMoney,
    required this.crossedMoney,
    required this.des,
    required this.title,
    required this.illustrate,
    required this.isDefault,
    required this.isAgreement,
    required this.isOpenWeb,
    required this.webDes,
    required this.dayMoney,
    required this.monthMoney,
    required this.vipEndTime,
    required this.day,
    required this.isFirstFree,
    required this.integral,
    required this.subscribePeriodDes,
    required this.isSubscribe,
    required this.pagePath,
    required this.subscribeMoney,
    required this.subscribeIntegral,
    required this.subscribeVipEndTime,
    required this.vipLevel,
    required this.vipListStyle,
    required this.orderNum,
    required this.buttonTitle,
    required this.mark,
  });

  factory VipTypeBean.fromJson(Map<String, dynamic> json) => VipTypeBean(
        id: json["id"],
        appleVipId: json["apple_vip_id"],
        money: json["money"].toString(),
        firstCheapMoney: json["first_cheap_money"].toString(),
        crossedMoney: json["crossed_money"],
        des: json["des"],
        title: json["title"],
        illustrate: json["illustrate"],
        isDefault: json["is_default"],
        isAgreement: json["is_agreement"],
        isOpenWeb: json["is_open_web"],
        webDes: json["web_des"],
        dayMoney: json["day_money"],
        monthMoney: json["month_money"],
        vipEndTime: DateTime.parse(json["vip_end_time"]),
        day: json["day"],
        isFirstFree: json["is_first_free"],
        integral: json["integral"],
        subscribePeriodDes: json["subscribe_period_des"],
        isSubscribe: json["is_subscribe"],
        pagePath: json["page_path"],
        subscribeMoney: json["subscribe_money"],
        subscribeIntegral: json["subscribe_integral"],
        subscribeVipEndTime: json["subscribe_vip_end_time"],
        vipLevel: json["vip_level"] ?? 0,
        vipListStyle: json["vip_list_style"],
        orderNum: json["order_num"],
        buttonTitle: json["button_title"],
        mark: json["mark"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "apple_vip_id": appleVipId,
        "money": money,
        "first_cheap_money": firstCheapMoney,
        "crossed_money": crossedMoney,
        "des": des,
        "title": title,
        "illustrate": illustrate,
        "is_default": isDefault,
        "is_agreement": isAgreement,
        "is_open_web": isOpenWeb,
        "web_des": webDes,
        "day_money": dayMoney,
        "month_money": monthMoney,
        "vip_end_time": vipEndTime.toIso8601String(),
        "day": day,
        "is_first_free": isFirstFree,
        "integral": integral,
        "subscribe_period_des": subscribePeriodDes,
        "is_subscribe": isSubscribe,
        "page_path": pagePath,
        "subscribe_money": subscribeMoney,
        "subscribe_integral": subscribeIntegral,
        "subscribe_vip_end_time": subscribeVipEndTime,
        "vip_level": vipLevel,
        "vip_list_style": vipListStyle,
        "order_num": orderNum,
        "button_title": buttonTitle,
        "mark": mark,
      };

  VIPLevel get level => VIPLevel.level(vipLevel);

  bool isPremiumMember() => level.isPermanentVip();
}
