/*
 * @Author: cold-x
 * @Date: 2025-05-16 09:28:22
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-05-20 19:06:27
 * @FilePath: /video_clip_edit/lib/utils/push/push_bean.dart
 * @Description: 
 */
import 'dart:convert';

class PushBean {
  String url;  //链接或者路由名
  dynamic args; //参数信息
  String type;  //推送类型

  PushBean({
    required this.args,
    required this.type,
    required this.url,
  });

  PushBean copyWith({
    String? type,
    dynamic? args,
    String? url,
  }) =>
      PushBean(
        type: type ?? this.type,
        args: args ?? this.args,
        url: url ?? this.url,
      );

  factory PushBean.fromRawJson(String str) =>
      PushBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PushBean.fromJson(Map<String, dynamic> json) =>
      PushBean(
        type:  '${json["jump_to_type"]}',
        args: json["jump_to_id"] ?? "",
        url: json["jump_to_url"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "jump_to_type": type,
        "jump_to_id": args,
        "jump_to_url": url,
      };
}