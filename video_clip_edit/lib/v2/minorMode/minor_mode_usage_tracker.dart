import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/v2/minorMode/minor_mode_time_utils.dart';

/// 未成年人模式使用时长统计：禁用时段内、后台不计时，按自然日累计。
class MinorModeUsageTracker with WidgetsBindingObserver {
  MinorModeUsageTracker({
    required this.shouldTrack,
    required this.isInDisabledPeriod,
    this.canContinueCounting,
    this.onUsageChanged,
  });

  final bool Function() shouldTrack;
  final bool Function() isInDisabledPeriod;
  final bool Function()? canContinueCounting;
  final void Function(int usageSeconds)? onUsageChanged;

  static const _usageDateKey = 'minor_mode_usage_date';
  static const _usageSecondsKey = 'minor_mode_usage_seconds';

  int _usageSeconds = 0;
  Timer? _timer;
  Timer? _watchTimer;
  bool _appResumed = true;

  int get usageSeconds => _usageSeconds;

  void init() {
    WidgetsBinding.instance.addObserver(this);
    _ensureTodayUsage();
    syncTimer();
  }

  void dispose() {
    _stopTimer();
    _stopWatchTimer();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _appResumed = true;
      _ensureTodayUsage();
      syncTimer();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _appResumed = false;
      _stopTimer();
    }
  }

  void syncTimer() {
    _ensureTodayUsage();
    if (_canCountNow()) {
      _stopWatchTimer();
      _startTimer();
      return;
    }
    _stopTimer();
    if (shouldTrack()) {
      _startWatchTimer();
    } else {
      _stopWatchTimer();
    }
  }

  bool _canCountNow() =>
      shouldTrack() &&
      _appResumed &&
      !isInDisabledPeriod() &&
      (canContinueCounting?.call() ?? true);

  void _startTimer() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_canCountNow()) {
        _stopTimer();
        return;
      }
      _usageSeconds++;
      ByStorageUtils.saveInt(_usageSecondsKey, _usageSeconds);
      onUsageChanged?.call(_usageSeconds);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startWatchTimer() {
    if (_watchTimer != null) return;
    _watchTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _ensureTodayUsage();
      syncTimer();
    });
  }

  void _stopWatchTimer() {
    _watchTimer?.cancel();
    _watchTimer = null;
  }

  void _ensureTodayUsage() {
    final today = MinorModeTimeUtils.formatDateKey(MinorModeTimeUtils.chinaNow());
    final storedDate = ByStorageUtils.getString(_usageDateKey);
    if (storedDate != today) {
      _usageSeconds = 0;
      ByStorageUtils.saveString(_usageDateKey, today);
      ByStorageUtils.saveInt(_usageSecondsKey, 0);
      onUsageChanged?.call(_usageSeconds);
      return;
    }
    _usageSeconds = ByStorageUtils.getInt(_usageSecondsKey) ?? 0;
  }
}
