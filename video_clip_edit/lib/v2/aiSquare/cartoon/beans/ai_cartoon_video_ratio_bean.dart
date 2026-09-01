import 'dart:convert';

class AiCartoonVideoRatioBean {
  int id;
  String scale;

  AiCartoonVideoRatioBean({
    required this.id,
    required this.scale,
  });

  AiCartoonVideoRatioBean copyWith({
    int? id,
    String? scale,
  }) =>
      AiCartoonVideoRatioBean(
        id: id ?? this.id,
        scale: scale ?? this.scale,
      );

  factory AiCartoonVideoRatioBean.fromRawJson(String str) =>
      AiCartoonVideoRatioBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiCartoonVideoRatioBean.fromJson(Map<String, dynamic> json) =>
      AiCartoonVideoRatioBean(
        id: json["id"],
        scale: json["scale"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "scale": scale,
      };
}
