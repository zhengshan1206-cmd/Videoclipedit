import 'dart:convert';

enum PromotionCategoryType {
  others,
  hotPlays,
  hotNovel,
  folkStory,
  comicDrama;

  static PromotionCategoryType fromId(int id) {
    switch (id) {
      case 1:
        return PromotionCategoryType.hotPlays;
      case 2:
        return PromotionCategoryType.hotNovel;
      case 3:
        return PromotionCategoryType.folkStory;
      case 4:
        return PromotionCategoryType.comicDrama;
      default:
        throw ArgumentError('Invalid promotion category type id: $id');
    }
  }
}

class PromotionCategoryBean {
  int id;
  String title;
  String icon;

  PromotionCategoryBean({
    required this.id,
    required this.title,
    required this.icon,
  });

  PromotionCategoryBean copyWith({
    int? id,
    String? title,
    String? icon,
  }) =>
      PromotionCategoryBean(
        id: id ?? this.id,
        title: title ?? this.title,
        icon: icon ?? this.icon,
      );

  factory PromotionCategoryBean.fromRawJson(String str) =>
      PromotionCategoryBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PromotionCategoryBean.fromJson(Map<String, dynamic> json) =>
      PromotionCategoryBean(
        id: json["id"],
        title: json["title"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "icon": icon,
      };
}
