import 'dart:ui';

class PointBean {
  double strokeWidth = 0.0;

  Offset? offset;

  PointBean({
    required this.strokeWidth,
    required this.offset,
  });

  factory PointBean.fromJson(Map<String, dynamic> json) => PointBean(
        strokeWidth: json["strokeWidth"],
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "strokeWidth": strokeWidth,
        "offset": offset,
      };
}
