import 'package:video_clip_edit/data/model/response/base_response_entity.dart';

/// position : [{"id":1,"desc":"底部"},{"id":2,"desc":"中部"},{"id":3,"desc":"顶部"},{"id":0,"desc":"不需要"}]
/// style : [{"id":1,"icon":""},{"id":2,"icon":""},{"id":3,"icon":""},{"id":4,"icon":""},{"id":5,"icon":""},{"id":6,"icon":""},{"id":7,"icon":""}]
/// font_type : [{"id":2,"title":"普惠体","url":"https://gamecdn.beiyinapp.com/2024-11-14/sys/dd575db2a3c346654c8b1414f8fa4745.png"},{"id":6,"title":"数黑体","url":"https://gamecdn.beiyinapp.com/2024-11-14/sys/c6f1fa0adb9d7b60994fe498f446010f.png"},{"id":8,"title":"思源黑体","url":"https://gamecdn.beiyinapp.com/2024-11-14/sys/4b8677cc34babe09913a2a6ab3447f53.png"},{"id":7,"title":"进步体","url":"https://gamecdn.beiyinapp.com/2024-11-14/sys/b7572897b6cb53f3d99f186dd3a2059f.png"},{"id":1,"title":"高端黑","url":"https://gamecdn.beiyinapp.com/2024-11-14/sys/d053af512425d9f1fecd1ba23c286501.png"},{"id":9,"title":"未来圆","url":"https://gamecdn.beiyinapp.com/2024-11-14/sys/150129b3d84e895be363d5f70400a267.png"},{"id":4,"title":"东方大楷","url":"https://gamecdn.beiyinapp.com/2024-11-14/sys/9c885fdbefc362bbe0fbad72d613563a.png"},{"id":3,"title":"刀隶体","url":"https://gamecdn.beiyinapp.com/2024-11-14/sys/c8a3acff7c004748d349202e348f586f.png"}]

class AiCreateCaptionsConfigBean extends BaseData {
  List<Position>? position;
  List<Style>? style;
  List<FontType>? fontType;

  AiCreateCaptionsConfigBean({
    this.position,
    this.style,
    this.fontType,
  });

  @override
  AiCreateCaptionsConfigBean.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      position = json['position'] == null
          ? null
          : List.from(json['position'])
          .map((e) => Position.fromJson(e))
          .toList();
      style = json['style'] == null
          ? null
          : List.from(json['style'])
          .map((e) => Style.fromJson(e))
          .toList();
      fontType = json['font_type'] == null
          ? null
          : List.from(json['font_type'])
          .map((e) => FontType.fromJson(e))
          .toList();
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['position'] = position?.map((e) => e.toJson()).toList();
    data['style'] = style?.map((e) => e.toJson()).toList();
    data['font_type'] = fontType?.map((e) => e.toJson()).toList();
    return data;
  }

}

/// id : 2
/// title : "普惠体"
/// url : "https://gamecdn.beiyinapp.com/2024-11-14/sys/dd575db2a3c346654c8b1414f8fa4745.png"

class FontType extends BaseData {

  num? id;
  String? title;
  String? url;

  FontType({
    this.id,
    this.title,
    this.url,
  });

  @override
  FontType.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      id = json['id'];
      title = json['title'];
      url = json['url'];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['url'] = url;
    return data;
  }
}

/// id : 1
/// icon : ""

class Style extends BaseData {

  num? id;
  String? icon;
  String? title;

  Style({
    this.id,
    this.icon,
    this.title,
  });

  @override
  Style.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      id = json['id'];
      icon = json['icon'];
      title = json['title'];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['icon'] = icon;
    data['title'] = title;
    return data;
  }
}

/// id : 1
/// desc : "底部"

class Position extends BaseData{

  num? id;
  String? desc;

  Position({
    this.id,
    this.desc,
  });

  @override
  Position.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      id = json['id'];
      desc = json['desc'];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['desc'] = desc;
    return data;
  }
}