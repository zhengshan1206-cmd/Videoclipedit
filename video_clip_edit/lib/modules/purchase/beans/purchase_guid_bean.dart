import 'dart:convert';

class PurchaseVipGuidBean {
  List<Broadcast> broadcasts;
  List<Copywriting> copywriting;
  List<Copywriting> copywritingV2;
  List<Comment> comments;
  User user;
  Head head;
  int vipPageIntercept;
  List<ZxtTag> zxtTag;
  String subscribeExplain;
  int showAdvipBtn;
  String kfQrcode;
  String kfUrl;
  int showKfGuide;

  PurchaseVipGuidBean({
    required this.broadcasts,
    required this.copywriting,
    required this.copywritingV2,
    required this.comments,
    required this.user,
    required this.head,
    required this.vipPageIntercept,
    required this.zxtTag,
    required this.subscribeExplain,
    required this.showAdvipBtn,
    required this.kfQrcode,
    required this.kfUrl,
    required this.showKfGuide,
  });

  PurchaseVipGuidBean copyWith({
    List<Broadcast>? broadcasts,
    List<Copywriting>? copywriting,
    List<Copywriting>? copywritingV2,
    List<Comment>? comments,
    User? user,
    Head? head,
    int? vipPageIntercept,
    List<ZxtTag>? zxtTag,
    String? subscribeExplain,
    int? showAdvipBtn,
    String? kfQrcode,
    String? kfUrl,
    int? showKfGuide,
  }) =>
      PurchaseVipGuidBean(
        broadcasts: broadcasts ?? this.broadcasts,
        copywriting: copywriting ?? this.copywriting,
        copywritingV2: copywritingV2 ?? this.copywritingV2,
        comments: comments ?? this.comments,
        user: user ?? this.user,
        head: head ?? this.head,
        vipPageIntercept: vipPageIntercept ?? this.vipPageIntercept,
        zxtTag: zxtTag ?? this.zxtTag,
        subscribeExplain: subscribeExplain ?? this.subscribeExplain,
        showAdvipBtn: showAdvipBtn ?? this.showAdvipBtn,
        kfQrcode: kfQrcode ?? this.kfQrcode,
        kfUrl: kfUrl ?? this.kfUrl,
        showKfGuide: showKfGuide ?? this.showKfGuide,
      );

  factory PurchaseVipGuidBean.fromRawJson(String str) =>
      PurchaseVipGuidBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PurchaseVipGuidBean.fromJson(Map<String, dynamic> json) =>
      PurchaseVipGuidBean(
        broadcasts: List<Broadcast>.from(
            json["broadcasts"].map((x) => Broadcast.fromJson(x))),
        copywriting: List<Copywriting>.from(
            json["copywriting"].map((x) => Copywriting.fromJson(x))),
        copywritingV2: List<Copywriting>.from(
            json["copywriting_v2"].map((x) => Copywriting.fromJson(x))),
        comments: List<Comment>.from(
            json["comments"].map((x) => Comment.fromJson(x))),
        user: User.fromJson(json["user"]),
        head: Head.fromJson(json["head"]),
        vipPageIntercept: json["vip_page_intercept"],
        zxtTag:
            List<ZxtTag>.from(json["zxt_tag"].map((x) => ZxtTag.fromJson(x))),
        subscribeExplain: json["subscribe_explain"],
        showAdvipBtn: json["show_advip_btn"],
        kfQrcode: json["kf_qrcode"],
        kfUrl: json["kf_url"],
        showKfGuide: json["show_kf_guide"],
      );

  Map<String, dynamic> toJson() => {
        "broadcasts": List<dynamic>.from(broadcasts.map((x) => x.toJson())),
        "copywriting": List<dynamic>.from(copywriting.map((x) => x.toJson())),
        "copywriting_v2":
            List<dynamic>.from(copywritingV2.map((x) => x.toJson())),
        "comments": List<dynamic>.from(comments.map((x) => x.toJson())),
        "user": user.toJson(),
        "head": head.toJson(),
        "vip_page_intercept": vipPageIntercept,
        "zxt_tag": List<dynamic>.from(zxtTag.map((x) => x.toJson())),
        "subscribe_explain": subscribeExplain,
        "show_advip_btn": showAdvipBtn,
        "kf_qrcode": kfQrcode,
        "kf_url": kfUrl,
        "show_kf_guide": showKfGuide,
      };
}

class Broadcast {
  String avatar;
  String text;
  String shortText;

  Broadcast({
    required this.avatar,
    required this.text,
    required this.shortText,
  });

  Broadcast copyWith({
    String? avatar,
    String? text,
    String? shortText,
  }) =>
      Broadcast(
        avatar: avatar ?? this.avatar,
        text: text ?? this.text,
        shortText: shortText ?? this.shortText,
      );

  factory Broadcast.fromRawJson(String str) =>
      Broadcast.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Broadcast.fromJson(Map<String, dynamic> json) => Broadcast(
        avatar: json["avatar"],
        text: json["text"],
        shortText: json["short_text"],
      );

  Map<String, dynamic> toJson() => {
        "avatar": avatar,
        "text": text,
        "short_text": shortText,
      };
}

class Comment {
  String avatar;
  String nickName;
  String comment;
  String vipTitle;

  Comment({
    required this.avatar,
    required this.nickName,
    required this.comment,
    required this.vipTitle,
  });

  Comment copyWith({
    String? avatar,
    String? nickName,
    String? comment,
    String? vipTitle,
  }) =>
      Comment(
        avatar: avatar ?? this.avatar,
        nickName: nickName ?? this.nickName,
        comment: comment ?? this.comment,
        vipTitle: vipTitle ?? this.vipTitle,
      );

  factory Comment.fromRawJson(String str) => Comment.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        avatar: json["avatar"],
        nickName: json["nick_name"],
        comment: json["comment"],
        vipTitle: json["vip_title"],
      );

  Map<String, dynamic> toJson() => {
        "avatar": avatar,
        "nick_name": nickName,
        "comment": comment,
        "vip_title": vipTitle,
      };
}

class Copywriting {
  String icon;
  String title;
  String des;

  Copywriting({
    required this.icon,
    required this.title,
    required this.des,
  });

  Copywriting copyWith({
    String? icon,
    String? title,
    String? des,
  }) =>
      Copywriting(
        icon: icon ?? this.icon,
        title: title ?? this.title,
        des: des ?? this.des,
      );

  factory Copywriting.fromRawJson(String str) =>
      Copywriting.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Copywriting.fromJson(Map<String, dynamic> json) => Copywriting(
        icon: json["icon"],
        title: json["title"],
        des: json["des"],
      );

  Map<String, dynamic> toJson() => {
        "icon": icon,
        "title": title,
        "des": des,
      };
}

class Head {
  String bg;
  String bg2;
  List<String> rotate;
  List<String> rotate2;

  Head({
    required this.bg,
    required this.bg2,
    required this.rotate,
    required this.rotate2,
  });

  Head copyWith({
    String? bg,
    String? bg2,
    List<String>? rotate,
    List<String>? rotate2,
  }) =>
      Head(
        bg: bg ?? this.bg,
        bg2: bg2 ?? this.bg2,
        rotate: rotate ?? this.rotate,
        rotate2: rotate2 ?? this.rotate2,
      );

  factory Head.fromRawJson(String str) => Head.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Head.fromJson(Map<String, dynamic> json) => Head(
        bg: json["bg"],
        bg2: json["bg2"],
        rotate: List<String>.from(json["rotate"].map((x) => x)),
        rotate2: List<String>.from(json["rotate2"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "bg": bg,
        "bg2": bg2,
        "rotate": List<dynamic>.from(rotate.map((x) => x)),
        "rotate2": List<dynamic>.from(rotate2.map((x) => x)),
      };
}

class User {
  int userId;
  String avatar;
  String nickName;
  int isVip;
  int integral;
  int vipLevel;
  String vipLevelText;
  dynamic vipEndTime;
  String exitCopywriting;
  int exitCountdown;
  String protocolUrl;
  String subscribeProtocolUrl;
  String inform;

  User({
    required this.userId,
    required this.avatar,
    required this.nickName,
    required this.isVip,
    required this.integral,
    required this.vipLevel,
    required this.vipLevelText,
    required this.vipEndTime,
    required this.exitCopywriting,
    required this.exitCountdown,
    required this.protocolUrl,
    required this.subscribeProtocolUrl,
    required this.inform,
  });

  User copyWith({
    int? userId,
    String? avatar,
    String? nickName,
    int? isVip,
    int? integral,
    int? vipLevel,
    String? vipLevelText,
    dynamic vipEndTime,
    String? exitCopywriting,
    int? exitCountdown,
    String? protocolUrl,
    String? subscribeProtocolUrl,
    String? inform,
  }) =>
      User(
        userId: userId ?? this.userId,
        avatar: avatar ?? this.avatar,
        nickName: nickName ?? this.nickName,
        isVip: isVip ?? this.isVip,
        integral: integral ?? this.integral,
        vipLevel: vipLevel ?? this.vipLevel,
        vipLevelText: vipLevelText ?? this.vipLevelText,
        vipEndTime: vipEndTime ?? this.vipEndTime,
        exitCopywriting: exitCopywriting ?? this.exitCopywriting,
        exitCountdown: exitCountdown ?? this.exitCountdown,
        protocolUrl: protocolUrl ?? this.protocolUrl,
        subscribeProtocolUrl: subscribeProtocolUrl ?? this.subscribeProtocolUrl,
        inform: inform ?? this.inform,
      );

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json["user_id"],
        avatar: json["avatar"],
        nickName: json["nick_name"],
        isVip: json["is_vip"],
        integral: json["integral"],
        vipLevel: json["vip_level"],
        vipLevelText: json["vip_level_text"],
        vipEndTime: json["vip_end_time"],
        exitCopywriting: json["exit_copywriting"],
        exitCountdown: json["exit_countdown"],
        protocolUrl: json["protocol_url"],
        subscribeProtocolUrl: json["subscribe_protocol_url"],
        inform: json["inform"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "avatar": avatar,
        "nick_name": nickName,
        "is_vip": isVip,
        "integral": integral,
        "vip_level": vipLevel,
        "vip_level_text": vipLevelText,
        "vip_end_time": vipEndTime,
        "exit_copywriting": exitCopywriting,
        "exit_countdown": exitCountdown,
        "protocol_url": protocolUrl,
        "subscribe_protocol_url": subscribeProtocolUrl,
        "inform": inform,
      };
}

class ZxtTag {
  String pic;
  String pic2;
  String banner;

  ZxtTag({
    required this.pic,
    required this.pic2,
    required this.banner,
  });

  ZxtTag copyWith({
    String? pic,
    String? pic2,
    String? banner,
  }) =>
      ZxtTag(
        pic: pic ?? this.pic,
        pic2: pic2 ?? this.pic2,
        banner: banner ?? this.banner,
      );

  factory ZxtTag.fromRawJson(String str) => ZxtTag.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ZxtTag.fromJson(Map<String, dynamic> json) => ZxtTag(
        pic: json["pic"],
        pic2: json["pic_2"],
        banner: json["banner"],
      );

  Map<String, dynamic> toJson() => {
        "pic": pic,
        "pic_2": pic2,
        "banner": banner,
      };
}
