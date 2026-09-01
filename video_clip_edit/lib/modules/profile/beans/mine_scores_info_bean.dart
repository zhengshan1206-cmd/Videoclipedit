import 'dart:convert';

class MineScoresInfoBean {
  Describe describe;
  User user;

  MineScoresInfoBean({
    required this.describe,
    required this.user,
  });

  MineScoresInfoBean copyWith({
    Describe? describe,
    User? user,
  }) =>
      MineScoresInfoBean(
        describe: describe ?? this.describe,
        user: user ?? this.user,
      );

  factory MineScoresInfoBean.fromRawJson(String str) =>
      MineScoresInfoBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MineScoresInfoBean.fromJson(Map<String, dynamic> json) =>
      MineScoresInfoBean(
        describe: Describe.fromJson(json["describe"]),
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "describe": describe.toJson(),
        "user": user.toJson(),
      };
}

class Describe {
  String title;
  List<String> items;

  Describe({
    required this.title,
    required this.items,
  });

  Describe copyWith({
    String? title,
    List<String>? items,
  }) =>
      Describe(
        title: title ?? this.title,
        items: items ?? this.items,
      );

  factory Describe.fromRawJson(String str) =>
      Describe.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Describe.fromJson(Map<String, dynamic> json) => Describe(
        title: json["title"],
        items: List<String>.from(json["items"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "items": List<dynamic>.from(items.map((x) => x)),
      };
}

class User {
  int id;
  int isVip;
  dynamic vipEndTime;
  int integral;
  String avatar;
  String nickName;
  int userId;
  String protocolUrl;
  String inform;
  List<String> integralRule;
  User({
    required this.id,
    required this.isVip,
    required this.vipEndTime,
    required this.integral,
    required this.avatar,
    required this.nickName,
    required this.userId,
    required this.protocolUrl,
    required this.inform,
    required this.integralRule,
  });

  User copyWith({
    int? id,
    int? isVip,
    dynamic vipEndTime,
    int? integral,
    String? avatar,
    String? nickName,
    int? userId,
    String? protocolUrl,
    String? inform,
    List<String>? integralRule,
  }) =>
      User(
        id: id ?? this.id,
        isVip: isVip ?? this.isVip,
        vipEndTime: vipEndTime ?? this.vipEndTime,
        integral: integral ?? this.integral,
        avatar: avatar ?? this.avatar,
        nickName: nickName ?? this.nickName,
        userId: userId ?? this.userId,
        protocolUrl: protocolUrl ?? this.protocolUrl,
        inform: inform ?? this.inform,
        integralRule: integralRule ?? this.integralRule,
      );

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json["id"],
      isVip: json["is_vip"],
      vipEndTime: json["vip_end_time"],
      integral: json["integral"],
      avatar: json["avatar"],
      nickName: json["nick_name"],
      userId: json["user_id"],
      protocolUrl: json["protocol_url"],
      inform: json["inform"],
      integralRule: List<String>.from(json["integral_rule"] ?? []));

  Map<String, dynamic> toJson() => {
        "id": id,
        "is_vip": isVip,
        "vip_end_time": vipEndTime,
        "integral": integral,
        "avatar": avatar,
        "nick_name": nickName,
        "user_id": userId,
        "protocol_url": protocolUrl,
        "inform": inform,
        "integral_rule": integralRule,
      };
}
