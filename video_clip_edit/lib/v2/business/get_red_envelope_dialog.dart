import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/main/controllers/new_user_benefits_controller.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/providers/ios_purchase_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/business/widget/guide_last_step_view.dart';

///专属红包领取页面
class GetRedEnvelopeWidget extends StatefulWidget {
  ///领取红包事件
  final VoidCallback? onTapForClaim;
  final VoidCallback? onTapForClose;

  const GetRedEnvelopeWidget({
    super.key,
    this.onTapForClaim,
    this.onTapForClose,
  });

  @override
  State<StatefulWidget> createState() => GetRedEnvelopeWidgetState();
}

class GetRedEnvelopeWidgetState extends State<GetRedEnvelopeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 36.w, end: 36.w),
                  child: Image.asset(
                    "assets/v2/business/img_red_envelope_bg.png",
                  ),
                ),
                Positioned(
                  top: 70.h,
                  child: Column(
                    children: [
                      Text(
                        "专属红包已就位",
                        style: TextStyle(
                          color: Color(0xFFFE3B00),
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      const NumberScrollAnimation(endNum: 99),
                      SizedBox(height: 8.h),
                      Text(
                        "红包仅限今日使用",
                        style: TextStyle(
                          color: const Color(0xFFFA9875),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 26.h,
                  child: GestureDetector(
                    child: BtnBreathingAnimationWidget(
                      child: Image.asset(
                        "assets/v2/business/img_red_envelope_btn.png",
                        width: 206.w,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onTapForClaim?.call();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 0.5.w),
                  borderRadius: BorderRadius.circular(16.w),
                ),
                child: Icon(Icons.close, size: 18.sp, color: Colors.white),
              ),
              onTap: () {
                widget.onTapForClose?.call();
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    );
  }
}

///放弃太可惜页面
class GetRewardWidget extends StatefulWidget {
  ///领取红包事件
  final VoidCallback? onTapForClaim;
  final VoidCallback? onTapForClose;

  const GetRewardWidget({super.key, this.onTapForClaim, this.onTapForClose});

  @override
  State<StatefulWidget> createState() => GetRewardWidgetState();
}

class GetRewardWidgetState extends State<GetRewardWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 36.w, end: 36.w),
                  child: Image.asset(
                    "assets/v2/business/img_red_envelope_bg2.png",
                  ),
                ),
                Positioned(
                  top: 110.h,
                  child: Column(
                    children: [
                      const NumberScrollAnimation(endNum: 99),
                      SizedBox(height: 8.h),
                      Text(
                        "专属优惠仅限今日",
                        style: TextStyle(
                          color: const Color(0xFFCD995D),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 40.h,
                  child: GestureDetector(
                    child: BtnBreathingAnimationWidget(
                      child: Image.asset(
                        "assets/v2/business/img_red_envelope_btn2.png",
                        width: 206.w,
                      ),
                    ),
                    onTap: () {
                      widget.onTapForClaim?.call();
                    },
                  ),
                ),
                Positioned(
                  bottom: 14.h,
                  child: GestureDetector(
                    child: Text(
                      "放弃红包",
                      style: TextStyle(
                        color: Color(0xFFFAD4C9).withOpacity(.8),
                      ),
                    ),
                    onTap: () {
                      widget.onTapForClose?.call();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 0.5.w),
                  borderRadius: BorderRadius.circular(16.w),
                ),
                child: Icon(Icons.close, size: 18.sp, color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

///新用户优惠页面
class NewUserWidget extends StatefulWidget {
  ///领取事件
  final VoidCallback? onTapForClaim;
  final VoidCallback? onTapForClose;

  const NewUserWidget({super.key, this.onTapForClaim, this.onTapForClose});

  @override
  State<StatefulWidget> createState() => NewUserWidgetState();
}

class NewUserWidgetState extends State<NewUserWidget> {
  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stack(
            //   alignment: AlignmentDirectional.center,
            //   children: [
            //     Padding(
            //       padding: EdgeInsetsDirectional.only(start: 36.w, end: 36.w),
            //       child: Image.asset(
            //         "assets/v2/business/img_first_time_bg.png",
            //       ),
            //     ),
            //     Positioned(
            //       bottom: 20.h,
            //       child: GestureDetector(
            //         child: BtnBreathingAnimationWidget(
            //           child: Image.asset(
            //             "assets/v2/business/img_first_time_btn.png",
            //             width: 206.w,
            //           ),
            //         ),
            //         onTap: () {
            //           Navigator.pop(context);
            //           widget.onTapForClaim?.call();
            //         },
            //       ),
            //     ),
            //   ],
            // ),
            Padding(
              padding: EdgeInsets.only(left: 32.w, right: 32.w),
              // padding: EdgeInsets.zero,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  widget.onTapForClaim?.call();
                },
                child: userController.newUserBenefitsImage.isNotEmpty
                    ? Image.network(
                        userController.newUserBenefitsImage,
                        fit: BoxFit.fitWidth,
                      )
                    : Image.asset("assets/v2/business/img_first_time_bg.png"),
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 0.5.w),
                  borderRadius: BorderRadius.circular(16.w),
                ),
                child: Icon(Icons.close, size: 18.sp, color: Colors.white),
              ),
              onTap: () {
                widget.onTapForClose?.call();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

///使用代金券页面
class UseCouponWidget extends StatefulWidget {
  ///点击事件
  final VoidCallback? onTapForClaim;

  const UseCouponWidget({super.key, this.onTapForClaim});

  @override
  State<StatefulWidget> createState() => UseCouponWidgetState();
}

class UseCouponWidgetState extends State<UseCouponWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 36.w, end: 36.w),
                  child: Image.asset(
                    "assets/v2/business/img_use_coupon_bg.png",
                  ),
                ),
                Positioned(
                  bottom: 40.h,
                  child: GestureDetector(
                    child: BtnBreathingAnimationWidget(
                      child: Image.asset(
                        "assets/v2/business/img_use_coupon_btn.png",
                        width: 262.w,
                      ),
                    ),
                    onTap: () {
                      widget.onTapForClaim?.call();
                    },
                  ),
                ),
                Positioned(
                  bottom: 14.h,
                  child: GestureDetector(
                    child: Text(
                      "让给别人",
                      style: TextStyle(
                        color: Color(0xFF010101).withOpacity(.5),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 0.5.w),
                  borderRadius: BorderRadius.circular(16.w),
                ),
                child: Icon(Icons.close, size: 18.sp, color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    );
  }
}

///限时购买页面
class LimitBuyWidget extends StatefulWidget {
  ///点击事件
  final VoidCallback? onTapForClaim;

  final VoidCallback? onClose;

  final PurchaseProvider? purchaseProvider;

  final IosPurchaseProvider? iosPurchaseProvider;

  const LimitBuyWidget({
    super.key,
    this.onTapForClaim,
    this.onClose,
    this.purchaseProvider,
    this.iosPurchaseProvider,
  });

  @override
  State<StatefulWidget> createState() => LimitBuyWidgetState();
}

class LimitBuyWidgetState extends State<LimitBuyWidget> {
  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    // 阔折/横屏下禁止按「整屏宽度」排子组件，否则白卡内 Row 远超底图宽度导致重叠错位
    final dialogW = math.min(screenW - 40.0, 420.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: dialogW,
              child: Stack(
                alignment: AlignmentDirectional.center,
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Image.asset(
                      "assets/v2/business/img_limit_buy_bg.png",
                      width: dialogW - 16.w,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Positioned(
                    top: 62.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: NumberScrollAnimation(
                            prefixText: "当前",
                            prefixTextStyle: TextStyle(
                              color: Color(0xFF5B1D08),
                              fontSize: 16.sp,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              fontFamily: "AlibabaPuHuiTi_3_115_Black",
                            ),
                            endNum: 1347,
                            textStyle: TextStyle(
                              color: Color(0xFF5B1D08),
                              fontSize: 16.sp,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              fontFamily: "AlibabaPuHuiTi_3_115_Black",
                            ),
                            showSymbol: false,
                            suffixText: "位\n   创作者正在使用",
                            suffixTextStyle: TextStyle(
                              color: Color(0xFF5B1D08),
                              fontSize: 16.sp,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              fontFamily: "AlibabaPuHuiTi_3_115_Black",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10.w,
                    right: 10.w,
                    top: 108.h,
                    bottom: 128.h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        Image.asset(
                          "assets/v2/business/img_benefits_bg.png",
                          height: 170.h,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          bottom: 15.h,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: AlignmentDirectional.topCenter,
                                    children: [
                                      Image.asset(
                                        "assets/v2/business/img_limit_red_envelope_bg.png",
                                        height: 90.w,
                                        fit: BoxFit.contain,
                                      ),
                                      Positioned(
                                        top: 12.h,
                                        child: GetBuilder<
                                            NewUserBenefitsController>(
                                          id: "updatePriceInfo",
                                          builder: (
                                            NewUserBenefitsController
                                                controller,
                                          ) {
                                            return RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "¥",
                                                    style: TextStyle(
                                                      color: Color(0xFFFF5752),
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        "${(int.tryParse(controller.getVipHappy()?.crossedMoney ?? "0") ?? 0) - (int.tryParse(controller.getVipHappy()?.money ?? "0") ?? 0)}",
                                                    style: TextStyle(
                                                      color: Color(0xFFFF5752),
                                                      fontSize: 28.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 18.w),
                                  Image.asset(
                                    "assets/v2/business/img_vertical_line.png",
                                    width: 1.w,
                                    height: 80.h,
                                  ),
                                  SizedBox(width: 18.w),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFC6958),
                                          borderRadius:
                                              BorderRadius.circular(6.w),
                                        ),
                                        alignment: AlignmentDirectional.center,
                                        width: 90.w,
                                        height: 24.h,
                                        child: Text(
                                          "每天仅需",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      GetBuilder<NewUserBenefitsController>(
                                        id: "updatePriceInfo",
                                        builder: (controller) {
                                          return RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: controller
                                                          .getVipHappy()
                                                          ?.dayMoney ??
                                                      "",
                                                  style: TextStyle(
                                                    color: Color(0xFFFC6958),
                                                    fontSize: 36.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "元",
                                                  style: TextStyle(
                                                    color: Color(0xFFFC6958),
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 82.h,
                    left: 10.w,
                    right: 10.w,
                    child: GestureDetector(
                      child: Obx(() {
                        bool agreed =
                            Get.find<NewUserBenefitsController>().agreed.value;
                        return Container(
                          color: Colors.transparent,
                          width: double.infinity,
                          alignment: AlignmentDirectional.center,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.center,
                            children: [
                              Image.asset(
                                agreed == true
                                    ? "assets/v2/business/img_pact_pressed.png"
                                    : "assets/v2/business/img_pact_normal.png",
                                width: 15.w,
                                height: 15.w,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                "同意",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.8),
                                  fontSize: 12.sp,
                                ),
                              ),
                              GestureDetector(
                                child: Text(
                                  "《会员服务协议》",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(.8),
                                    fontSize: 12.sp,
                                  ),
                                ),
                                onTap: () {
                                  if (widget.purchaseProvider?.vipPageBean?.user
                                          .protocolUrl.isEmpty ==
                                      true) return;
                                  ByNavRouterUtils.jumpWebViewPage(
                                    context,
                                    "",
                                    widget.purchaseProvider!.vipPageBean!.user
                                        .protocolUrl,
                                  );
                                },
                              ),
                              if (Platform.isIOS)
                                Text(
                                  "和",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(.8),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              if (Platform.isIOS)
                                GestureDetector(
                                  child: Text(
                                    "《自动续费服务协议》",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(.8),
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  onTap: () {
                                    debugPrint(
                                      "open Url:${widget.iosPurchaseProvider?.vipPageBean?.user.subScribeProtocolUrl}",
                                    );
                                    if (widget
                                            .iosPurchaseProvider
                                            ?.vipPageBean
                                            ?.user
                                            .subScribeProtocolUrl
                                            .isEmpty ==
                                        true) return;
                                    ByNavRouterUtils.jumpWebViewPage(
                                      context,
                                      "",
                                      widget.iosPurchaseProvider?.vipPageBean
                                              ?.user.subScribeProtocolUrl ??
                                          "",
                                    );
                                  },
                                ),
                              Text(
                                "和",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.8),
                                  fontSize: 12.sp,
                                ),
                              ),
                              GestureDetector(
                                child: Text(
                                  "《积分服务协议》",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(.8),
                                    fontSize: 12.sp,
                                  ),
                                ),
                                onTap: () {
                                  if (Platform.isIOS) {
                                    debugPrint(
                                      "open Url:${widget.iosPurchaseProvider?.vipPageBean?.user.integralRule}",
                                    );
                                    if (widget.iosPurchaseProvider?.vipPageBean!
                                            .user.integralRule.isNotEmpty !=
                                        true) return;
                                    ByNavRouterUtils.jumpWebViewPage(
                                      context,
                                      "",
                                      widget.iosPurchaseProvider!.vipPageBean
                                              ?.user.integralRule ??
                                          "",
                                    );
                                  } else {
                                    debugPrint(
                                      "open Url:${widget.purchaseProvider?.vipPageBean?.user.integralRule}",
                                    );
                                    if (widget.purchaseProvider?.vipPageBean!
                                            .user.integralRule.isNotEmpty !=
                                        true) {
                                      return;
                                    }
                                    ByNavRouterUtils.jumpWebViewPage(
                                      context,
                                      "",
                                      widget.purchaseProvider!.vipPageBean?.user
                                              .integralRule ??
                                          "",
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                      onTap: () {
                        Get.find<NewUserBenefitsController>().switchAgree();
                        context
                            .read<PurchaseProvider>()
                            .agreementCheckedStatusChanged(
                              Get.find<NewUserBenefitsController>()
                                  .agreed
                                  .value,
                            );
                      },
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 6.h,
                    child: Center(
                      child: GestureDetector(
                        child: BtnBreathingAnimationWidget(
                          child: Image.asset(
                            "assets/v2/business/img_limit_buy_btn.png",
                            width: 200.w,
                          ),
                        ),
                        onTap: () {
                          widget.onTapForClaim?.call();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 0.5.w),
                  borderRadius: BorderRadius.circular(16.w),
                ),
                child: Icon(Icons.close, size: 18.sp, color: Colors.white),
              ),
              onTap: () {
                widget.onClose?.call();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

///数字滚动动画
class NumberScrollAnimation extends StatefulWidget {
  final TextStyle? textStyle;
  final bool? showSymbol;
  final double? startNum;
  final double? endNum;
  final String? prefixText;
  final TextStyle? prefixTextStyle;
  final String? suffixText;
  final TextStyle? suffixTextStyle;

  const NumberScrollAnimation({
    super.key,
    this.textStyle,
    this.showSymbol = true,
    this.startNum,
    this.endNum,
    this.prefixText,
    this.prefixTextStyle,
    this.suffixText,
    this.suffixTextStyle,
  });

  @override
  State<NumberScrollAnimation> createState() => _NumberScrollAnimationState();
}

class _NumberScrollAnimationState extends State<NumberScrollAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.startNum ?? 0,
      end: widget.endNum ?? 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 自动开始动画
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // 将数字和 "元" 分开处理
        String numberStr = "";
        if ((widget.startNum ?? 0).toInt() == (widget.startNum ?? 0) &&
            (widget.endNum ?? 0).toInt() == (widget.endNum ?? 0)) {
          numberStr = _animation.value.toInt().toString();
        } else {
          numberStr = _animation.value
              .toStringAsFixed(2)
              .replaceFirst(RegExp(r'\.?0+$'), '');
        }
        return RichText(
          text: TextSpan(
            children: [
              if (widget.prefixText?.isNotEmpty == true)
                TextSpan(
                  text: widget.prefixText,
                  style: widget.prefixTextStyle ??
                      TextStyle(
                        color: Color(0xFFFE3B00),
                        fontWeight: FontWeight.bold,
                        height: 1,
                        fontSize: 66.sp,
                      ),
                ),
              // 滚动数字部分
              TextSpan(
                text: numberStr,
                style: widget.textStyle ??
                    TextStyle(
                      color: Color(0xFFFE3B00),
                      fontWeight: FontWeight.bold,
                      height: 1,
                      fontSize: 66.sp,
                    ),
              ),
              if (widget.showSymbol == true)
                // 固定的 "元" 部分
                TextSpan(
                  text: " 元",
                  style: widget.textStyle ??
                      TextStyle(
                        color: const Color(0xFFFE3B00),
                        fontWeight: FontWeight.bold,
                        height: 1,
                        fontSize: 24.sp,
                      ),
                ),
              if (widget.suffixText?.isNotEmpty == true)
                TextSpan(
                  text: widget.suffixText,
                  style: widget.suffixTextStyle ??
                      TextStyle(
                        color: Color(0xFFFE3B00),
                        fontWeight: FontWeight.bold,
                        height: 1,
                        fontSize: 66.sp,
                      ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 按钮呼吸动画
class BtnBreathingAnimationWidget extends StatefulWidget {
  final Widget child;

  const BtnBreathingAnimationWidget({super.key, required this.child});

  @override
  State<StatefulWidget> createState() => _BtnWidgetState();
}

class _BtnWidgetState extends State<BtnBreathingAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController btnController;
  late Animation<double> btnAnimation;

  @override
  void initState() {
    ///开按钮缩放动画
    btnController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    btnAnimation = Tween(begin: 1.0, end: 0.8).animate(btnController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: btnAnimation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(scale: btnAnimation.value, child: widget.child);
      },
    );
  }

  @override
  void dispose() {
    btnController.dispose();
    super.dispose();
  }
}

// 短剧归因到的首页引导弹窗
class ShortFilmGuideDialog extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onTapForClaim;

  const ShortFilmGuideDialog({super.key, this.onClose, this.onTapForClaim});

  @override
  State<ShortFilmGuideDialog> createState() => _ShortFilmGuideDialogState();
}

class _ShortFilmGuideDialogState extends State<ShortFilmGuideDialog> {
  bool _showCloseButton = false;
  Timer? _closeButtonTimer;

  @override
  void initState() {
    super.initState();
    // 2秒后显示关闭按钮
    _closeButtonTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showCloseButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _closeButtonTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Image.asset(
                  "assets/v2/promote/promote-6.png",
                  height: 494.w,
                  fit: BoxFit.fitHeight,
                ),
                Positioned(
                  bottom: 76.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        widget.onTapForClaim?.call();
                      },
                      child: ScaleTransitionWidget(
                        period: 300,
                        child: Container(
                          width: 260.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.w),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFE2551), Color(0xFFF9506E)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "领取授权",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Positioned(
                //   bottom: 36.h,
                //   right: 22.w,
                //   child: const FingerScaleAnimateView(),
                // ),
              ],
            ),
            SizedBox(height: 24.h),
            if (_showCloseButton)
              GestureDetector(
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  child: Image.asset(
                    "assets/v2/promote/promote-9.png",
                    width: 18.w,
                    height: 18.w,
                  ),
                ),
                onTap: () {
                  widget.onClose?.call();
                  Navigator.pop(context);
                },
              )
            else
              SizedBox(width: 32.w, height: 32.w),
          ],
        ),
      ),
    );
  }
}

///推广页展示效果弹窗
class PromotePageEffectDialog extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onTapForClaim;
  final VoidCallback? closeCallback;

  const PromotePageEffectDialog({
    super.key,
    this.onClose,
    this.onTapForClaim,
    this.closeCallback,
  });

  @override
  State<PromotePageEffectDialog> createState() =>
      _PromotePageEffectDialogState();
}

class _PromotePageEffectDialogState extends State<PromotePageEffectDialog>
    with SingleTickerProviderStateMixin {
  bool _showButton = false;
  bool _showButton2 = false;
  bool _showGif = true;
  Timer? _gifTimer;
  Timer? _autoCloseTimer;
  Timer? _showButtonTimer;
  Timer? _showGifTimer;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // 初始化缩放动画控制器
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
    // 2秒后显示"我知道了"按钮和1.5 promote-11
    _gifTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _showButton = true;
        });
        // 启动缩放动画
        _scaleController.forward();
      }
    });
    // 1.5秒后显示promote-11
    _showButtonTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showButton2 = true;
        });
      }
    });
    _showGifTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showGif = false;
        });
      }
    });
    // 5秒后自动关闭弹窗
    _autoCloseTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pop();
        widget.closeCallback?.call();
      }
    });
  }

  @override
  void dispose() {
    _gifTimer?.cancel();
    _autoCloseTimer?.cancel();
    _showButtonTimer?.cancel();
    _showGifTimer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SizedBox(
          height: 400.w,
          child: Stack(
            children: [
              // promote-11 和按钮在 GIF 播放完成后显示，带缩放动画
              if (_showButton)
                AnimatedBuilder(
                  animation: _scaleController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: double.infinity,
                        height: 90.w,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              "assets/v2/promote/promote-11.png",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: DiagonalShimmerWidget(
                          child: Center(
                            child: Image.asset(
                              "assets/v2/promote/promote-12.png",
                              width: 262.w,
                              height: 43.w,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              // GIF 播放时显示，播放完成后隐藏
              if (_showGif)
                Stack(
                  children: [
                    Positioned(
                      top: 0.w,
                      left: -120.w,
                      child: Transform.rotate(
                        angle: 0.7853, // 顺时针旋转90度 (π/4)
                        child: Image.asset(
                          "assets/v2/promote/promote-10.gif",
                          width: 440.w,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0.w,
                      right: -120.w,
                      child: Transform.rotate(
                        angle: -0.7853, // 逆时针旋转90度 (-π/4)
                        child: Image.asset(
                          "assets/v2/promote/promote-10.gif",
                          width: 440.w,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ],
                ),
              // "我知道了"按钮与promote-11同时显示
              if (_showButton2)
                SizedBox(
                  width: double.infinity,
                  height: 300.w,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        _autoCloseTimer?.cancel();
                        Navigator.of(context).pop();
                        widget.onClose?.call();
                      },
                      child: Text(
                        "我知道了",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 会员/续费弹窗通用协议行（与 RetentionVipNewDailog、PayPageBottomInterceptDialog 共用，逻辑一致）
class VipAgreementRow extends StatelessWidget {
  final EdgeInsetsGeometry? paddingAndroid;
  final EdgeInsetsGeometry? paddingIos;

  const VipAgreementRow({super.key, this.paddingAndroid, this.paddingIos});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Selector<IosPurchaseProvider,
          ({bool agreementChecked, bool hasVipPageBean})>(
        selector: (_, provider) => (
          agreementChecked: provider.agreementChecked,
          hasVipPageBean: provider.vipPageBean != null,
        ),
        builder: (context, data, child) {
          return _buildIosAgreement(context, data.agreementChecked);
        },
      );
    } else {
      return Selector<PurchaseProvider,
          ({bool isAgreementChecked, bool hasVipPageBean})>(
        selector: (_, provider) => (
          isAgreementChecked: provider.isAgreementChecked,
          hasVipPageBean: provider.vipPageBean != null,
        ),
        builder: (context, data, child) {
          return _buildAndroidAgreement(context, data.isAgreementChecked);
        },
      );
    }
  }

  EdgeInsets get _defaultPaddingAndroid =>
      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h);
  EdgeInsets get _defaultPaddingIos =>
      EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h);

  Widget _buildAndroidAgreement(BuildContext context, bool isAgreementChecked) {
    final currentProvider = context.read<PurchaseProvider>();
    final padding = paddingAndroid ?? _defaultPaddingAndroid;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 如果没有展示选择按钮且是默认同意状态，点击协议文字不应取消同意
        if (currentProvider.agreementNum && currentProvider.isAgreementChecked)
          return;
        currentProvider.agreementCheckedStatusChanged(
          !currentProvider.isAgreementChecked,
        );
      },
      child: Container(
        padding: padding,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!currentProvider.agreementNum)
                Image.asset(
                  isAgreementChecked
                      ? "assets/purchase/dark/checked_dark.png"
                      : "assets/purchase/dark/uncheck_dark.png",
                  height: 15.h,
                  color: const Color(0xFFFF3564),
                  fit: BoxFit.fitHeight,
                ),
              if (!currentProvider.agreementNum) SizedBox(width: 5.w),
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    ByWidgetsUtil.commonRichText(
                      texts: [
                        TextSpan(
                          text: "我已阅读并同意",
                          style: TextStyle(color: Color(0xFFB4B4BD)),
                        ),
                        TextSpan(
                          text: "《会员服务协议》",
                          style: const TextStyle(color: Color(0xFF42AAFF)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              final url =
                                  currentProvider.vipPageBean?.user.protocolUrl;
                              if (url == null || url.isEmpty) return;
                              ByNavRouterUtils.jumpWebViewPage(
                                context,
                                "",
                                url,
                              );
                            },
                        ),
                        if (currentProvider.isShowIntegralAgreement)
                          TextSpan(
                            text: "《积分服务协议》",
                            style: const TextStyle(color: Color(0xFF42AAFF)),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                final url = currentProvider
                                    .vipPageBean?.user.integralRule;
                                if (url == null || url.isEmpty) return;
                                ByNavRouterUtils.jumpWebViewPage(
                                  context,
                                  "",
                                  url,
                                );
                              },
                          ),
                      ],
                      fontSize: 12.sp,
                      textColor: const Color(0xFF999999),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIosAgreement(BuildContext context, bool isAgreementChecked) {
    final currentProvider = context.read<IosPurchaseProvider>();
    final padding = paddingIos ?? _defaultPaddingIos;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        currentProvider.agreementCheckedStatusChanged(
          !currentProvider.agreementChecked,
        );
      },
      child: Container(
        padding: padding,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                isAgreementChecked
                    ? "assets/purchase/dark/checked_dark.png"
                    : "assets/purchase/dark/uncheck_dark.png",
                height: 15.h,
                color: const Color(0xFFFF3564),
                fit: BoxFit.fitHeight,
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    ByWidgetsUtil.commonRichText(
                      texts: [
                        const TextSpan(text: "同意"),
                        TextSpan(
                          text: "《会员服务协议》",
                          style: const TextStyle(
                            color: Color(0xFF42AAFF),
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              final url =
                                  currentProvider.vipPageBean?.user.protocolUrl;
                              if (url == null || url.isEmpty) return;
                              ByNavRouterUtils.jumpWebViewPage(
                                context,
                                "",
                                url,
                              );
                            },
                        ),
                        const TextSpan(text: "和"),
                        TextSpan(
                          text: "《自动续费服务协议》",
                          style: const TextStyle(
                            color: Color(0xFF42AAFF),
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              final url = currentProvider
                                  .vipPageBean?.user.subScribeProtocolUrl;
                              if (url == null || url.isEmpty) return;
                              ByNavRouterUtils.jumpWebViewPage(
                                context,
                                "",
                                url,
                              );
                            },
                        ),
                        if (currentProvider.isShowIntegralAgreement)
                          TextSpan(
                            children: [
                              const TextSpan(text: "和"),
                              TextSpan(
                                text: "《积分服务协议》",
                                style: const TextStyle(
                                  color: Color(0xFF42AAFF),
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    final url = currentProvider
                                        .vipPageBean?.user.integralRule;
                                    if (url == null || url.isEmpty) return;
                                    ByNavRouterUtils.jumpWebViewPage(
                                      context,
                                      "",
                                      url,
                                    );
                                  },
                              ),
                            ],
                          ),
                      ],
                      fontSize: 12.sp,
                      textColor: const Color(0xFFB4B4BD),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///支付挽留弹窗 新版本逻辑3.10.41
class RetentionVipNewDailog extends StatefulWidget {
  final VoidCallback? onTapForClaim;
  final VoidCallback? onClose;
  final String? bgUrl;
  final String? btnTxt;

  const RetentionVipNewDailog({
    super.key,
    this.onTapForClaim,
    this.onClose,
    this.bgUrl,
    this.btnTxt,
  });

  @override
  State<RetentionVipNewDailog> createState() => _RetentionVipNewDailogState();
}

class _RetentionVipNewDailogState extends State<RetentionVipNewDailog> {
  @override
  void initState() {
    super.initState();
    // 确保 vipPageBean 已加载
    Future.microtask(() {
      if (!mounted) return;
      if (Platform.isIOS) {
        final iosProvider = context.read<IosPurchaseProvider>();
        if (iosProvider.vipPageBean == null) {
          iosProvider.loadVipData();
        }
      } else {
        final androidProvider = context.read<PurchaseProvider>();
        if (androidProvider.vipPageBean == null) {
          androidProvider.loadVipData();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  child: SizedBox(
                    width: 32.w,
                    height: 32.w,
                    child: Image.asset(
                      "assets/v2/promote/promote-9.png",
                      width: 18.w,
                      height: 18.w,
                    ),
                  ),
                  onTap: () {
                    widget.onClose?.call();
                    Get.back();
                  },
                ),
                SizedBox(width: 24.w),
              ],
            ),
            SizedBox(height: 6.h > 0 ? 6.h : 0),
            if (widget.bgUrl?.isNotEmpty == true)
              GestureDetector(
                child: Image.network(
                  widget.bgUrl!,
                  width: 1.sw,
                  fit: BoxFit.fitWidth,
                ),
                onTap: () {
                  widget.onTapForClaim?.call();
                },
              ),
            SizedBox(height: 10.h > 0 ? 10.h : 0),
            const VipAgreementRow(),
          ],
        ),
      ),
    );
  }
}

///付费页底部拦截弹窗
class PayPageBottomInterceptDialog extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onTapForClaim;

  /// 下发的背景图 URL，其余内容均在该图内
  final String? backgroundImageUrl;

  /// 下发的标题
  final String? title;

  const PayPageBottomInterceptDialog({
    super.key,
    this.onClose,
    this.onTapForClaim,
    this.backgroundImageUrl,
    this.title,
  });

  @override
  State<PayPageBottomInterceptDialog> createState() =>
      _PayPageBottomInterceptDialogState();
}

class _PayPageBottomInterceptDialogState
    extends State<PayPageBottomInterceptDialog> {
  String get _kDefaultBgUrl => widget.backgroundImageUrl?.isNotEmpty == true
      ? widget.backgroundImageUrl!
      : "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      if (Platform.isIOS) {
        final iosProvider = context.read<IosPurchaseProvider>();
        if (iosProvider.vipPageBean == null) {
          iosProvider.loadVipData();
        }
      } else {
        final androidProvider = context.read<PurchaseProvider>();
        if (androidProvider.vipPageBean == null) {
          androidProvider.loadVipData();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String bgUrl = widget.backgroundImageUrl?.isNotEmpty == true
        ? widget.backgroundImageUrl!
        : _kDefaultBgUrl;
    // 从底部往上撑开：内容高度 = 图片区 + 底部按钮，不占满屏
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: 1.sw,
                child: Image.network(bgUrl, fit: BoxFit.fitWidth),
              ),
              Positioned(
                top: 24.h,
                right: 16.w,
                child: GestureDetector(
                  onTap: () {
                    widget.onClose?.call();
                    Get.back();
                  },
                  child: Image.asset(
                    "assets/springFestival/springFestival-10.png",
                    width: 14.w,
                    height: 14.w,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Positioned(
                bottom: 0.h,
                right: 0.w,
                left: 0.w,
                child: GestureDetector(
                  onTap: () {
                    widget.onClose?.call();
                    Get.back();
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      24.w,
                      0,
                      24.w,
                      MediaQuery.of(context).padding.bottom + 7.h,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _promoteButton(widget.title ?? ""),
                        VipAgreementRow(
                          paddingAndroid: EdgeInsets.symmetric(vertical: 8.h),
                          paddingIos: EdgeInsets.symmetric(vertical: 8.h),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _promoteButton(String btnTxt) {
    ///放大缩小 动画；仅触发去支付，不关闭弹窗（由用户点关闭按钮或支付成功后再关）
    return ScaleTransitionWidget(
      period: 300,
      child: GestureDetector(
        onTap: () {
          widget.onTapForClaim?.call();
        },
        child: Container(
          width: double.infinity,
          height: 50.h,
          decoration: BoxDecoration(
            // gradient: const LinearGradient(
            //   colors: [Color(0xFFFD6D32), Color(0xFFFC3E42)],
            //   begin: Alignment.centerLeft,
            //   end: Alignment.centerRight,
            // ),
            image: const DecorationImage(
              image: AssetImage("assets/springFestival/springFestival-11.png"),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(24.r),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                btnTxt,
                style: TextStyle(
                  color: const Color(0xFFE56F1C),
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
