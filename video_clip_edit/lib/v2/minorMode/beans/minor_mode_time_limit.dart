class MinorModeTimeLimit {
  MinorModeTimeLimit({
    this.startTime,
    this.endTime,
    this.totalUseTime,
    this.weekday,
    this.isEnable,
  });

  static const String defaultStartTime = '06:00';
  static const String defaultEndTime = '22:00';
  static const String defaultPeriodText = '$defaultStartTime-$defaultEndTime';
  static const int defaultStartHour = 6;
  static const int defaultEndHour = 22;
  static const int defaultIsEnable = 1;

  final String? startTime;
  final String? endTime;
  final int? totalUseTime;
  final int? weekday;
  final int? isEnable;

  int get resolvedIsEnable => isEnable ?? defaultIsEnable;

  bool get hasDisabledPeriod {
    if (resolvedIsEnable != 1) return false;
    return startTime != null &&
        startTime!.isNotEmpty &&
        endTime != null &&
        endTime!.isNotEmpty;
  }

  String get resolvedStartTime =>
      (startTime != null && startTime!.isNotEmpty)
          ? startTime!
          : defaultStartTime;

  String get resolvedEndTime =>
      (endTime != null && endTime!.isNotEmpty) ? endTime! : defaultEndTime;

  String get disabledPeriodText =>
      hasDisabledPeriod ? '$startTime-$endTime' : defaultPeriodText;

  /// 接口下发的起止时间（不受 is_enable 影响，用于回显与提交）
  String get configuredPeriodText {
    final hasTimes = startTime != null &&
        startTime!.isNotEmpty &&
        endTime != null &&
        endTime!.isNotEmpty;
    if (!hasTimes) return defaultPeriodText;
    return '$startTime-$endTime';
  }

  bool get isDisabledPeriodEnabled => resolvedIsEnable == 1;

  /// 当前时刻是否处于禁用时段内（仅 is_enable=1 时生效，支持跨天）
  bool isDisabledPeriodActiveAt(DateTime moment) {
    if (resolvedIsEnable != 1) return false;

    final start = _parseTimeOfDay(resolvedStartTime);
    final end = _parseTimeOfDay(resolvedEndTime);
    if (start == null || end == null) return false;

    final currentMinutes = moment.hour * 60 + moment.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes == endMinutes) return false;

    if (startMinutes < endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }
    return currentMinutes >= startMinutes || currentMinutes < endMinutes;
  }

  static ({int hour, int minute})? _parseTimeOfDay(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return (hour: hour, minute: minute);
  }

  factory MinorModeTimeLimit.fromJson(Map<String, dynamic> json) {
    return MinorModeTimeLimit(
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      totalUseTime: _parseInt(json['total_use_time']),
      weekday: _parseInt(json['weekday'] ?? json['week_day']),
      isEnable: _parseInt(json['is_enable'] ?? json['isEnable']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (startTime != null) 'start_time': startTime,
        if (endTime != null) 'end_time': endTime,
        if (totalUseTime != null) 'total_use_time': totalUseTime,
        if (weekday != null) 'weekday': weekday,
        if (isEnable != null) 'is_enable': isEnable,
      };

  /// 提交 updateMinorModeTimeLimit 时使用
  Map<String, dynamic> toSubmitJson() => {
        'start_time': resolvedStartTime,
        'end_time': resolvedEndTime,
        'is_enable': resolvedIsEnable,
        'total_use_time': (totalUseTime ?? 40).toString(),
        if (weekday != null) 'weekday': weekday,
      };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is bool) return value ? 1 : 0;
    final text = value.toString().trim();
    if (text == 'true') return 1;
    if (text == 'false') return 0;
    return int.tryParse(text);
  }
}
