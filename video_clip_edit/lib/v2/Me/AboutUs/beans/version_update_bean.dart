/*
 * @Author: cold-x
 * @Date: 2025-05-15 16:49:21
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-05-15 16:57:13
 * @FilePath: /video_clip_edit/lib/v2/Me/AboutUs/beans/version_update_bean.dart
 * @Description: 版本更新数据
 */

import 'dart:convert';

class VersionUpdateBean {
  String version;  //商店版本号
  String content; //更新内容
  String url;  //下载地址
  bool isShowUpdate; //是否显示更新
  bool isForceUpdate;   //是否强制更新

  VersionUpdateBean({
    required this.version,
    required this.content,
    required this.url,
    required this.isShowUpdate,
    required this.isForceUpdate,
  });

  VersionUpdateBean copyWith({
    String? version,
    String? content,
    String? url,
    bool? isShowUpdate,
    bool? isForceUpdate,
  }) =>
      VersionUpdateBean(
        version: version ?? this.version,
        content: content ?? this.content,
        url: url ?? this.url,
        isShowUpdate: isShowUpdate ?? this.isShowUpdate,
        isForceUpdate: isForceUpdate ?? this.isForceUpdate,
      );

  factory VersionUpdateBean.fromRawJson(String str) =>
      VersionUpdateBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VersionUpdateBean.fromJson(Map<String, dynamic> json) =>
      VersionUpdateBean(
        version: json["version"],
        content: json["updateContent"],
        url: json["updateUrl"],
        isShowUpdate: json["isShowUpdate"],
        isForceUpdate: json["isForceUpdate"],
      );

  Map<String, dynamic> toJson() => {
        "version": version,
        "content": content,
        "updateUrl": url,
        "isShowUpdate": isShowUpdate,
        "isForceUpdate": isForceUpdate,
      };
}