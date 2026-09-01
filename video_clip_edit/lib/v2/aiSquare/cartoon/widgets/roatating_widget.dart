import 'dart:math';
import 'package:flutter/material.dart';

class RotatingWidget extends StatefulWidget {
  const RotatingWidget({
    super.key,
    this.duration,
    this.child,
  });

  final int? duration;
  final Widget? child;
  @override
  _RotatingWidgetState createState() => _RotatingWidgetState();
}

class _RotatingWidgetState extends State<RotatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration ?? 1),
    )..repeat(); // 动画重复
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * pi, // 2 * pi * controller.value
            child: child,
          );
        },

        child: widget.child, // 你可以替换成任意 Widget
      ),
    );
  }
}
