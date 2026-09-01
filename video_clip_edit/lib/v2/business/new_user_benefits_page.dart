import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/main/controllers/new_user_benefits_controller.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
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
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16.w),
                          bottomRight: Radius.circular(16.w))),
                  child: CountdownTimerWidget(
                    duration: Duration(
                      milliseconds: Get.find<NewUserBenefitsController>()
                          .countdownForMill(),
                    ),
                    onFinished: () {
                      ///倒计时完成
                      Get.find<NewUserBenefitsController>().hideBottom();
                    },
                  ),
                ),
                const Expanded(child: SizedBox()),
                Image.asset(
                  "assets/v2/business/img_new_user_benefits.png",
                  width: 172.w,
                  fit: BoxFit.fitWidth,
                ),
              ],
            ),
            Positioned(
              right: 0,
              child: Container(
                height: 52.h,
                padding: EdgeInsetsDirectional.only(start: 20.w, end: 20.w),
                color: Colors.transparent,
                child: BtnBreathingAnimationWidget(
                    child: Image.asset(
                  "assets/v2/business/img_rush_icon.png",
                  width: 36.w,
                  height: 36.w,
                )),
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
                  Get.toNamed(
                    Routes.benefitsForCreatorPage,
                  )?.then((value) {
                    if (Get.find<NewUserBenefitsController>().agreed.value ==
                        true) {
                      Get.find<NewUserBenefitsController>().switchAgree();
                      context
                          .read<PurchaseProvider>()
                          .agreementCheckedStatusChanged(
                              Get.find<NewUserBenefitsController>()
                                  .agreed
                                  .value);
                    }
                  });
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 36.w,
                ),
                Image.asset(
                  "assets/v2/business/img_benefits_for_creator.png",
                  width: 214.w,
                  fit: BoxFit.fitWidth,
                ),
                const Expanded(child: SizedBox()),
                Image.asset(
                  "assets/v2/business/img_go_to_receive.png",
                  width: 66.w,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(
                  width: 16.w,
                )
              ],
            )
          ],
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
  final Widget child;
  final VoidCallback? onClose;

  const _BenefitsBgWidget({required this.child, this.onClose});

  @override
  State<StatefulWidget> createState() => _BenefitsBgWidgetState();
}

class _BenefitsBgWidgetState extends State<_BenefitsBgWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 70.h,
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 10.h,
              ),
              Expanded(
                  child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFEFFAE), Color(0xFFFEDAAA)]),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.w),
                            topRight: Radius.circular(24.w),
                            bottomLeft: Radius.circular(12.w),
                            bottomRight: Radius.circular(12.w)),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFFF38315).withOpacity(.8),
                              // color: Colors.black,
                              offset: Offset(0, 2.w),
                              blurRadius: 15,
                              spreadRadius: 1)
                        ]),
                    margin: EdgeInsetsDirectional.only(start: 16.w, end: 8.w),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsetsDirectional.only(
                        start: 4.w + 16.w,
                        end: 4.w + 8.w,
                        top: 4.w,
                        bottom: 4.w),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFC5713), Color(0xFFFFA142)]),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.w),
                            topRight: Radius.circular(24.w),
                            bottomLeft: Radius.circular(12.w),
                            bottomRight: Radius.circular(12.w))),
                    child: widget.child,
                  ),
                  Positioned(
                    left: 0,
                    child: ShakePauseGiftWidget(
                        child: Image.asset(
                      "assets/v2/business/img_gift_icon.png",
                      width: 60.h,
                      height: 60.h,
                    )),
                  ),
                ],
              ))
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
