import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:video_clip_edit/data/model/response/base_response_entity.dart';

@JsonSerializable()
class UserWorksData extends BaseData {
  //APPLEID,GOOGLE,DEVICE,WECHAT
  String? name;
  num? value;
  @JsonKey(name: 'jump_url')
  String? jumpUrl;
  @JsonKey(name: 'jump_param')
  String? jumpParam;

  UserWorksData({
    this.name,
    this.value,
    this.jumpUrl,
    this.jumpParam,
  });

  @override
  UserWorksData.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      name = json['name'];
      value = json['value'];
      jumpUrl = json['jump_url'];
      jumpParam = json['jump_param'];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['value'] = value;
    data['jump_url'] = jumpUrl;
    data['jump_param'] = jumpParam;
    return data;
  }
}
