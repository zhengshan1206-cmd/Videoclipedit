import 'package:flutter/material.dart';

class RotateTransitionWidget extends StatefulWidget {
  final Widget child;
  const RotateTransitionWidget({
    super.key,
    required this.child,
  });

  @override
  State<RotateTransitionWidget> createState() => _RotateTransitionWidgetState();
}

class _RotateTransitionWidgetState extends State<RotateTransitionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..repeat(reverse: false);

    _animation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: widget.child,
    );
  }
}
