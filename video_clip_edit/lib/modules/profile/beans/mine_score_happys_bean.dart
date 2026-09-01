import 'dart:convert';

class MineScoreHappysBean {
  List<Item> items;
  Pays pays;

  MineScoreHappysBean({
    required this.items,
    required this.pays,
  });

  MineScoreHappysBean copyWith({
    List<Item>? items,
    Pays? pays,
  }) =>
      MineScoreHappysBean(
        items: items ?? this.items,
        pays: pays ?? this.pays,
      );

  factory MineScoreHappysBean.fromRawJson(String str) =>
      MineScoreHappysBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MineScoreHappysBean.fromJson(Map<String, dynamic> json) =>
      MineScoreHappysBean(
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        pays: Pays.fromJson(json["pays"]),
      );

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "pays": pays.toJson(),
      };
}

class Item {
  int id;
  String appleVipId;
  String money;
  String mark;
  int isDefault;
  String unitIntegralMoney;
  int integral;

  Item({
    required this.id,
    required this.appleVipId,
    required this.money,
    required this.mark,
    required this.isDefault,
    required this.unitIntegralMoney,
    required this.integral,
  });

  Item copyWith({
    int? id,
    String? appleVipId,
    String? money,
    String? mark,
    int? isDefault,
    String? unitIntegralMoney,
    int? integral,
  }) =>
      Item(
        id: id ?? this.id,
        appleVipId: appleVipId ?? this.appleVipId,
        money: money ?? this.money,
        mark: mark ?? this.mark,
        isDefault: isDefault ?? this.isDefault,
        unitIntegralMoney: unitIntegralMoney ?? this.unitIntegralMoney,
        integral: integral ?? this.integral,
      );

  factory Item.fromRawJson(String str) => Item.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        appleVipId: json["apple_vip_id"],
        money: json["money"],
        mark: json["mark"],
        isDefault: json["is_default"],
        unitIntegralMoney: json["unit_integral_money"],
        integral: json["integral"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "apple_vip_id": appleVipId,
        "money": money,
        "mark": mark,
        "is_default": isDefault,
        "unit_integral_money": unitIntegralMoney,
        "integral": integral,
      };
}

class Pays {
  int wxpay;
  int alipay;
  int yeepay;

  Pays({
    required this.wxpay,
    required this.alipay,
    required this.yeepay,
  });

  Pays copyWith({
    int? wxpay,
    int? alipay,
    int? yeepay,
  }) =>
      Pays(
        wxpay: wxpay ?? this.wxpay,
        alipay: alipay ?? this.alipay,
        yeepay: yeepay ?? this.yeepay,
      );

  factory Pays.fromRawJson(String str) => Pays.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Pays.fromJson(Map<String, dynamic> json) => Pays(
        wxpay: json["wxpay"],
        alipay: json["alipay"],
        yeepay: json["yeepay"],
      );

  Map<String, dynamic> toJson() => {
        "wxpay": wxpay,
        "alipay": alipay,
        "yeepay": yeepay,
      };
}
