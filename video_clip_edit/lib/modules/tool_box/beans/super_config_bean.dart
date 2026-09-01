import 'dart:convert';

class SuperConfigBean {
  ListClass list;

  SuperConfigBean({
    required this.list,
  });

  SuperConfigBean copyWith({
    ListClass? list,
  }) =>
      SuperConfigBean(
        list: list ?? this.list,
      );

  factory SuperConfigBean.fromRawJson(String str) =>
      SuperConfigBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SuperConfigBean.fromJson(Map<String, dynamic> json) =>
      SuperConfigBean(
        list: ListClass.fromJson(json["list"]),
      );

  Map<String, dynamic> toJson() => {
        "list": list.toJson(),
      };
}

class ListClass {
  Kfurl kfurl;
  HomeRightFloatIcon? homeRightFloatIcon;
  HomeRightFloatIcon myConterBanner;
  SpreadDivide spreadDivide;

  ListClass({
    required this.kfurl,
    this.homeRightFloatIcon,
    required this.myConterBanner,
    required this.spreadDivide,
  });

  ListClass copyWith({
    Kfurl? kfurl,
    HomeRightFloatIcon? homeRightFloatIcon,
    HomeRightFloatIcon? myConterBanner,
    SpreadDivide? spreadDivide,
  }) =>
      ListClass(
        kfurl: kfurl ?? this.kfurl,
        homeRightFloatIcon: homeRightFloatIcon ?? this.homeRightFloatIcon,
        myConterBanner: myConterBanner ?? this.myConterBanner,
        spreadDivide: spreadDivide ?? this.spreadDivide,
      );

  factory ListClass.fromRawJson(String str) =>
      ListClass.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ListClass.fromJson(Map<String, dynamic> json) => ListClass(
        kfurl: Kfurl.fromJson(json["kfurl"]),
        homeRightFloatIcon:
            HomeRightFloatIcon.fromJson(json["home_right_float_icon"]),
        myConterBanner: HomeRightFloatIcon.fromJson(json["my_conter_banner"]),
        spreadDivide: SpreadDivide.fromJson(json["spread_divide"]),
      );

  Map<String, dynamic> toJson() => {
        "kfurl": kfurl.toJson(),
        "home_right_float_icon": homeRightFloatIcon?.toJson(),
        "my_conter_banner": myConterBanner.toJson(),
        "spread_divide": spreadDivide.toJson(),
      };
}

class HomeRightFloatIcon {
  String icon;
  Url url;

  HomeRightFloatIcon({
    required this.icon,
    required this.url,
  });

  HomeRightFloatIcon copyWith({
    String? icon,
    Url? url,
  }) =>
      HomeRightFloatIcon(
        icon: icon ?? this.icon,
        url: url ?? this.url,
      );

  factory HomeRightFloatIcon.fromRawJson(String str) =>
      HomeRightFloatIcon.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HomeRightFloatIcon.fromJson(Map<String, dynamic> json) =>
      HomeRightFloatIcon(
        icon: json["icon"],
        url: Url.fromJson(json["url"]),
      );

  Map<String, dynamic> toJson() => {
        "icon": icon,
        "url": url.toJson(),
      };
}

class Url {
  int valType;
  String valText;

  Url({
    required this.valType,
    required this.valText,
  });

  Url copyWith({
    int? valType,
    String? valText,
  }) =>
      Url(
        valType: valType ?? this.valType,
        valText: valText ?? this.valText,
      );

  factory Url.fromRawJson(String str) => Url.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Url.fromJson(Map<String, dynamic> json) => Url(
        valType: json["val_type"],
        valText: json["val_text"],
      );

  Map<String, dynamic> toJson() => {
        "val_type": valType,
        "val_text": valText,
      };
}

class Kfurl {
  String url;

  Kfurl({
    required this.url,
  });

  Kfurl copyWith({
    String? url,
  }) =>
      Kfurl(
        url: url ?? this.url,
      );

  factory Kfurl.fromRawJson(String str) => Kfurl.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Kfurl.fromJson(Map<String, dynamic> json) => Kfurl(
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
      };
}

class SpreadDivide {
  String audits;

  SpreadDivide({
    required this.audits,
  });

  SpreadDivide copyWith({
    String? audits,
  }) =>
      SpreadDivide(
        audits: audits ?? this.audits,
      );

  factory SpreadDivide.fromRawJson(String str) =>
      SpreadDivide.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SpreadDivide.fromJson(Map<String, dynamic> json) => SpreadDivide(
        audits: json["audits"],
      );

  Map<String, dynamic> toJson() => {
        "audits": audits,
      };
}
