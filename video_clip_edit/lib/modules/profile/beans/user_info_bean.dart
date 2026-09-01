// To parse this JSON data, do
//
//     final userInfoBean = userInfoBeanFromJson(jsonString);

import 'dart:convert';

UserInfoBean userInfoBeanFromJson(String str) =>
    UserInfoBean.fromJson(json.decode(str));

String userInfoBeanToJson(UserInfoBean data) => json.encode(data.toJson());

enum VIPLevel {
  none(0),
  oneDay(1),
  threeDay(3),
  week(7),
  monthy(30),
  quarterly(90),
  yearly(365),
  lifeTime(99999),
  exclusive(999999);

  const VIPLevel(this.value);

  final int value;

  static VIPLevel level(int vipLevel) {
    return VIPLevel.values.firstWhere(
      (status) => status.value == vipLevel,
    );
  }

  String get vipLevelName {
    switch (this) {
      case none:
        return '';
      case oneDay:
        return "1天体验会员";
      case threeDay:
        return "3天体验会员";
      case week:
        return "7天体验会员";
      case monthy:
        return "月度会员";
      case quarterly:
        return "季度会员";
      case yearly:
        return "年度会员";
      case lifeTime:
        return "终身会员";
      case exclusive:
        return "尊享会员";
    }
  }

  bool isPermanentVip() {
    return this == lifeTime || this == exclusive;
  }
}

extension VIPLevelValue on VIPLevel {
  int get rawValue {
    switch (this) {
      case VIPLevel.none:
        return 0;
      case VIPLevel.oneDay:
        return 1;
      case VIPLevel.threeDay:
        return 3;
      case VIPLevel.week:
        return 7;
      case VIPLevel.monthy:
        return 30;
      case VIPLevel.quarterly:
        return 90;
      case VIPLevel.yearly:
        return 365;
      case VIPLevel.lifeTime:
        return 99999;
      case VIPLevel.exclusive:
        return 999999;
    }
  }

  String get typeName {
    switch (this) {
      case VIPLevel.none:
        return "";
      case VIPLevel.oneDay:
        return "1天体验会员";
      case VIPLevel.threeDay:
        return "3天体验会员";
      case VIPLevel.week:
        return "7天体验会员";
      case VIPLevel.monthy:
        return "月度会员";
      case VIPLevel.quarterly:
        return "季度会员";
      case VIPLevel.yearly:
        return "年度会员";
      case VIPLevel.lifeTime:
        return "终身会员";
      case VIPLevel.exclusive:
        return "尊享会员";
    }
  }

  static VIPLevel fromRawValue(int rawValue) {
    return VIPLevel.values.firstWhere(
      (status) => status.rawValue == rawValue,
    );
  }

  static String typeNameFromRawValue(int rawValue) {
    return VIPLevel.values
        .firstWhere(
          (status) => status.rawValue == rawValue,
        )
        .typeName;
  }
}

class UserInfoBean {
  String avatar;
  String nickName;
  int userId;
  int isBindWx;
  int isBindPhone;
  String phone;
  int isVip;
  int vipLevel;
  DateTime? vipEndTime;
  int isSubscribe;
  int isOpenWeb;
  String nextExecuteTime;
  String nextExecuteTimeDes;
  String complaintUrl;
  String kfUrl;
  int isFormal;
  int integral;

  ///当前用户活跃天数
  int? activeDay;

  ///是否是48小时内新用户归因
  int? isNewAttributionUser;

  //是否有过归因  1是 0否
  int? hasAttribution;

  // need_retention_pop 用户发起过支付后是否需要拦截弹窗  1是 0否
  int? needRetentionPop;

  UserInfoBean({
    required this.avatar,
    required this.nickName,
    required this.userId,
    required this.isBindWx,
    required this.isBindPhone,
    required this.phone,
    required this.isVip,
    required this.vipLevel,
    required this.vipEndTime,
    required this.isSubscribe,
    required this.isOpenWeb,
    required this.nextExecuteTime,
    required this.nextExecuteTimeDes,
    required this.complaintUrl,
    required this.kfUrl,
    required this.isFormal,
    required this.integral,
    required this.activeDay,
    required this.isNewAttributionUser,
    required this.hasAttribution,
    required this.needRetentionPop,
  });

  factory UserInfoBean.fromJson(Map<String, dynamic> json) => UserInfoBean(
        avatar: json["avatar"],
        nickName: json["nick_name"],
        userId: json["user_id"],
        isBindWx: json["is_bind_wx"],
        isBindPhone: json["is_bind_phone"],
        phone: json["phone"],
        isVip: json["is_vip"],
        vipLevel: json["vip_level"],
        vipEndTime: json["vip_end_time"] == null
            ? null
            : DateTime.parse(json["vip_end_time"]),
        isSubscribe: json["is_subscribe"],
        isOpenWeb: json["is_open_web"],
        nextExecuteTime: json["next_execute_time"],
        nextExecuteTimeDes: json["next_execute_time_des"],
        complaintUrl: json["complaint_url"],
        kfUrl: json["kf_url"],
        isFormal: json["is_formal"],
        integral: json["integral"],
        activeDay: json['active_day'],
        isNewAttributionUser: json['is_new_attribution_user'] ?? 0,
        hasAttribution: json['has_attribution'] ?? 0,
        needRetentionPop: json['need_retention_pop'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "avatar": avatar,
        "nick_name": nickName,
        "user_id": userId,
        "is_bind_wx": isBindWx,
        "is_bind_phone": isBindPhone,
        "phone": phone,
        "is_vip": isVip,
        "vip_level": vipLevel,
        "vip_end_time": vipEndTime == null
            ? null
            : "${vipEndTime!.year.toString().padLeft(4, '0')}-${vipEndTime!.month.toString().padLeft(2, '0')}-${vipEndTime!.day.toString().padLeft(2, '0')}",
        "is_subscribe": isSubscribe,
        "is_open_web": isOpenWeb,
        "next_execute_time": nextExecuteTime,
        "next_execute_time_des": nextExecuteTimeDes,
        "complaint_url": complaintUrl,
        "kf_url": kfUrl,
        "is_formal": isFormal,
        "integral": integral,
        "active_day": activeDay,
        "is_new_attribution_user": isNewAttributionUser,
        "has_attribution": hasAttribution,
        "need_retention_pop": needRetentionPop,
      };

  String get vipLevelName => level.vipLevelName;

  VIPLevel get level => VIPLevel.level(vipLevel);

  bool isPremiumMember() => level.isPermanentVip();
}
