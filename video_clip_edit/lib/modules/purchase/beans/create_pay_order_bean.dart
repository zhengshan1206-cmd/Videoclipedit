// To parse this JSON data, do
//
//     final createPayOrderBean = createPayOrderBeanFromJson(jsonString);

import 'dart:convert';

CreatePayOrderBean createPayOrderBeanFromJson(String str) =>
    CreatePayOrderBean.fromJson(json.decode(str));

String createPayOrderBeanToJson(CreatePayOrderBean data) =>
    json.encode(data.toJson());

class CreatePayOrderBean {
  String id;
  String pay;
  Info info;
  String amount;
  String callMethod;
  int isSubscribeH5;

  CreatePayOrderBean({
    required this.id,
    required this.pay,
    required this.info,
    required this.amount,
    required this.callMethod,
    required this.isSubscribeH5,
  });

  factory CreatePayOrderBean.fromJson(Map<String, dynamic> json) =>
      CreatePayOrderBean(
        id: json["id"],
        pay: json["pay"],
        info: Info.fromJson(json["info"]),
        amount: json["amount"],
        callMethod: json["call_method"],
        isSubscribeH5: json["is_subscribe_h5"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "pay": pay,
        "info": info.toJson(),
        "amount": amount,
        "call_method": callMethod,
        "is_subscribe_h5": isSubscribeH5,
      };
}

class Info {
  String prePayTn;
  String appId;
  String miniProgramPath;
  String miniProgramOrgId;

  Info({
    required this.prePayTn,
    required this.appId,
    required this.miniProgramPath,
    required this.miniProgramOrgId,
  });

  factory Info.fromJson(Map<String, dynamic> json) => Info(
        prePayTn: json["prePayTn"],
        appId: json["appId"],
        miniProgramPath: json["miniProgramPath"],
        miniProgramOrgId: json["miniProgramOrgId"],
      );

  Map<String, dynamic> toJson() => {
        "prePayTn": prePayTn,
        "appId": appId,
        "miniProgramPath": miniProgramPath,
        "miniProgramOrgId": miniProgramOrgId,
      };
}
