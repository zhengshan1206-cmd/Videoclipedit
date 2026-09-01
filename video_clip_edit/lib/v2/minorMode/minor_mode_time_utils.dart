/// 未成年人模式时间工具：禁用时段按北京时间（UTC+8）与服务器配置对齐。
class MinorModeTimeUtils {
  MinorModeTimeUtils._();

  static const Duration _chinaOffset = Duration(hours: 8);

  /// 当前北京时间，用于禁用时段、每日使用时长统计。
  static DateTime chinaNow() {
    return DateTime.now().toUtc().add(_chinaOffset);
  }

  static String formatDateKey(DateTime time) {
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    return '${time.year}-$month-$day';
  }

  static String formatDateTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '${formatDateKey(time)} $h:$m:$s';
  }
}
