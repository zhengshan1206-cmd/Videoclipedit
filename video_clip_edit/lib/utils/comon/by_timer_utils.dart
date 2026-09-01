import 'dart:async';
import 'package:flutter/material.dart';

/// 定时器工具类
class TimerUtil {
  Timer? _timer;
  final Duration duration;
  final VoidCallback callback;

  TimerUtil({
    required this.duration,
    required this.callback,
  });

  /// 开始定时器
  void start() {
    stop(); // 确保之前的定时器被停止
    _timer = Timer.periodic(duration, (timer) {
      callback();
    });
  }

  /// 停止定时器
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// 检查定时器是否正在运行
  bool get isRunning => _timer != null && _timer!.isActive;

  /// 销毁定时器
  void dispose() {
    stop();
  }
}

/// 在页面中使用示例：
/// 
/// class MyPage extends StatefulWidget {
///   @override
///   _MyPageState createState() => _MyPageState();
/// }
/// 
/// class _MyPageState extends State<MyPage> {
///   late TimerUtil _timerUtil;
/// 
///   @override
///   void initState() {
///     super.initState();
///     _timerUtil = TimerUtil(
///       duration: Duration(seconds: 5), // 每5秒执行一次
///       callback: () {
///         // 在这里执行需要定时刷新的操作
///         print('定时刷新执行');
///       },
///     );
///     _timerUtil.start();
///   }
/// 
///   @override
///   void dispose() {
///     _timerUtil.dispose();
///     super.dispose();
///   }
/// 
///   @override
///   Widget build(BuildContext context) {
///     return Container();
///   }
/// } 