import 'package:flutter/material.dart';
import 'package:video_clip_edit/modules/home/erase/beans/point_bean.dart';

class PathPainter extends CustomPainter {
  final List<PointBean?> points;
  PathPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.pink.withOpacity(0.5)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      Offset? offset = points[i]?.offset;
      Offset? offset1 = points[i + 1]?.offset;
      double? width = points[i]?.strokeWidth;
      double? width1 = points[i + 1]?.strokeWidth;

      if (offset != null &&
          offset1 != null &&
          width != null &&
          width1 != null) {
        if (width1 == width) {
          paint.strokeWidth = width;
          canvas.drawLine(offset, offset1, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) => true;
}
