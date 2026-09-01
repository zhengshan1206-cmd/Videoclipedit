

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';

class ToastUtil {
  static final ToastUtil _instance = ToastUtil._internal();
  factory ToastUtil() => _instance;
  ToastUtil._internal();

  DateTime? _lastShowTime;

  void showToast(String msg) {
    final now = DateTime.now();
    // 检查是否距离上次显示超过10秒
    if (_lastShowTime == null || now.difference(_lastShowTime!) > const Duration(seconds: 7)) {
      _lastShowTime = now;
      Get.log("弹窗提示=== ");
      BotToast.showText(text: msg);
    }
  }
}