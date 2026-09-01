// To parse this JSON data, do
//
//     final purchaseFunctionBean = purchaseFunctionBeanFromJson(jsonString);

import 'dart:convert';

PurchaseFunctionBean purchaseFunctionBeanFromJson(String str) =>
    PurchaseFunctionBean.fromJson(json.decode(str));

String purchaseFunctionBeanToJson(PurchaseFunctionBean data) =>
    json.encode(data.toJson());

class PurchaseFunctionBean {
  String icon;
  String name;
  bool isNew;
  bool selected;

  PurchaseFunctionBean({
    required this.icon,
    required this.name,
    required this.isNew,
    required this.selected,
  });

  factory PurchaseFunctionBean.fromJson(Map<String, dynamic> json) =>
      PurchaseFunctionBean(
        icon: json["icon"],
        name: json["name"],
        isNew: json["isNew"],
        selected: json["selected"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "icon": icon,
        "name": name,
        "isNew": isNew,
        "selected": selected,
      };
}
