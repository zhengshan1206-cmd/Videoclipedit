// To parse this JSON data, do
//
//     final assisntItemBean = assisntItemBeanFromJson(jsonString);

import 'dart:convert';

enum AssisntItemType {
  /// 商品文案测评
  productReviewCopy,

  /// 电商海报文案
  eCommercePosterCopywriting,

  /// 爆款标题
  hotHeadlines,
}

extension AssisntItemTypeExt on AssisntItemType {
  /// 获取类型的原始值
  int get rawValue {
    switch (this) {
      case AssisntItemType.productReviewCopy:
        return 1;
      case AssisntItemType.eCommercePosterCopywriting:
        return 2;
      case AssisntItemType.hotHeadlines:
        return 3;
      default:
        return -1;
    }
  }

  /// 根据原始值获取对应的枚举类型
  static AssisntItemType typeWithRawValue(int val) {
    switch (val) {
      case 1:
        return AssisntItemType.productReviewCopy;
      case 2:
        return AssisntItemType.eCommercePosterCopywriting;
      case 3:
        return AssisntItemType.hotHeadlines;
      default:
        return AssisntItemType.productReviewCopy;
    }
  }
}

AssisntItemBean assisntItemBeanFromJson(String str) =>
    AssisntItemBean.fromJson(json.decode(str));

String assisntItemBeanToJson(AssisntItemBean data) =>
    json.encode(data.toJson());

class AssisntItemBean {
  String title;
  String hot;
  int type;

  AssisntItemBean({
    required this.title,
    required this.hot,
    required this.type,
  });

  factory AssisntItemBean.fromJson(Map<String, dynamic> json) =>
      AssisntItemBean(
        title: json["title"],
        hot: json["hot"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "hot": hot,
        "type": type,
      };
}
