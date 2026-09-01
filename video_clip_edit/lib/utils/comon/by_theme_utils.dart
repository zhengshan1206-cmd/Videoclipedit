import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

/// 未使用
/// 主题配置在 lib/project/configs/colors.dart 和 lib/project/provider/theme_provider.dart
class ByThemeUtils {
  /// 暗黑模式判断
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// 暗黑模式判断
  static bool jhIsDark() {
    // final brightness = SchedulerBinding.instance.window.platformBrightness; // “window”已弃用
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return isDarkMode;
  }

  static Color? getDarkColor(BuildContext context, Color darkColor) {
    return isDark(context) ? darkColor : null;
  }

  static Color? getIconColor(BuildContext context) {
    return isDark(context) ? ByColorUtil.MainTextColor : null;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color getDialogBackgroundColor(BuildContext context) {
    return Theme.of(context).canvasColor;
  }

  static Color getStickyHeaderColor(BuildContext context) {
    return isDark(context)
        ? ByColorUtil.MainTextColor
        : ByColorUtil.MainTextColor;
  }

  static Color getDialogTextFieldColor(BuildContext context) {
    return isDark(context)
        ? ByColorUtil.MainTextColor
        : ByColorUtil.MainTextColor;
  }

  static Color? getKeyboardActionsColor(BuildContext context) {
    return isDark(context)
        ? ByColorUtil.MainTextColor
        : ByColorUtil.MainTextColor;
  }
}
