import 'package:video_clip_edit/data/model/response/base_response_entity.dart';

class CommonNoticeBean extends BaseData {
  num? id;
  String? icon;
  int? type;
  String? content;

  CommonNoticeBean({
    this.id,
    this.icon,
    this.type,
    this.content,
  });

  @override
  CommonNoticeBean.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      id = json['id'];
      icon = json['icon'];
      type = json['type'];
      content = json['content'];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['icon'] = icon;
    data['type'] = type;
    data['content'] = content;
    return data;
  }
}