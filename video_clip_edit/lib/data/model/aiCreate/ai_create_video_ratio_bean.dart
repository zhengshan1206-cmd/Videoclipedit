import 'package:video_clip_edit/data/model/response/base_response_entity.dart';

class AiCreateVideoRatioBean extends BaseData {
  int? id;
  String? scale;

  AiCreateVideoRatioBean({
    this.id,
    this.scale,
  });

  @override
  AiCreateVideoRatioBean.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      id = json['id'];
      scale = json['scale'];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['scale'] = scale;
    return data;
  }
}
