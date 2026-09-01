import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

///礼物抖动动画
class ShakePauseGiftWidget extends StatefulWidget {
  final Widget child;

  const ShakePauseGiftWidget({super.key, required this.child});

  @override
  _ShakePauseGiftState createState() => _ShakePauseGiftState();
}

class _ShakePauseGiftState extends State<ShakePauseGiftWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isShaking = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // 一次抖动动画周期（快）
    );

    // 启动抖动循环
    startShakeLoop();
  }

  void startShakeLoop() async {
    while (mounted) {
      // 启动抖动动画：repeat 3 次
      setState(() => isShaking = true);
      for (int i = 0; i < 1; i++) {
        await _controller.forward();
        await _controller.reverse();
      }

      // 停顿一会
      setState(() => isShaking = false);
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        double dy = isShaking
            ? sin(_controller.value * pi * 2) * 4 // 抖动幅度6像素
            : 0; // 停止时归零
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class IntermittentShakingRedEnvelope extends StatefulWidget {
  final Widget child;
  final Duration shakeDuration; // 每次摇动动画的持续时间
  final Duration pauseDuration; // 每次摇完后的停顿时间

  const IntermittentShakingRedEnvelope({
    Key? key,
    required this.child,
    this.shakeDuration = const Duration(milliseconds: 600),
    this.pauseDuration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<IntermittentShakingRedEnvelope> createState() => _IntermittentShakingRedEnvelopeState();
}

class _IntermittentShakingRedEnvelopeState extends State<IntermittentShakingRedEnvelope>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _shakeTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.shakeDuration,
    );

    _animation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.8, end: 0.8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _startShakingLoop();
  }

  void _startShakingLoop() {
    _shakeOnce(); // 第一次开始摇

    _shakeTimer = Timer.periodic(
      widget.shakeDuration + widget.pauseDuration,
          (timer) {
        _shakeOnce();
      },
    );
  }

  void _shakeOnce() {
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _shakeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

