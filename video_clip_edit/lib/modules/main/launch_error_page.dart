import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/main/beans/launch_info_bean.dart';
import 'package:video_clip_edit/modules/main/controllers/launch_error_controller.dart';
import 'package:video_clip_edit/modules/main/launch_log_page.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/widgets/ai_commentary_progress_bar.dart';

class LaunchErrorPage extends StatefulWidget {
  const LaunchErrorPage({super.key});

  @override
  State<LaunchErrorPage> createState() => _LaunchErrorPageState();
}

class _LaunchErrorPageState extends State<LaunchErrorPage> {
  final controller = Get.put(LaunchErrorController());

  Timer? _timer;

  /// 超时时间 10s
  int timeout = 10;

  /// 已花费时间
  double timeCost = 0;

  /// 点击次数
  int clickCount = 0;

  /// Logo 点击次数
  int logoClickCount = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _initTimer();
  }

  void _initTimer() {
    _timer?.cancel();

    /// 初始化一个定时器，每0.5秒，让进度增加0.1
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      controller.progress.value += 0.006;
      timeCost += 0.1;
      final faild = controller.launchFaild.value == true && timeCost >= 3.0;
      if (timeCost >= timeout || faild) {
        _timer?.cancel();

        /// 请求超时
        controller.launching.value = false;
        controller.launchFaild.value = false;
        controller.progress.value = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxW = ByScreenUtils.screenWidth - 27.w * 2;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Image.asset(
              "assets/v2/launch/launch_error_top_bg.png",
              fit: BoxFit.fitWidth,
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: 240.h),
                GestureDetector(
                  onTap: () {
                    logoClickCount++;
                    final remaining = 5 - logoClickCount;
                    if (logoClickCount >= 5) {
                      logoClickCount = 0; // 重置计数
                      Get.to(() => const LaunchLogPage());
                    } else {
                      BotToast.showText(text: "还需点击 $remaining 次");
                    }
                  },
                  child: Image.asset(
                    "assets/v2/launch/launch_error_logo.png",
                    width: 180.w,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                SizedBox(height: 35.h),
                ByWidgetsUtil.commonText(
                  text: "网络异常，请检查网络后重试",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                ),

                SizedBox(height: 15.h),

                ByWidgetsUtil.commonText(
                  text: "如有问题,可拨打客服热线协助您解决",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                ),

                SizedBox(height: 5.h),
                ByWidgetsUtil.commonText(
                  text: "（人工客服时间 早9:00-晚23:00）",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                ),

                SizedBox(height: 10.h),

                GestureDetector(
                  onTap: () async {
                    ///todo 拨打电话
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: "4008698538",
                    );
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    }
                  },
                  child: ByWidgetsUtil.commonText(
                    text: "400-869-8538",
                    fontSize: 26.sp,
                    fontWeight: FontWeight.normal,
                    textColor: ByColorUtil.CommonTextColor,
                  ),
                ),

                SizedBox(height: 20.h),
                Obx(
                  () => Offstage(
                    offstage: controller.launching.value == true,
                    child: controller.reTryCount.value >= 3
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (controller.reTryCount.value >= 1) ...[
                                SizedBox(
                                  height: 32.h,
                                  child: ByWidgetsUtil.commonBtn(
                                    title: "联系客服",
                                    textColor: ByColorUtil.LoginBtnBgColor,
                                    bgColor: const Color(0xFFEAEEFF),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                    ),
                                    fontSize: 14.sp,
                                    borderRadius: 8.sp,
                                    onClick: () {
                                      controller.contactCustomerEvent();
                                    },
                                  ),
                                ),
                                SizedBox(width: 10.w),
                              ],
                              _buildRetryBtn(context),
                            ],
                          )
                        : Row(
                            children: [
                              const Spacer(),
                              _buildRetryBtn(context),
                              if (controller.reTryCount.value >= 1) ...[
                                SizedBox(width: 10.w),
                                SizedBox(
                                  height: 32.h,
                                  child: ByWidgetsUtil.commonBtn(
                                    title: "联系客服",
                                    textColor: ByColorUtil.LoginBtnBgColor,
                                    bgColor: const Color(0xFFEAEEFF),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                    ),
                                    fontSize: 14.sp,
                                    borderRadius: 8.sp,
                                    onClick: () {
                                      controller.contactCustomerEvent();
                                    },
                                  ),
                                ),
                              ],
                              const Spacer(),
                            ],
                          ),
                  ),
                ),
                // SizedBox(height: 18.h),
                Obx(
                  () => Offstage(
                    offstage: controller.launching.value == false,
                    child: Container(
                      height: 32.h,
                      padding: EdgeInsets.symmetric(horizontal: 142.w),
                      child: ByWidgetsUtil.commonContainer(
                        bgColor: const Color(0xFFEAEEFF),
                        padding: EdgeInsets.zero,
                        borerRadius: 8.w,
                        child: ByWidgetsUtil.activityIndicator(
                          radius: 9.w,
                          color: ByColorUtil.LoginBtnBgColor,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),
                Obx(
                  () => Offstage(
                    offstage: controller.launching.value == false,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      alignment: Alignment.centerLeft,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Obx(
                            () => Positioned(
                              left: (maxW - 0.w) * controller.progress.value,
                              child: Image.asset(
                                "assets/ai/clip/ai_clip_progress.gif",
                                height: 40.h,
                                width: 24.w,
                                // fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                          SizedBox(width: maxW - 27.w, height: 40.h),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                SizedBox(
                  width: maxW,
                  height: 5.h,
                  child: Obx(
                    () => Offstage(
                      offstage: controller.launching.value == false,
                      child: AiCommentaryProgressBar(
                        progress: controller.progress.value,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 120.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SizedBox _buildRetryBtn(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: ByWidgetsUtil.commonBtn(
        title: "立即重试",
        textColor: ByColorUtil.LoginBtnBgColor,
        bgColor: const Color(0xFFEAEEFF),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        fontSize: 14.sp,
        borderRadius: 8.sp,
        onClick: () async {
          timeCost = 0;
          controller.launching.value = true;
          controller.progress.value = 0.0;
          controller.reTryCount.value = controller.reTryCount.value + 1;

          _initTimer();
          // clickCount ++;
          // if(clickCount > ) {
          // final Map params = await ByDeviceInfoUtils.getUserDiviceInfo();
          // BotToast.showText(text: json.encode(params));
          // _timer?.cancel();
          // return;
          // }

          final provider = context.read<LaunchProvider>();
          provider.launch(
            context,
            onSuccess: (LaunchInfoBean bean) {
              timeCost = 0;
              final userController = Get.find<UserController>();
              _timer?.cancel();
              userController.reloadUserInfo(
                successAction: (userInfo) {
                  controller.progress.value = 1.0;
                  Future.delayed(const Duration(milliseconds: 50), () {
                    controller.launching.value = false;
                    controller.progress.value = 0.0;
                    final launchPage = bean.verConfig.launchPage;
                    if (launchPage == 1 || bean.isVip == 1) {
                      Get.offNamed(Routes.main);
                    } else {
                      if ((userInfo?.isFormal ?? 0) == 1 &&
                          userController.user.value?.isBindPhone == 1) {
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
                  });
                },
              );
            },
            onFail: () {
              controller.launchFaild.value = true;
              if (timeCost >= 3.0) {
                timeCost = 0;
                controller.launching.value = false;
                controller.launchFaild.value = false;
                controller.progress.value = 0.0;
                _timer?.cancel();
              }
            },
          );
        },
      ),
    );
  }
}
