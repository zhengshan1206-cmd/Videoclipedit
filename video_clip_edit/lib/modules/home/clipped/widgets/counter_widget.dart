import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late Timer? _timer;
  int seconds = 0;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        seconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = (seconds / 3600).floor();
    final mins = (seconds % 3600 / 60).floor();
    final secs = seconds % 60;
    return Container(
      child: ByWidgetsUtil.commonText(
        text: hours > 0
            ? "${"$hours".padLeft(2, "0")}:${"$mins".padLeft(2, "0")}:${"$secs".padLeft(2, "0")}"
            : "${"$mins".padLeft(2, "0")}:${"$secs".padLeft(2, "0")}",
        fontSize: 36.sp,
        fontWeight: FontWeight.bold,
        textColor: ByColorUtil.TabTextColorSelected,
      ),
    );
  }
}
