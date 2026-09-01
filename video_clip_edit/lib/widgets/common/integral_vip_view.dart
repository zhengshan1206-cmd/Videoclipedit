import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';
import 'package:video_clip_edit/v2/integral/integral_pay_dialog.dart';

import '../../modules/home/providers/by_audio_player.dart';
import '../../utils/comon/by_common_events.dart';
import '../../v2/aiSquare/widgets/ai_video_player.dart';

/// 积分-VIP模块组件
class IntegralVipView extends StatefulWidget {
  const IntegralVipView({
    super.key,
    this.padding,
    this.requiredPoints = 0,
    this.type,
  });

  /// 自定义内边距
  final EdgeInsetsGeometry? padding;

  /// 所需积分
  final int requiredPoints;

  /// 权益类型
  final String? type;

  @override
  State<IntegralVipView> createState() => _IntegralVipViewState();
}

class _IntegralVipViewState extends State<IntegralVipView> {
  late final IntegralVipController controller;

  @override
  void initState() {
    super.initState();
    controller = IntegralVipController.getOrPut();
    if (widget.type != null) {
      // 使用 Future.microtask 确保在下一个微任务中执行初始化
      Future.microtask(() {
        controller.init(
          requiredPoints: widget.requiredPoints,
          type: widget.type!,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 检查积分模块是否开启
    // final purchaseProvider = context.read<PurchaseProvider>();
    // if (purchaseProvider.isIntegralOpen) {
    //   return SizedBox(height: 0.h);
    // }

    return Container(
      padding: widget.padding ?? EdgeInsets.only(bottom: 8.h),
      child: Obx(() {
        final userController = Get.find<UserController>();
        final userInfo = userController.user.value;
        final isVip = userInfo?.isVip ?? 0;
        final currentPoints = userInfo?.integral ?? 0;
        final freeCount = controller.freeCount;
        final isTest = controller.isTest;
        final actualPoints = controller.actualPoints;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isTest > 0
                  ? "创作即消耗1次"
                  : isVip == 0
                      ? "使用该功能需要消耗积分"
                      : (controller.isShowIntegral && freeCount > 0)
                          ? "创作即消耗1次"
                          : "本次消耗$actualPoints积分",
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF0B1843),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {

                  eventBus.fire(const PauseVideoEvent());
                  if (ByAudioPlayer.sharedInstance.isPlaying) {
                    ByAudioPlayer.sharedInstance.pause();
                  }


                  //登录前置检测
                  final purchaseProvider = context.read<PurchaseProvider>();
                  if (purchaseProvider.preLoginCheck(context) == false) {
                    return;
                  }
                  if (controller.isShowIntegral && freeCount > 0 ||
                      isTest > 0) {
                    return;
                  }
                  if (isVip == 0) {
                    context
                        .read<LaunchProvider>()
                        .gotoPay(context, closePay: true);
                  } else {
                    Get.toNamed(Routes.integralPage);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/mine/mine_integrate-icon.png",
                        width: 16.w,
                        height: 16.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 5.w),
                      isTest > 0
                          ? ByWidgetsUtil.commonRichText(
                              texts: [
                                const TextSpan(text: "剩余试用"),
                                TextSpan(
                                  text: "$isTest",
                                  style: const TextStyle(
                                    color: Color(0xFFF9A200),
                                  ),
                                ),
                                const TextSpan(text: "次"),
                              ],
                              textColor: const Color(0xFF0B1843),
                              fontSize: 14.sp,
                            )
                          : isVip == 0
                              ? Text(
                                  "开通会员赠送积分",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFFF9A200),
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : ByWidgetsUtil.commonRichText(
                                  texts: [
                                    const TextSpan(text: "剩余"),
                                    TextSpan(
                                      text: (controller.isShowIntegral &&
                                              freeCount > 0)
                                          ? "$freeCount"
                                          : "$currentPoints",
                                      style: const TextStyle(
                                        color: Color(0xFFF9A200),
                                      ),
                                    ),
                                    TextSpan(
                                        text: (controller.isShowIntegral &&
                                                freeCount > 0)
                                            ? "次"
                                            : "积分"),
                                  ],
                                  textColor: const Color(0xFF0B1843),
                                  fontSize: 14.sp,
                                ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
