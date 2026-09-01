import 'package:video_clip_edit/data/model/response/base_response_entity.dart';

/// id : 1
/// title : "都市言情"
/// url : "https://inchatcdn.beiyinapp.com/inchat/ai/2024/11/29/hanman_sample.png"

class AICreatePictureStyleBean extends BaseData {
  num? id;
  String? title;
  String? url;
  List<Case>? cases;

  AICreatePictureStyleBean({
    this.id,
    this.title,
    this.url,
    this.cases,
  });

  @override
  AICreatePictureStyleBean.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      id = json['id'];
      title = json['title'];
      url = json['url'];
      cases = json['cases'] == null
          ? null
          : List.from(json['cases'])
          .map((e) => Case.fromJson(e))
          .toList();
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['url'] = url;
    data['cases'] = cases?.map((e) => e.toJson()).toList();
    return data;
  }
}

class Case extends BaseData {

  String? url;
  String? ratio;

  Case({
    this.url,
    this.ratio,
  });

  @override
  Case.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      url = json['url'];
      ratio = json['ratio'];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['ratio'] = ratio;
    return data;
  }

}