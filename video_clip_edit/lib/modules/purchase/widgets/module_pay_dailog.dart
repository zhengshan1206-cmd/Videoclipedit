import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'dart:async';

class ModulePayDailog extends StatefulWidget {
  final String markUrl;
  final String mark;

  const ModulePayDailog({super.key, required this.markUrl, required this.mark});

  @override
  State<ModulePayDailog> createState() => _ModulePayDailogState();
}

class _ModulePayDailogState extends State<ModulePayDailog> {
  // 判断是否是网络图片
  bool get isNetworkImage => widget.markUrl.startsWith('http');

  Timer? _timer;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
        _autoNavigate();
      }
    });
  }

  void _autoNavigate() {
    if (mounted) {
      ByNavRouterUtils.goBack(context);
      // context.read<LaunchProvider>().gotoPay(context, closePay: true);
      context
          .read<LaunchProvider>()
          .showPayHalfDialog(context, widget.mark);
    }
  }

  void _handleUserInteraction() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              _handleUserInteraction();
              ByNavRouterUtils.goBack(context);
              context
                  .read<LaunchProvider>()
                  .showPayHalfDialog(context, widget.mark);
            },
            child: Stack(
              children: [
                Container(
                  width: 300.w,
                  height: 400.h,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                    image: DecorationImage(
                      image: isNetworkImage
                          ? NetworkImage(widget.markUrl)
                          : AssetImage(widget.markUrl),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16.h,
                  right: 15.w,
                  left: 15.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransitionWidget(
                        child: Stack(
                          children: [
                            Container(
                              height: 70.h,
                              width: 270.w,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      "assets/purchase/dailog_obtain_btn3.png"),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 30,
                              child: Image.asset(
                                "assets/purchase/icon_pointer.png",
                                width: 52,
                                height: 45,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12.h,
                  left: 15.w,
                  right: 15.w,
                  child: Text(
                    '$_countdown秒后自动跳转',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF000000).withOpacity(0.5),
                      fontSize: 12.sp,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _handleUserInteraction();
              ByNavRouterUtils.goBack(context);
            },
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/purchase/dailog_bonus_close.png",
                width: 32,
                height: 32,
              ),
            ),
          )
        ],
      ),
    );
  }
}
