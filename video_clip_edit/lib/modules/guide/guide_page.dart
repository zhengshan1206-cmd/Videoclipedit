import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/widgets/svga_player.dart';
import '../../controller/user_controller.dart';
import '../../providers/launch_provider.dart';
import '../../routes/app_pages.dart';
import '../login/controller/login_manager.dart';
import '../main/beans/launch_info_bean.dart';
import '../profile/beans/user_info_bean.dart';

///引导页面 这里只是一个过度动画
class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  ///展示的文本
  String showText = "正在加载Ai模型…";

  ///当前动画执行进度
  int progress = 0;

  /// 总倒计时时长：4.5秒
  final int totalSeconds = 4;
  final int totalMilliseconds = 500;

  /// 时间间隔：1.5秒
  final Duration interval = const Duration(milliseconds: 1500);
  late int _remainingSeconds;
  late int _remainingMilliseconds;
  Timer? _timer;
  bool _isRunning = false;

  ///登录的业务逻辑模块
  late LaunchProvider provider;

  ///登录数据
  late LaunchInfoBean launchInfo;

  ///用户的业务逻辑模块
  UserController controller = Get.find<UserController>();

  ///用户数据
  UserInfoBean? userInfo;

  @override
  void initState() {
    super.initState();
    initData();

    /// 初始化剩余时间
    _remainingSeconds = totalSeconds;
    _remainingMilliseconds = totalMilliseconds;
    _startCountdown();
  }

  @override
  void dispose() {
    /// 取消定时器
    _timer?.cancel();
    super.dispose();
  }

  initData() {
    provider = context.read<LaunchProvider>();
    provider.getPayStyle();
    launchInfo = provider.launchInfo!;
    userInfo = controller.user.value;
  }

  /// 开始倒计时
  void _startCountdown() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _remainingSeconds = totalSeconds;
      _remainingMilliseconds = totalMilliseconds;
    });

    _timer = Timer.periodic(interval, (timer) {
      setState(() {
        /// 减去一个时间间隔
        int totalRemainingMs =
            _remainingSeconds * 1000 + _remainingMilliseconds;
        totalRemainingMs -= interval.inMilliseconds;

        if (totalRemainingMs <= 0) {
          /// 倒计时结束
          _remainingSeconds = 0;
          _remainingMilliseconds = 0;
          _isRunning = false;
          _timer?.cancel();
        } else {
          /// 更新剩余时间
          _remainingSeconds = totalRemainingMs ~/ 1000;
          _remainingMilliseconds = totalRemainingMs % 1000;
        }

        if (_remainingSeconds == 3) {
          provider.getPayStyle();
          if (mounted) {
            setState(() {
              progress = 25;
            });
          }
        }

        if (_remainingSeconds == 1) {
          provider.getPayStyle();
          if (mounted) {
            setState(() {
              progress = 50;
              showText = "正在准备素材库…";
            });
          }
        }

        if (_remainingSeconds == 0) {
          if (mounted) {
            setState(() {
              progress = 99;
              showText = "电影级滤镜已经加载完成";
            });
            goNext();
          }
        }
        Get.log("===当前剩余时间=== $_remainingSeconds");
      });
    });
  }

  ///这里开始判断是去往归因的付费页面或者去首页
  void goNext() {
    launchInfo = provider.launchInfo!;
    final launchPage = launchInfo.verConfig.launchPage;
    Get.log("===跳转时候的launchInfo===${launchInfo.toJson()}");

    // 更新用户信息（使用 dynamic 避免部分环境下 onFailed 命名参数解析问题）
    (controller as dynamic).reloadUserInfo(
      successAction: (updatedUserInfo) {
        if (controller.user.value?.isBindPhone == 0) {
          LoginManager.initShanYan();
        }
        // 更新本地用户信息，优先使用更新后的用户信息
        final currentUserInfo = updatedUserInfo ?? controller.user.value;
        if (currentUserInfo != null) {
          userInfo = currentUserInfo;
        }

        // 保持原有逻辑
        if (launchPage == 1 || launchInfo.isVip == 1) {
          Get.offNamed(Routes.main);
        } else {
          // 使用更新后的用户信息，优先使用 controller.user.value（已由 reloadUserInfo 更新）
          final currentUserInfo = controller.user.value ?? userInfo;
          if ((currentUserInfo?.isFormal ?? 0) == 1 &&
              controller.user.value?.isBindPhone == 1) {
            provider.gotoPay(
              context,
              closePay: true,
              replace: true,
              needCheckLogin: false,
              cancelLogin: () {
                Get.offNamed(Routes.main);
              },
            );
          } else {
            Get.offNamed(Routes.main);
          }
        }
      },
      onFailed: (code, msg) {
        Get.offNamed(Routes.launchFaild);
        FlutterBugly.uploadException(
          message: "启动用户信息获取失败1: $code: $msg",
          detail: msg,
        );
        provider.uploadLaunchError(code, msg, true, {}, 45);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
      },
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            SizedBox(
              width: 1.sw,
              height: 600.h,
              child: const SvgaPlayer(url: "assets/guide/guide_animation.svga"),
            ),
            SizedBox(height: 49.w),
            Center(
              child: Text(
                "$showText（$progress%）",
                style: TextStyle(
                  color: Color(0XFF101E48),
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 82.w, right: 82.w, top: 12.w),
              child: SizedBox(
                width: 1.sw,
                child: LinearProgressIndicator(
                  value: progress / 100.0,
                  backgroundColor: const Color(0XFFE8E8E8),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0XFF819EFF)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
