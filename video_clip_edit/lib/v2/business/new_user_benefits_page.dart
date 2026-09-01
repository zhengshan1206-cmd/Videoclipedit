import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/main/controllers/new_user_benefits_controller.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/business/get_red_envelope_dialog.dart';
import 'package:video_clip_edit/v2/business/widget/countdown_timer_widget.dart';
import 'package:video_clip_edit/v2/business/widget/shake_pause_gift_widget.dart';

///新用户限时福利
class NewUserBenefitsWidget extends StatefulWidget {
  const NewUserBenefitsWidget({super.key});

  @override
  State<StatefulWidget> createState() => NewUserBenefitsWidgetState();
}

class NewUserBenefitsWidgetState extends State<NewUserBenefitsWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: _BenefitsBgWidget(
        barHeight: 80.h,
        giftSize: 50.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 不用 FittedBox+固定 351.w：窄屏上缩放后易与左侧礼物、右侧「抢」叠层错位；
            // 在父级宽度内用 LayoutBuilder 铺满可用宽度（阔屏 cap 较小设计宽并居中，整体更紧凑）。
            Positioned.fill(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: 30.w,
                  end: 36.w,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxW = constraints.maxWidth;
                    final contentW = math.min(304.w, maxW);
                    return Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: contentW,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: EdgeInsetsDirectional.only(
                                  start: 10.w, end: 10.w),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(12.w),
                                      bottomRight: Radius.circular(12.w))),
                              child: CountdownTimerWidget(
                                duration: Duration(
                                  milliseconds:
                                      Get.find<NewUserBenefitsController>()
                                          .countdownForMill(),
                                ),
                                onFinished: () {
                                  Get.find<NewUserBenefitsController>()
                                      .hideBottom();
                                },
                                textStyle: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFFFC5F19),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 40.h),
                              child: Image.asset(
                                "assets/v2/business/img_new_user_benefits.png",
                                width: contentW,
                                fit: BoxFit.contain,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            PositionedDirectional(
              end: 4.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsetsDirectional.only(start: 12.w, end: 8.w),
                  color: Colors.transparent,
                  child: BtnBreathingAnimationWidget(
                      child: Image.asset(
                    "assets/v2/business/img_rush_icon.png",
                    width: 30.w,
                    height: 30.w,
                  )),
                ),
              ),
            )
          ],
        ),
        onClose: () {
          Get.find<NewUserBenefitsController>().hideBottom();
        },
      ),
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.find<UserController>().user.value?.isVip != 1) {
            ByNavigatorUtil.checkLogin(
                withOutGotoBind: false,
                context: Get.context!,
                nextStepEvent: () {
                  final ctx = Get.context ?? context;
                  if (ctx.mounted) {
                    ctx.read<LaunchProvider>().gotoPay(ctx, closePay: true);
                  }
                });
          } else {
            Get.find<NewUserBenefitsController>().hideBottom();
          }
        });
      },
    );
  }
}

///创作者抄底福利
class BenefitsForCreatorWidget extends StatefulWidget {
  const BenefitsForCreatorWidget({super.key});

  @override
  State<StatefulWidget> createState() => BenefitsForCreatorWidgetState();
}

class BenefitsForCreatorWidgetState extends State<BenefitsForCreatorWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: _BenefitsBgWidget(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final rowW = math.min(330.w, maxW);
            return Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: rowW,
                child: Row(
                  children: [
                    SizedBox(width: 36.w),
                    Expanded(
                      child: Image.asset(
                        "assets/v2/business/img_benefits_for_creator.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    Image.asset(
                      "assets/v2/business/img_go_to_receive.png",
                      width: 66.w,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(width: 16.w),
                  ],
                ),
              ),
            );
          },
        ),
        onClose: () {
          Get.find<NewUserBenefitsController>().hideBottom();
        },
      ),
      onTap: () {
        ByNavigatorUtil.checkLogin(
            withOutGotoBind: false,
            context: Get.context!,
            nextStepEvent: () {
              final UserController controller = Get.find<UserController>();
              UserInfoBean? userInfo = controller.user.value;
              if (userInfo?.isVip != 1) {
                if (Get.context != null) {
                  Get.context
                      ?.read<LaunchProvider>()
                      .gotoPay(Get.context!, closePay: true);
                }
              } else {
                Get.find<NewUserBenefitsController>().hideBottom();
              }
            });
      },
    );
  }
}

///福利相关UI通用背景
class _BenefitsBgWidget extends StatefulWidget {
  const _BenefitsBgWidget({
    required this.child,
    this.onClose,
    this.barHeight,
    this.giftSize,
  });

  final Widget child;
  final VoidCallback? onClose;
  /// 为 null 时使用默认高度（兼容创作者福利等）。
  final double? barHeight;
  /// 左侧礼物尺寸，为 null 时使用默认。
  final double? giftSize;

  @override
  State<StatefulWidget> createState() => _BenefitsBgWidgetState();
}

class _BenefitsBgWidgetState extends State<_BenefitsBgWidget> {
  /// 底部福利条总高度（默认）；新用户条可传入更小 [barHeight]。
  static double _defaultBarOuterHeight() => 90.h;

  static double _defaultGiftSize() => 60.h;

  @override
  Widget build(BuildContext context) {
    final barH = widget.barHeight ?? _defaultBarOuterHeight();
    final giftS = widget.giftSize ?? _defaultGiftSize();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: SizedBox(
        width: double.infinity,
        height: barH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: widget.barHeight != null ? 4.h : 6.h),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFFEFFAE),
                                  Color(0xFFFEDAAA)
                                ]),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.w),
                                topRight: Radius.circular(24.w),
                                bottomLeft: Radius.circular(12.w),
                                bottomRight: Radius.circular(12.w)),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      const Color(0xFFF38315).withOpacity(.8),
                                  offset: Offset(0, 2.w),
                                  blurRadius: 15,
                                  spreadRadius: 1)
                            ]),
                        padding: EdgeInsets.all(4.w),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFC5713),
                                    Color(0xFFFFA142)
                                  ]),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.w),
                                  topRight: Radius.circular(20.w),
                                  bottomLeft: Radius.circular(10.w),
                                  bottomRight: Radius.circular(10.w))),
                          child: widget.child,
                        ),
                      ),
                      PositionedDirectional(
                        start: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: ShakePauseGiftWidget(
                              child: Image.asset(
                            "assets/v2/business/img_gift_icon.png",
                            width: giftS,
                            height: giftS,
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            PositionedDirectional(
              end: 0,
              top: 0,
              child: GestureDetector(
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsetsDirectional.only(end: 2.w),
                  child: Image.asset(
                    "assets/v2/business/img_close_icon.png",
                    width: 20.w,
                    height: 20.w,
                  ),
                ),
                onTap: () {
                  widget.onClose?.call();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///红包提示
class RedEnvelopeNoticeWidget extends StatefulWidget {
  const RedEnvelopeNoticeWidget({super.key});

  @override
  State<StatefulWidget> createState() => RedEnvelopeNoticeWidgetState();
}

class RedEnvelopeNoticeWidgetState extends State<RedEnvelopeNoticeWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(
                  margin: EdgeInsetsDirectional.only(start: 8.w, end: 8.w),
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.white.withOpacity(.1),
                        // color: Colors.black,
                        offset: Offset(0, 2.w),
                        blurRadius: 8,
                        spreadRadius: 1)
                  ]),
                  child: Image.asset(
                    "assets/v2/business/img_red_envelope_notice_bg.png",
                    width: double.infinity,
                    height: 60.h,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16.w,
                      ),
                      IntermittentShakingRedEnvelope(
                          child: Image.asset(
                        "assets/v2/business/img_red_envelope_icon.png",
                        // width: 20.w,
                        height: 24.h,
                        fit: BoxFit.fitHeight,
                      )),
                      SizedBox(
                        width: 8.w,
                      ),
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: "您有",
                            style: TextStyle(
                                color: Color(0xFF0B1843),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp)),
                        TextSpan(
                            text: "99元",
                            style: TextStyle(
                                color: Color(0xFFFF3630),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp)),
                        TextSpan(
                            text: "红包，",
                            style: TextStyle(
                                color: Color(0xFF0B1843),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp)),
                        WidgetSpan(
                            child: CountdownTimerWidget(
                          duration: Duration(
                              milliseconds:
                                  Get.find<NewUserBenefitsController>()
                                      .countdownForMill()),
                          onFinished: () {
                            Get.find<NewUserBenefitsController>().hideBottom();
                          },
                          textStyle: TextStyle(
                              color: const Color(0xFFFF3630),
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp),
                        )),
                        TextSpan(
                            text: "后过期",
                            style: TextStyle(
                                color: Color(0xFF0B1843),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp)),
                      ])),
                      BtnBreathingAnimationWidget(
                          child: Container(
                        padding:
                            EdgeInsetsDirectional.only(start: 8.w, end: 16.w),
                        color: Colors.transparent,
                        child: Image.asset(
                          "assets/v2/business/img_go_use.png",
                          width: 74.w,
                          height: 28.h,
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0.w,
              top: 0,
              child: GestureDetector(
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsetsDirectional.only(end: 8.w),
                  child: Image.asset(
                    "assets/v2/business/img_close_icon.png",
                    width: 20.h,
                    height: 20.h,
                  ),
                ),
                onTap: () {
                  Get.find<NewUserBenefitsController>().hideBottom();
                },
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        ByNavigatorUtil.checkLogin(
            withOutGotoBind: false,
            context: Get.context!,
            nextStepEvent: () {
              if (Get.find<UserController>().user.value?.isVip != 1) {
                ///登录成功
                if (Get.context != null) {
                  Get.context
                      ?.read<LaunchProvider>()
                      .gotoPay(Get.context!, closePay: true);
                }
              } else {
                Get.find<NewUserBenefitsController>().hideBottom();
              }
            });
      },
    );
  }
}
