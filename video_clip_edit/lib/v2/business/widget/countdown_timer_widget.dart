import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///包含2位数毫秒的倒计时组件
class CountdownTimerWidget extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onFinished;
  final TextStyle? textStyle;

  const CountdownTimerWidget({
    super.key,
    required this.duration,
    this.onFinished,
    this.textStyle,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Duration _remaining;
  Timer? _timer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    const interval = Duration(milliseconds: 10); // 每 10ms 更新一次
    _timer = Timer.periodic(interval, (timer) {
      setState(() {
        if (_remaining > interval) {
          _remaining -= interval;
        } else {
          _remaining = Duration.zero;
          _timer?.cancel();
          if (!_finished) {
            _finished = true;
            widget.onFinished?.call();
          }
        }
      });
    });
  }

  String _formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final millis = (duration.inMilliseconds.remainder(1000) ~/ 10);

    final buffer = StringBuffer();
    if (hours > 0) buffer.write('${hours.toString().padLeft(2, '0')}:');
    if (hours > 0 || minutes > 0) {
      buffer.write('${minutes.toString().padLeft(2, '0')}:');
    }
    if (hours > 0 || minutes > 0 || seconds > 0) {
      buffer.write('${seconds.toString().padLeft(2, '0')}:');
    }
    buffer.write(millis.toString().padLeft(2, '0'));

    return buffer.toString();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTime(_remaining),
      style: widget.textStyle ??
          TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFFFC5F19),
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace'),
    );
  }
}

