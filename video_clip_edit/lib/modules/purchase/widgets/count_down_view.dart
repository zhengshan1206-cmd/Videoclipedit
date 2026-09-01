import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_clip_edit/modules/purchase/beans/count_down_config.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class CountDownView extends StatefulWidget {
  final CountDownConfig config;
  const CountDownView({
    super.key,
    required this.config,
  });

  @override
  State<CountDownView> createState() => _CountDownViewState();
}

class _CountDownViewState extends State<CountDownView> {
  Timer? _timer;
  String? _hour;
  String? _mins;
  String? _seconds;
  List<String>? timeComponents;
  @override
  void initState() {
    super.initState();
    final dateTime = widget.config.dateTime;

    _refresh(dateTime);
    _timer = Timer.periodic(const Duration(milliseconds: 90), (timer) {
      _refresh(dateTime);
    });
  }

  void _refresh(DateTime dateTime) {
    final duration = dateTime.difference(DateTime.now());

    // 如果倒计时结束
    if (duration.isNegative || duration.inSeconds == 0) {
      _timer?.cancel();
      setState(() {
        _hour = "00";
        _mins = "00";
        _seconds = "00";
        timeComponents = ["00", "00", "00"];
      });
      return;
    }

    final (hour, mins, seconds) = (
      "${duration.inHours}".padLeft(2, "0"),
      "${duration.inMinutes.remainder(60)}".padLeft(2, "0"),
      "${duration.inSeconds.remainder(60)}".padLeft(2, "0"),
    );
    setState(() {
      _hour = hour;
      _mins = mins;
      _seconds = seconds;

      timeComponents = [
        _hour ?? "00",
        _mins ?? "00",
        _seconds ?? "00",
      ];
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._buildComponents(),
      ],
    );
  }

  _buildComponents() {
    final timeWidgets =
        timeComponents?.map((e) => _buildTime(time: e)).toList() ?? [];
    List<Widget> res = [];
    for (var e in timeWidgets) {
      res.add(e);
      res.add(_buildSeparator());
    }
    res.removeLast();
    return res;
  }

  Padding _buildSeparator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.config.separatorPadding),
      child: ByWidgetsUtil.commonText(
        text: ":",
        fontWeight: FontWeight.bold,
        fontSize: widget.config.separatorFontSize,
        textColor: widget.config.separatorTextColor,
      ),
    );
  }

  Container _buildTime({
    required String time,
  }) {
    return Container(
      width: widget.config.timeItemWidh,
      height: widget.config.timeItemWidh,
      // padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.config.timeItemBorderRadius),
        color: widget.config.timeItemBgColor,
      ),
      child: FittedBox(
        child: ByWidgetsUtil.commonText(
          text: time,
          fontSize: widget.config.fontSize,
          textColor: widget.config.textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
