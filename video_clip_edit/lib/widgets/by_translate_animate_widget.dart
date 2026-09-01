import 'package:flutter/material.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';

class ByTranslateAnimateWidget extends StatefulWidget {
  final Widget child;
  const ByTranslateAnimateWidget({
    super.key,
    required this.child,
  });

  @override
  State<ByTranslateAnimateWidget> createState() =>
      _ByTranslateAnimateWidgetState();
}

class _ByTranslateAnimateWidgetState extends State<ByTranslateAnimateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  @override
  void initState() {
    byDebugPrint("initState...", tag: "Translate:");
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: false);

    _animation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // 图片初始位置（右边界外）
      end: const Offset(-1.0, 0.0), // 图片结束位置（左边界外）
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    byDebugPrint("dispose...", tag: "Translate:");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return AnimatedBuilder(
    //   animation: _controller,
    //   builder: (context, child) {
    //     return Transform.translate(
    //       offset: Offset(
    //         -_controller.value * MediaQuery.of(context).size.width,
    //         0,
    //       ),
    //       child: widget.child,
    //       // child: Row(
    //       //   children: [
    //       //     widget.child,
    //       //     widget.child,
    //       //     widget.child,
    //       //   ],
    //       // ),
    //     );
    //   },
    // );
    return SlideTransition(
      position: _animation,
      child: widget.child,
      // child: SizedBox(
      //   width: MediaQuery.of(context).size.width * 2,
      //   child: Row(
      //     children: [
      //       widget.child,
      //       widget.child
      //       // Image.asset(
      //       //   "assets/home/voice_input_wave.png",
      //       //   width: MediaQuery.of(context).size.width,
      //       //   fit: BoxFit.fitWidth,
      //       // ),
      //     ],
      //   ),
      // ),
    );
  }
}
