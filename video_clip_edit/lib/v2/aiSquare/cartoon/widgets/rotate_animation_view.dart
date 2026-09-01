import 'package:flutter/material.dart';

class RotateAnimationView extends StatefulWidget {
  const RotateAnimationView({
    super.key,
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final void Function() onTap;

  @override
  State<RotateAnimationView> createState() => _RotateAnimationViewState();
}

class _RotateAnimationViewState extends State<RotateAnimationView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    // ..forward(
    //     from: 0,
    //   ).then((_) {
    //     // widget.onTap();
    //   });

    _rotationAnimation =
        Tween<double>(begin: 0.0, end: 360 * 3).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0).then((_) {
          widget.onTap();
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 3.14159 / 180,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
