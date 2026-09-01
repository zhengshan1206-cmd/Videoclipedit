import 'dart:convert';

class NewToolBoxListBean {
  int id;
  int postionId;
  int categoryId;
  String title;
  String des;
  String icon;
  String bgimg;
  String style;
  String width;
  String height;
  int type;
  String jumpUrl;
  String jumpParam;
  String typeName;
  String typeBgcolor;
  int similarType;
  String similarJumpUrl;
  String similarJumpParam;
  String similarTypeName;
  String similarTypeBgcolor;
  String useTime;
  String withdrawMoney;
  String withdrawMoneyTip;

  NewToolBoxListBean({
    required this.id,
    required this.postionId,
    required this.categoryId,
    required this.title,
    required this.des,
    required this.icon,
    required this.bgimg,
    required this.style,
    required this.type,
    required this.jumpUrl,
    required this.jumpParam,
    required this.typeName,
    required this.typeBgcolor,
    required this.similarType,
    required this.similarJumpUrl,
    required this.similarJumpParam,
    required this.similarTypeName,
    required this.similarTypeBgcolor,
    required this.useTime,
    required this.withdrawMoney,
    required this.withdrawMoneyTip,
    required this.width,
    required this.height,
  });

  NewToolBoxListBean copyWith({
    int? id,
    int? postionId,
    int? categoryId,
    String? title,
    String? des,
    String? icon,
    String? bgimg,
    String? style,
    int? type,
    String? jumpUrl,
    String? jumpParam,
    String? typeName,
    String? typeBgcolor,
    int? similarType,
    String? similarJumpUrl,
    String? similarJumpParam,
    String? similarTypeName,
    String? similarTypeBgcolor,
    String? useTime,
    String? width,
    String? height,
    String? withdrawMoney,
    String? withdrawMoneyTip,
  }) =>
      NewToolBoxListBean(
        id: id ?? this.id,
        postionId: postionId ?? this.postionId,
        categoryId: categoryId ?? this.categoryId,
        title: title ?? this.title,
        des: des ?? this.des,
        icon: icon ?? this.icon,
        bgimg: bgimg ?? this.bgimg,
        style: style ?? this.style,
        type: type ?? this.type,
        jumpUrl: jumpUrl ?? this.jumpUrl,
        jumpParam: jumpParam ?? this.jumpParam,
        typeName: typeName ?? this.typeName,
        width: width ?? this.width,
        height: height ?? this.height,
        typeBgcolor: typeBgcolor ?? this.typeBgcolor,
        similarType: similarType ?? this.similarType,
        similarJumpUrl: similarJumpUrl ?? this.similarJumpUrl,
        similarJumpParam: similarJumpParam ?? this.similarJumpParam,
        similarTypeName: similarTypeName ?? this.similarTypeName,
        similarTypeBgcolor: similarTypeBgcolor ?? this.similarTypeBgcolor,
        useTime: useTime ?? this.useTime,
        withdrawMoney: withdrawMoney ?? this.withdrawMoney,
        withdrawMoneyTip: withdrawMoneyTip ?? this.withdrawMoneyTip,
      );

  double get coverRatio {
    if (width == "0" || height == "0") return 0;
    final widthValue = double.parse(width);
    final heightValue = double.parse(height);
    if (widthValue == 0 || heightValue == 0) return 0;
    double ratio = widthValue / heightValue;
    return ratio;
  }

  factory NewToolBoxListBean.fromRawJson(String str) =>
      NewToolBoxListBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NewToolBoxListBean.fromJson(Map<String, dynamic> json) =>
      NewToolBoxListBean(
        id: json["id"],
        postionId: json["postion_id"],
        categoryId: json["category_id"],
        title: json["title"],
        des: json["des"],
        icon: json["icon"],
        bgimg: json["bgimg"],
        style: json["style"],
        type: json["type"],
        width: (json["width"] ?? "0").toString(),
        height: (json["height"] ?? "0").toString(),
        jumpUrl: json["jump_url"],
        jumpParam: json["jump_param"],
        typeName: json["type_name"],
        typeBgcolor: json["type_bgcolor"],
        similarType: json["similar_type"],
        similarJumpUrl: json["similar_jump_url"],
        similarJumpParam: json["similar_jump_param"],
        similarTypeName: json["similar_type_name"],
        similarTypeBgcolor: json["similar_type_bgcolor"],
        useTime: json["use_time"],
        withdrawMoney: json["withdraw_money"],
        withdrawMoneyTip: json["withdraw_money_tip"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "postion_id": postionId,
        "category_id": categoryId,
        "title": title,
        "des": des,
        "icon": icon,
        "bgimg": bgimg,
        "style": style,
        "type": type,
        "width": width,
        "height": height,
        "jump_url": jumpUrl,
        "jump_param": jumpParam,
        "type_name": typeName,
        "type_bgcolor": typeBgcolor,
        "similar_type": similarType,
        "similar_jump_url": similarJumpUrl,
        "similar_jump_param": similarJumpParam,
        "similar_type_name": similarTypeName,
        "similar_type_bgcolor": similarTypeBgcolor,
        "use_time": useTime,
        "withdraw_money": withdrawMoney,
        "withdraw_money_tip": withdrawMoneyTip,
      };
}
