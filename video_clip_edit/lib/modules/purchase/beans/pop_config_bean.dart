// To parse this JSON data, do
//
//     final popConfigBean = popConfigBeanFromJson(jsonString);

import 'dart:convert';

PopConfigBean popConfigBeanFromJson(String str) =>
    PopConfigBean.fromJson(json.decode(str));

String popConfigBeanToJson(PopConfigBean data) => json.encode(data.toJson());

class PopConfigBean {
  int id;
  String title;
  int adLinkType;
  String times;
  int popType;
  String img;
  String popBtnTitle;
  int vipId;
  String closeBtnType;
  int popUpId;
  int status;
  int orderNum;
  DateTime updatedAt;
  DateTime createdAt;
  String minTimes;
  String maxTimes;
  List<VipInfo> vipInfo;
  int maxShowLimit;

  PopConfigBean({
    required this.id,
    required this.title,
    required this.adLinkType,
    required this.times,
    required this.popType,
    required this.img,
    required this.popBtnTitle,
    required this.vipId,
    required this.closeBtnType,
    required this.popUpId,
    required this.status,
    required this.orderNum,
    required this.updatedAt,
    required this.createdAt,
    required this.minTimes,
    required this.maxTimes,
    required this.vipInfo,
    required this.maxShowLimit,
  });

  factory PopConfigBean.fromJson(Map<String, dynamic> json) => PopConfigBean(
    id: json["id"],
    title: json["title"],
    adLinkType: json["ad_link_type"],
    times: json["times"],
    popType: json["pop_type"],
    img: json["img"],
    popBtnTitle: json["pop_btn_title"],
    vipId: json["vip_id"],
    closeBtnType: json["close_btn_type"],
    popUpId: json["pop_up_id"],
    status: json["status"],
    orderNum: json["order_num"],
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    minTimes: json["min_times"],
    maxTimes: json["max_times"],
    vipInfo: List<VipInfo>.from(
      json["vip_info"].map((x) => VipInfo.fromJson(x)),
    ),
    maxShowLimit: json["max_show_limit"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "ad_link_type": adLinkType,
    "times": times,
    "pop_type": popType,
    "img": img,
    "pop_btn_title": popBtnTitle,
    "vip_id": vipId,
    "close_btn_type": closeBtnType,
    "pop_up_id": popUpId,
    "status": status,
    "order_num": orderNum,
    "updated_at": updatedAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "min_times": minTimes,
    "max_times": maxTimes,
    "vip_info": List<dynamic>.from(vipInfo.map((x) => x.toJson())),
    "max_show_limit": maxShowLimit,
  };
}

class VipInfo {
  int id;
  String appleVipId;
  String money;
  int firstCheapMoney;
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
  String integralMoney;
  String wordsPackMoney;
  DateTime vipEndTime;
  int day;
  int isFirstFree;
  int integral;
  int wordsPack;
  String subscribePeriodDes;
  int isSubscribe;
  String pagePath;
  String subscribeMoney;
  int subscribeIntegral;
  String subscribeVipEndTime;
  int vipLevel;
  int vipListStyle;
  int newUserVipListStyle;
  int retentionUserVipListStyle;
  int orderNum;
  String buttonTitle;
  String mark;
  int musicNum;
  List<String> boldArea;
  String musicMoney;

  VipInfo({
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
    required this.integralMoney,
    required this.wordsPackMoney,
    required this.vipEndTime,
    required this.day,
    required this.isFirstFree,
    required this.integral,
    required this.wordsPack,
    required this.subscribePeriodDes,
    required this.isSubscribe,
    required this.pagePath,
    required this.subscribeMoney,
    required this.subscribeIntegral,
    required this.subscribeVipEndTime,
    required this.vipLevel,
    required this.vipListStyle,
    required this.newUserVipListStyle,
    required this.retentionUserVipListStyle,
    required this.orderNum,
    required this.buttonTitle,
    required this.mark,
    required this.musicNum,
    required this.boldArea,
    required this.musicMoney,
  });

  factory VipInfo.fromJson(Map<String, dynamic> json) => VipInfo(
    id: json["id"],
    appleVipId: json["apple_vip_id"],
    money: json["money"],
    firstCheapMoney: json["first_cheap_money"],
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
    integralMoney: json["integral_money"],
    wordsPackMoney: json["words_pack_money"],
    vipEndTime: DateTime.parse(json["vip_end_time"]),
    day: json["day"],
    isFirstFree: json["is_first_free"],
    integral: json["integral"],
    wordsPack: json["words_pack"],
    subscribePeriodDes: json["subscribe_period_des"],
    isSubscribe: json["is_subscribe"],
    pagePath: json["page_path"],
    subscribeMoney: json["subscribe_money"],
    subscribeIntegral: json["subscribe_integral"],
    subscribeVipEndTime: json["subscribe_vip_end_time"],
    vipLevel: json["vip_level"],
    vipListStyle: json["vip_list_style"],
    newUserVipListStyle: json["new_user_vip_list_style"],
    retentionUserVipListStyle: json["retention_user_vip_list_style"],
    orderNum: json["order_num"],
    buttonTitle: json["button_title"],
    mark: json["mark"],
    musicNum: json["music_num"],
    boldArea: List<String>.from(json["bold_area"].map((x) => x)),
    musicMoney: json["music_money"],
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
    "integral_money": integralMoney,
    "words_pack_money": wordsPackMoney,
    "vip_end_time": vipEndTime.toIso8601String(),
    "day": day,
    "is_first_free": isFirstFree,
    "integral": integral,
    "words_pack": wordsPack,
    "subscribe_period_des": subscribePeriodDes,
    "is_subscribe": isSubscribe,
    "page_path": pagePath,
    "subscribe_money": subscribeMoney,
    "subscribe_integral": subscribeIntegral,
    "subscribe_vip_end_time": subscribeVipEndTime,
    "vip_level": vipLevel,
    "vip_list_style": vipListStyle,
    "new_user_vip_list_style": newUserVipListStyle,
    "retention_user_vip_list_style": retentionUserVipListStyle,
    "order_num": orderNum,
    "button_title": buttonTitle,
    "mark": mark,
    "music_num": musicNum,
    "bold_area": List<dynamic>.from(boldArea.map((x) => x)),
    "music_money": musicMoney,
  };
}
