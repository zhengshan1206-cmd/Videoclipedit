import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/main/controllers/new_user_benefits_controller.dart';
import 'package:video_clip_edit/modules/purchase/beans/count_down_config.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class NewVIPCountDownWidget extends StatelessWidget {
  const NewVIPCountDownWidget({super.key, this.isBlue = true});

  final bool isBlue;

  @override
  Widget build(BuildContext context) {
    int h = Random().nextInt(7) + 1; // 随机1～8 小时
    final now = DateTime.now();
    int countdown = 0;
    if (Get.isRegistered<NewUserBenefitsController>()) {
      countdown =
          Get.find<NewUserBenefitsController>().countdownForMill() ~/ 1000;
    }
    if (countdown == 0) {
      countdown = context.select<PurchaseProvider, int>(
        (p) => p.vipSpecialBean?.countdown ?? h * 60 * 60,
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 0.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CountDownView(
                config: CountDownConfig(
                  dateTime: now.add(Duration(seconds: countdown)),
                  fontSize: 14.sp,
                  timeItemWidh: 24.w,
                  timeItemBorderRadius: 4.w,
                  separatorFontSize: 14.sp,
                  separatorPadding: 3.w,
                  textColor: Colors.white,
                  separatorTextColor: Colors.white,
                  timeItemBgColor: isBlue
                      ? const Color(0xFFF74B9C)
                      : const Color(0xFFFFA838),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
  late Duration _countdown;

  @override
  void initState() {
    super.initState();
    final dateTime = widget.config.dateTime;
    _countdown = dateTime.difference(DateTime.now()); // 倒计时时长
    _refresh(dateTime);
    _startTimer(dateTime);
  }

  // 开始倒计时
  void _startTimer(DateTime dateTime) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 90), (timer) {
      _refresh(dateTime);
    });
  }

  void _refresh(DateTime dateTime) {
    final duration = dateTime.difference(DateTime.now());
    final (
      hour,
      mins,
      seconds,
    ) = (
      "${duration.inHours}".padLeft(2, "0"),
      "${duration.inMinutes.remainder(60)}".padLeft(2, "0"),
      "${duration.inSeconds.remainder(60)}".padLeft(2, "0"),
      // "${duration.inMilliseconds.remainder(1000)}".padLeft(3, "0"),
    );

    if (duration.inMilliseconds < 0) {
      _startTimer(DateTime.now().add(_countdown));
      return;
    }
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
    List<Widget> timers = _buildComponents();
    TextStyle tvStyle = const TextStyle(fontSize: 14, color: Colors.white);
    if(timers.isEmpty){
      return const SizedBox();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '倒计时',
          style: tvStyle,
        ),
        // 不足1h 不显示 时
        timers[0],
        Text(
          '时',
          style: tvStyle,
        ),
        timers[1],
        Text(
          '分',
          style: tvStyle,
        ),
        timers[2],
        Text(
          '秒 后恢复原价',
          style: tvStyle,
        ),
      ],
    );
  }

  List<Widget> _buildComponents() {
    final timeWidgets =
        timeComponents?.map((e) => _buildTime(time: e)).toList() ?? [];
    List<Widget> res = [];
    for (var e in timeWidgets) {
      res.add(e);
    }
    return res;
  }

  Container _buildTime({
    required String time,
  }) {
    return Container(
      width: widget.config.timeItemWidh,
      height: widget.config.timeItemWidh,
      margin: const EdgeInsets.symmetric(horizontal: 4),
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
