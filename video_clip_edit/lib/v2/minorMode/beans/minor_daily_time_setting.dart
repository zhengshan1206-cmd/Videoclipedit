import 'package:video_clip_edit/v2/minorMode/beans/minor_mode_time_limit.dart';

class MinorDailyTimeSetting {
  MinorDailyTimeSetting({
    required this.weekLabel,
    required this.isToday,
    this.durationMinutes = 40,
    this.disabledPeriod = MinorModeTimeLimit.defaultPeriodText,
    this.disabledEnabled = true,
  });

  final String weekLabel;
  final bool isToday;
  int durationMinutes;
  String disabledPeriod;
  bool disabledEnabled;
}
