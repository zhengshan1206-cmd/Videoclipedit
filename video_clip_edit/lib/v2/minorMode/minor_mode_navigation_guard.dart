import 'package:flutter/foundation.dart';
import 'package:video_clip_edit/v2/minorMode/minor_mode_time_utils.dart';
import 'package:video_clip_edit/v2/minorMode/controllers/minor_mode_controller.dart';
import 'package:video_clip_edit/v2/minorMode/widgets/minor_mode_disabled_period_dialog.dart';

/// 未成年人模式导航拦截（独立文件，避免与 by_common_utils 循环依赖）。
class MinorModeNavigationGuard {
  MinorModeNavigationGuard._();

  /// 需要拦截时弹窗并返回 true。
  static bool interceptIfNeeded() {
    final controller = MinorModeController.to;
    final reason = controller.blockReason;
    if (reason == null) {
      if (kDebugMode && controller.isMinorModeEnabled) {
        final china = MinorModeTimeUtils.chinaNow();
        debugPrint(
          'minorModeBlock skip: disabledPeriod=${controller.isInDisabledPeriodNow}, '
          'usageExceeded=${controller.isUsageTimeExceeded}, '
          'isEnable=${controller.info.value?.unifiedTimeLimit?.isEnable}, '
          'period=${controller.info.value?.unifiedTimeLimit?.disabledPeriodText}, '
          'chinaNow=${MinorModeTimeUtils.formatDateTime(china)}, '
          'localNow=${DateTime.now()}',
        );
      }
      return false;
    }
    MinorModeDisabledPeriodDialog.show(reason: reason);
    return true;
  }
}
