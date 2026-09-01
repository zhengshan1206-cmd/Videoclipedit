import 'dart:convert';

class MineScoreOrderBean {
  String id;
  String pay;
  Info info;
  String amount;

  MineScoreOrderBean({
    required this.id,
    required this.pay,
    required this.info,
    required this.amount,
  });

  MineScoreOrderBean copyWith({
    String? id,
    String? pay,
    Info? info,
    String? amount,
  }) =>
      MineScoreOrderBean(
        id: id ?? this.id,
        pay: pay ?? this.pay,
        info: info ?? this.info,
        amount: amount ?? this.amount,
      );

  factory MineScoreOrderBean.fromRawJson(String str) =>
      MineScoreOrderBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MineScoreOrderBean.fromJson(Map<String, dynamic> json) =>
      MineScoreOrderBean(
        id: json["id"],
        pay: json["pay"],
        info: Info.fromJson(json["info"]),
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "pay": pay,
        "info": info.toJson(),
        "amount": amount,
      };
}

class Info {
  String appid;
  String partnerid;
  String prepayid;
  String package;
  String noncestr;
  String timestamp;
  String sign;
  String packageValue;

  Info({
    required this.appid,
    required this.partnerid,
    required this.prepayid,
    required this.package,
    required this.noncestr,
    required this.timestamp,
    required this.sign,
    required this.packageValue,
  });

  Info copyWith({
    String? appid,
    String? partnerid,
    String? prepayid,
    String? package,
    String? noncestr,
    String? timestamp,
    String? sign,
    String? packageValue,
  }) =>
      Info(
        appid: appid ?? this.appid,
        partnerid: partnerid ?? this.partnerid,
        prepayid: prepayid ?? this.prepayid,
        package: package ?? this.package,
        noncestr: noncestr ?? this.noncestr,
        timestamp: timestamp ?? this.timestamp,
        sign: sign ?? this.sign,
        packageValue: packageValue ?? this.packageValue,
      );

  factory Info.fromRawJson(String str) => Info.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Info.fromJson(Map<String, dynamic> json) => Info(
        appid: json["appid"] ?? "",
        partnerid: json["partnerid"] ?? "",
        prepayid: json["prepayid"] ?? "",
        package: json["package"] ?? "",
        noncestr: json["noncestr"] ?? "",
        timestamp: json["timestamp"] ?? "0",
        sign: json["sign"] ?? "",
        packageValue: json["packageValue"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "appid": appid,
        "partnerid": partnerid,
        "prepayid": prepayid,
        "package": package,
        "noncestr": noncestr,
        "timestamp": timestamp,
        "sign": sign,
        "packageValue": packageValue,
      };
}
