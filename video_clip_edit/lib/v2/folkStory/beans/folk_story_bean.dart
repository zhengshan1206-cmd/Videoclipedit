/*
 * @Author: cold-x
 * @Date: 2025-04-27 13:55:16
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-05-08 15:40:59
 * @FilePath: /video_clip_edit/lib/v2/folkStory/beans/folk_story_bean.dart
 * @Description: 民间故事主题数据模型
 */
import 'dart:convert';


class FolkStoryThemeBean {
  String id;
  String title; //标题
  String themeColor;  //主题色
  String module;
  String bgImage;   //背景色
  String buttonColor;  //按钮色
  String bgmID;

  FolkStoryThemeBean({
    required this.id,
    required this.title,
    required this.themeColor,
    required this.module,
    required this.bgImage,
    required this.buttonColor,
    required this.bgmID,
  });

  FolkStoryThemeBean copyWith({
    String? id,
    String? title,
    String? themeColor,
    String? module,
    String? bgImage,
    String? buttonColor,
    String? bgmID,
  }) =>
      FolkStoryThemeBean(
        id: id ?? this.id,
        title: title ?? this.title,
        themeColor: themeColor ?? this.themeColor,
        module: module ?? this.module,
        bgImage: bgImage ?? this.bgImage,
        buttonColor: buttonColor ?? this.buttonColor,
        bgmID: bgmID ?? this.bgmID,
      );

  factory FolkStoryThemeBean.fromRawJson(String str) =>
      FolkStoryThemeBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FolkStoryThemeBean.fromJson(Map<String, dynamic> json) =>
      FolkStoryThemeBean(
        id: '${json["id"]}',
        title: json["title"],
        themeColor: json["theme_color"],
        module: json["module"],
        bgImage: json["bg_img"] ?? "",
        buttonColor: json["button_color"],
        bgmID: '${json["bgm_type_id"]}',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "theme_color": themeColor,
        "module": module,
        "bg_img": bgImage,
        "button_color": buttonColor,
        "bgm_type_id": bgmID,
      };
}
