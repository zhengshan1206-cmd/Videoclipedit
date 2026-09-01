import 'dart:convert';

class MineLegalrightBean {
  String avatar;
  String nickName;
  int userId;
  int isBindWx;
  int isVip;
  int vipLevel;
  String vipEndTime;
  int isSubscribe;
  int isOpenWeb;
  String nextExecuteTime;
  String nextExecuteTimeDes;
  int leafletsStatus;
  String leafletsImage;
  int leafletsType;
  String leafletsUrl;
  List<dynamic> legalright;
  List<dynamic> legalrightV2;
  List<Strategy> strategy;
  String inform;

  MineLegalrightBean({
    required this.avatar,
    required this.nickName,
    required this.userId,
    required this.isBindWx,
    required this.isVip,
    required this.vipLevel,
    required this.vipEndTime,
    required this.isSubscribe,
    required this.isOpenWeb,
    required this.nextExecuteTime,
    required this.nextExecuteTimeDes,
    required this.leafletsStatus,
    required this.leafletsImage,
    required this.leafletsType,
    required this.leafletsUrl,
    required this.legalright,
    required this.legalrightV2,
    required this.strategy,
    required this.inform,
  });

  MineLegalrightBean copyWith({
    String? avatar,
    String? nickName,
    int? userId,
    int? isBindWx,
    int? isVip,
    int? vipLevel,
    String? vipEndTime,
    int? isSubscribe,
    int? isOpenWeb,
    String? nextExecuteTime,
    String? nextExecuteTimeDes,
    int? leafletsStatus,
    String? leafletsImage,
    int? leafletsType,
    String? leafletsUrl,
    List<dynamic>? legalright,
    List<dynamic>? legalrightV2,
    List<Strategy>? strategy,
    String? inform,
  }) =>
      MineLegalrightBean(
        avatar: avatar ?? this.avatar,
        nickName: nickName ?? this.nickName,
        userId: userId ?? this.userId,
        isBindWx: isBindWx ?? this.isBindWx,
        isVip: isVip ?? this.isVip,
        vipLevel: vipLevel ?? this.vipLevel,
        vipEndTime: vipEndTime ?? this.vipEndTime,
        isSubscribe: isSubscribe ?? this.isSubscribe,
        isOpenWeb: isOpenWeb ?? this.isOpenWeb,
        nextExecuteTime: nextExecuteTime ?? this.nextExecuteTime,
        nextExecuteTimeDes: nextExecuteTimeDes ?? this.nextExecuteTimeDes,
        leafletsStatus: leafletsStatus ?? this.leafletsStatus,
        leafletsImage: leafletsImage ?? this.leafletsImage,
        leafletsType: leafletsType ?? this.leafletsType,
        leafletsUrl: leafletsUrl ?? this.leafletsUrl,
        legalright: legalright ?? this.legalright,
        legalrightV2: legalrightV2 ?? this.legalrightV2,
        strategy: strategy ?? this.strategy,
        inform: inform ?? this.inform,
      );

  factory MineLegalrightBean.fromRawJson(String str) =>
      MineLegalrightBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MineLegalrightBean.fromJson(Map<String, dynamic> json) =>
      MineLegalrightBean(
        avatar: json["avatar"],
        nickName: json["nick_name"],
        userId: json["user_id"],
        isBindWx: json["is_bind_wx"],
        isVip: json["is_vip"],
        vipLevel: json["vip_level"],
        vipEndTime: json["vip_end_time"],
        isSubscribe: json["is_subscribe"],
        isOpenWeb: json["is_open_web"],
        nextExecuteTime: json["next_execute_time"],
        nextExecuteTimeDes: json["next_execute_time_des"],
        leafletsStatus: json["leaflets_status"],
        leafletsImage: json["leaflets_image"],
        leafletsType: json["leaflets_type"],
        leafletsUrl: json["leaflets_url"],
        legalright: List<dynamic>.from(json["legalright"].map((x) => x)),
        legalrightV2: List<dynamic>.from(json["legalright_v2"].map((x) => x)),
        strategy: List<Strategy>.from(
            json["strategy"].map((x) => Strategy.fromJson(x))),
        inform: json["inform"],
      );

  Map<String, dynamic> toJson() => {
        "avatar": avatar,
        "nick_name": nickName,
        "user_id": userId,
        "is_bind_wx": isBindWx,
        "is_vip": isVip,
        "vip_level": vipLevel,
        "vip_end_time": vipEndTime,
        "is_subscribe": isSubscribe,
        "is_open_web": isOpenWeb,
        "next_execute_time": nextExecuteTime,
        "next_execute_time_des": nextExecuteTimeDes,
        "leaflets_status": leafletsStatus,
        "leaflets_image": leafletsImage,
        "leaflets_type": leafletsType,
        "leaflets_url": leafletsUrl,
        "legalright": List<dynamic>.from(legalright.map((x) => x)),
        "legalright_v2": List<dynamic>.from(legalrightV2.map((x) => x)),
        "strategy": List<dynamic>.from(strategy.map((x) => x.toJson())),
        "inform": inform,
      };
}

class Strategy {
  String title;
  String pic;
  String url;
  String pagePath;

  Strategy({
    required this.title,
    required this.pic,
    required this.url,
    required this.pagePath,
  });

  Strategy copyWith({
    String? title,
    String? pic,
    String? url,
    String? pagePath,
  }) =>
      Strategy(
        title: title ?? this.title,
        pic: pic ?? this.pic,
        url: url ?? this.url,
        pagePath: pagePath ?? this.pagePath,
      );

  factory Strategy.fromRawJson(String str) =>
      Strategy.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Strategy.fromJson(Map<String, dynamic> json) => Strategy(
        title: json["title"],
        pic: json["pic"],
        url: json["url"],
        pagePath: json["page_path"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "pic": pic,
        "url": url,
        "page_path": pagePath,
      };
}
