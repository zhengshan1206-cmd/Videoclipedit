import 'dart:convert';

class AiCartoonVideoModeBean {
  String title;
  String tag;
  String desc;
  bool selected;
  String selectedColor;
  String selectedIcon;

  AiCartoonVideoModeBean({
    required this.title,
    required this.tag,
    required this.desc,
    required this.selected,
    required this.selectedColor,
    required this.selectedIcon,
  });

  AiCartoonVideoModeBean copyWith({
    String? title,
    String? tag,
    String? desc,
    bool? selected,
    String? selectedColor,
    String? selectedIcon,
  }) =>
      AiCartoonVideoModeBean(
        title: title ?? this.title,
        tag: tag ?? this.tag,
        desc: desc ?? this.desc,
        selected: selected ?? this.selected,
        selectedColor: selectedColor ?? this.selectedColor,
        selectedIcon: selectedIcon ?? this.selectedIcon,
      );

  factory AiCartoonVideoModeBean.fromRawJson(String str) =>
      AiCartoonVideoModeBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiCartoonVideoModeBean.fromJson(Map<String, dynamic> json) =>
      AiCartoonVideoModeBean(
        title: json["title"],
        tag: json["tag"],
        desc: json["desc"],
        selected: json["selected"],
        selectedColor: json["selectedColor"],
        selectedIcon: json["selectedIcon"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "tag": tag,
        "desc": desc,
        "selected": selected,
        "selectedColor": selectedColor,
        "selectedIcon": selectedIcon,
      };
}
