// To parse this JSON data, do
//
//     final assitantPageInfoBean = assitantPageInfoBeanFromJson(jsonString);

import 'dart:convert';

enum ItemType {
  /// 数字类型
  number,

  /// 文本输入类型
  text,

  /// 选项
  items,
}

extension ItemTypeExt on ItemType {
  String get rawValue {
    // values
    switch (this) {
      case ItemType.text:
        return "text";
      case ItemType.number:
        return "number";
      case ItemType.items:
        return "items";
      default:
        return "text";
    }
  }

  static ItemType typeFromRawValue(String rawVal) {
    // values
    switch (rawVal) {
      case "text":
        return ItemType.text;
      case "number":
        return ItemType.number;
      case "items":
        return ItemType.items;
      default:
        return ItemType.text;
    }
  }
}

AssitantPageInfoBean assitantPageInfoBeanFromJson(String str) =>
    AssitantPageInfoBean.fromJson(json.decode(str));

String assitantPageInfoBeanToJson(AssitantPageInfoBean data) =>
    json.encode(data.toJson());

class AssitantPageInfoBean {
  String templateName;
  List<String> template;
  List<Item> items;

  AssitantPageInfoBean({
    required this.templateName,
    required this.template,
    required this.items,
  });

  factory AssitantPageInfoBean.fromJson(Map<String, dynamic> json) =>
      AssitantPageInfoBean(
        templateName: json["template_name"],
        template: List<String>.from(json["template"].map((x) => x)),
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "template_name": templateName,
        "template": List<dynamic>.from(template.map((x) => x)),
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };

  editInfo() {
    Map<String, dynamic> res = {};
    for (var e in items) {
      if (e.type == ItemType.items) {
        res[e.id] = e.selectedValue;
      } else {
        res[e.id] = e.value;
      }
    }
    return res;
  }

  String? validate() {
    for (var element in items) {
      if (element.isRequisite == 1 && !element.finished()) {
        final isItems = element.type == ItemType.items;
        return isItems ? "请选择${element.title}" : "请填写${element.title}";
      }
    }
    return null;
  }
}

class Item {
  String id;
  String title;
  int isRequisite;
  String? selectedValue;
  String itemDes;
  ItemType type;
  List<String>? items;
  int? itemMaxSize;
  int? itemMinSize;
  String? value;
  int? itemMax;
  int? itemMin;

  Item({
    required this.id,
    required this.title,
    required this.isRequisite,
    this.selectedValue,
    required this.itemDes,
    required this.type,
    this.items,
    this.itemMaxSize,
    this.itemMinSize,
    this.value,
    this.itemMax,
    this.itemMin,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        title: json["title"],
        isRequisite: json["is_requisite"],
        selectedValue: json["selectedValue"],
        itemDes: json["item_des"],
        type: ItemTypeExt.typeFromRawValue(json["type"]),
        items: json["items"] == null
            ? []
            : List<String>.from(json["items"]!.map((x) => x)),
        itemMaxSize: json["item_max_size"],
        itemMinSize: json["item_min_size"],
        value: json["value"],
        itemMax: json["item_max"],
        itemMin: json["item_min"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "is_requisite": isRequisite,
        "selectedValue": selectedValue,
        "item_des": itemDes,
        "type": type.rawValue,
        "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x)),
        "item_max_size": itemMaxSize,
        "item_min_size": itemMinSize,
        "value": value,
        "item_max": itemMax,
        "item_min": itemMin,
      };

  updateUserValue(String val) {
    switch (type) {
      case ItemType.items:
        selectedValue = val;
        break;
      default:
        value = val;
    }
  }

  bool finished() {
    if (type == ItemType.items) {
      return selectedValue != null && selectedValue!.isNotEmpty;
    }
    return value != null && value!.isNotEmpty;
  }
}
