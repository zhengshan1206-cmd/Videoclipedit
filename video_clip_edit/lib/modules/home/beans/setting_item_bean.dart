// To parse this JSON data, do
//
//     final settingItemBean = settingItemBeanFromJson(jsonString);

import 'dart:convert';

// SettingItemBean settingItemBeanFromJson(String str) =>
//     SettingItemBean.fromJson(json.decode(str));

// String settingItemBeanToJson(SettingItemBean data) =>
//     json.encode(data.toJson());

// class SettingItemBean {
//   String title;
//   String? desc;
//   bool interactive;
//   bool? isAvatar;
//   bool? canCopy;

//   SettingItemBean({
//     required this.title,
//     this.desc,
//     required this.interactive,
//     this.isAvatar = false,
//     this.canCopy = false,
//   });

//   factory SettingItemBean.fromJson(Map<String, dynamic> json) =>
//       SettingItemBean(
//         title: json["title"],
//         desc: json["desc"],
//         interactive: json["interactive"],
//         isAvatar: json["isAvatar"] ?? false,
//         canCopy: json["canCopy"] ?? false,
//       );

//   Map<String, dynamic> toJson() => {
//         "title": title,
//         "desc": desc,
//         "interactive": interactive,
//         "isAvatar": isAvatar,
//         "canCopy": canCopy,
//       };
// }
// To parse this JSON data, do
//
//     final settingItemBean = settingItemBeanFromJson(jsonString);

SettingItemBean settingItemBeanFromJson(String str) =>
    SettingItemBean.fromJson(json.decode(str));

String settingItemBeanToJson(SettingItemBean data) =>
    json.encode(data.toJson());

class SettingItemBean {
  String title;
  String url;
  String? imgUrl;
  String? pagePath;
  String? desc;
  bool interactive;
  bool? isAvatar;
  bool? canCopy;

  SettingItemBean({
    required this.title,
    required this.url,
    required this.imgUrl,
    required this.pagePath,
    required this.desc,
    required this.interactive,
    required this.isAvatar,
    required this.canCopy,
  });

  factory SettingItemBean.fromJson(Map<String, dynamic> json) =>
      SettingItemBean(
        title: json["title"],
        url: json["url"],
        imgUrl: json["imgUrl"],
        pagePath: json["page_path"],
        desc: json["desc"] ?? "",
        interactive: json["interactive"] ?? true,
        isAvatar: json["isAvatar"] ?? false,
        canCopy: json["canCopy"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "url": url,
        "imgUrl": imgUrl,
        "page_path": pagePath,
        "desc": desc,
        "interactive": interactive,
        "isAvatar": isAvatar,
        "canCopy": canCopy,
      };
}
