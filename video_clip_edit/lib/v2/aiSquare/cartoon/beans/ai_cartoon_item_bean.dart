import 'dart:convert';

enum AiCartoonItemBeanType {
  voice,
  ratio,
  bgm,
  font,
  settings,
}

class AiCartoonItemBean {
  String? value;
  String placeholder;
  String title;
  String imgPath;
  AiCartoonItemBeanType type;
  bool? shouldBold;
  bool? required;
  bool? hasHeader;
  bool? interactive;

  AiCartoonItemBean({
    required this.placeholder,
    required this.type,
    required this.imgPath,
    required this.title,
    this.value = "",
    this.shouldBold = false,
    this.required = false,
    this.hasHeader = true,
    this.interactive = true,
  });

  AiCartoonItemBean copyWith({
    String? value,
    AiCartoonItemBeanType? type,
    bool? shouldBold,
    String? placeholder,
    String? title,
    String? imgPath,
    bool? required,
    bool? hasHeader,
    bool? interactive,
  }) =>
      AiCartoonItemBean(
        value: value ?? this.value,
        type: type ?? this.type,
        shouldBold: shouldBold ?? this.shouldBold,
        placeholder: placeholder ?? this.placeholder,
        title: title ?? this.title,
        imgPath: imgPath ?? this.imgPath,
        required: required ?? this.required,
        hasHeader: hasHeader ?? this.hasHeader,
        interactive: interactive ?? this.interactive,
      );

  factory AiCartoonItemBean.fromRawJson(String str) =>
      AiCartoonItemBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiCartoonItemBean.fromJson(Map<String, dynamic> json) =>
      AiCartoonItemBean(
        value: json["value"],
        type: json["type"],
        shouldBold: json["shouldBold"],
        placeholder: json["placeholder"],
        title: json["title"],
        imgPath: json["imgPath"],
        required: json["required"],
        hasHeader: json["hasHeader"],
        interactive: true,
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "type": type,
        "shouldBold": shouldBold,
        "placeholder": placeholder,
        "title": title,
        "imgPath": imgPath,
        "required": required,
        "hasHeader": hasHeader,
        "interactive": interactive,
      };

  bool hasValue() {
    return (value ?? "").isNotEmpty;
  }
}
