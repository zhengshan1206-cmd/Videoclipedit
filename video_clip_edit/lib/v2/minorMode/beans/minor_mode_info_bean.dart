import 'dart:convert';

import 'package:video_clip_edit/v2/minorMode/beans/minor_mode_time_limit.dart';
import 'package:video_clip_edit/v2/minorMode/beans/minor_page_type.dart';
import 'package:video_clip_edit/v2/minorMode/minor_mode_time_utils.dart';

class MinorModeInfoBean {
  MinorModeInfoBean({
    this.birthday,
    this.phone,
    this.passwordMd5,
    this.mode,
    this.status,
    this.unifiedTimeLimit,
    this.dailyTimeLimits,
  });

  final String? birthday;
  final String? phone;

  /// 家长密码 MD5（接口字段 p）
  final String? passwordMd5;

  /// 时间设置模式：1-统一时间设置，2-每日分别设置
  final int? mode;

  /// 未成年人模式开关：1-开启，2-关闭
  final int? status;

  final MinorModeTimeLimit? unifiedTimeLimit;
  final List<MinorModeTimeLimit>? dailyTimeLimits;

  static const int modeUnified = 1;
  static const int modeDaily = 2;
  static const int statusEnabled = 1;
  static const int statusDisabled = 2;

  bool get isMinorModeEnabled => status == statusEnabled;

  bool get hasConfiguredPhone {
    final value = phone?.trim();
    return value != null && value.isNotEmpty;
  }

  bool get hasPasswordMd5 {
    final value = passwordMd5?.trim();
    return value != null && value.isNotEmpty;
  }

  /// time_limit 为对象（有有效字段）或非空数组时视为已配置
  bool get hasTimeLimitConfigured {
    if (unifiedTimeLimit != null) {
      final limit = unifiedTimeLimit!;
      return limit.totalUseTime != null ||
          limit.hasDisabledPeriod ||
          limit.isEnable != null;
    }
    return dailyTimeLimits?.isNotEmpty ?? false;
  }

  /// 已配置手机号、密码与时间限制，且当前未开启，可直接验证密码开启
  bool get canQuickEnable =>
      hasConfiguredPhone &&
      hasPasswordMd5 &&
      hasTimeLimitConfigured &&
      !isMinorModeEnabled;

  bool get isDailyMode => mode == modeDaily;

  /// 获取指定日期对应的时间限制配置
  MinorModeTimeLimit? timeLimitForDate(DateTime date) {
    if (isDailyMode) {
      final limits = dailyTimeLimits;
      if (limits == null || limits.isEmpty) return null;

      final weekday = date.weekday;
      for (final limit in limits) {
        if (limit.weekday == weekday) return limit;
      }
      return weekday - 1 < limits.length ? limits[weekday - 1] : null;
    }
    return unifiedTimeLimit;
  }

  /// 未成年人模式已开启，且当前北京时间处于 is_enable=1 的禁用时段
  bool isInDisabledPeriodNow([DateTime? moment]) {
    if (!isMinorModeEnabled) return false;
    final now = moment ?? MinorModeTimeUtils.chinaNow();
    return timeLimitForDate(now)?.isDisabledPeriodActiveAt(now) ?? false;
  }

  /// 今日累计使用时长（分钟）是否已达上限（按北京时间自然日）
  bool isUsageTimeExceeded(int usageSeconds, [DateTime? moment]) {
    if (!isMinorModeEnabled) return false;
    final now = moment ?? MinorModeTimeUtils.chinaNow();
    final limitMinutes = timeLimitForDate(now)?.totalUseTime;
    if (limitMinutes == null || limitMinutes <= 0) return false;
    return usageSeconds >= limitMinutes * 60;
  }

  MinorTimeSettingMode get timeSettingMode => isDailyMode
      ? MinorTimeSettingMode.daily
      : MinorTimeSettingMode.unified;

  factory MinorModeInfoBean.fromJson(Map<String, dynamic> json) {
    MinorModeTimeLimit? unified;
    List<MinorModeTimeLimit>? daily;
    final timeLimitRaw = _parseTimeLimitRaw(json['time_limit']);

    if (timeLimitRaw is Map) {
      unified = MinorModeTimeLimit.fromJson(
        Map<String, dynamic>.from(timeLimitRaw),
      );
    } else if (timeLimitRaw is List) {
      daily = timeLimitRaw
          .whereType<Map>()
          .map(
            (item) => MinorModeTimeLimit.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return MinorModeInfoBean(
      birthday: json['birthday']?.toString(),
      phone: json['phone']?.toString(),
      passwordMd5: json['p']?.toString(),
      mode: _parseInt(json['mode']),
      status: _parseInt(json['status']),
      unifiedTimeLimit: unified,
      dailyTimeLimits: daily,
    );
  }

  static dynamic _parseTimeLimitRaw(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map || raw is List) return raw;
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        return jsonDecode(raw);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        if (birthday != null) 'birthday': birthday,
        if (phone != null) 'phone': phone,
        if (passwordMd5 != null) 'p': passwordMd5,
        if (mode != null) 'mode': mode,
        if (status != null) 'status': status,
        if (unifiedTimeLimit != null)
          'time_limit': unifiedTimeLimit!.toJson()
        else if (dailyTimeLimits != null)
          'time_limit': dailyTimeLimits!.map((e) => e.toJson()).toList(),
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
