import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/erase/beans/point_bean.dart';
import 'package:video_clip_edit/modules/home/erase/widgets/custom_painter.dart';
import 'package:video_clip_edit/modules/home/providers/video_erase_provider.dart';

class DrawableWidget extends StatefulWidget {
  const DrawableWidget({
    super.key,
    required this.child,
  });
  final Widget child;
  @override
  State<DrawableWidget> createState() => _DrawableWidgetState();
}

class _DrawableWidgetState extends State<DrawableWidget> {
  List<PointBean?> points = [];
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: GestureDetector(
            onPanUpdate: (details) {
              VideoEraseProvider p = context.read<VideoEraseProvider>();
              double? width = p.selectBean?.penSize;
              RenderBox renderBox = context.findRenderObject() as RenderBox;

              if (mounted) {
                setState(() {
                  points.add(PointBean(
                      strokeWidth: width ?? 0.0,
                      offset: renderBox.globalToLocal(details.globalPosition)));
                });
              }
            },
            onPanEnd: (details) {
              if (mounted) setState(() => points.add(null));
            },
            child: Consumer(
              builder: (c, p, child) {
                return CustomPaint(
                  painter: PathPainter(points),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
