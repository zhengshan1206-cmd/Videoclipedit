import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/v2/minorMode/controllers/minor_mode_controller.dart';
import 'package:video_clip_edit/v2/minorMode/minor_mode_navigation_guard.dart';

/// 未成年人模式 UI 辅助，统一控制受限状态下的展示。
class MinorModeUi {
  MinorModeUi._();

  static bool get isRestricted => MinorModeController.to.isMinorModeEnabled;

  static Widget hideWhenRestricted(Widget child) {
    return Obx(() => isRestricted ? const SizedBox.shrink() : child);
  }

  static Widget showWhenRestricted(Widget child) {
    return Obx(() => isRestricted ? child : const SizedBox.shrink());
  }

  /// 禁用时段或使用时长超限时拦截首页列表跳转，返回 true 表示已拦截。
  static bool interceptHomeNavigation([BuildContext? context]) {
    return MinorModeNavigationGuard.interceptIfNeeded();
  }

  static void runHomeNavigation(BuildContext context, VoidCallback action) {
    if (interceptHomeNavigation(context)) return;
    action();
  }
}
