import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/base_view.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/modules/login/widgets/login_text_field.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/widgets/common_button.dart';
import 'package:video_clip_edit/widgets/count_down_view.dart';
import 'package:video_clip_edit/widgets/dialog/controllers/bind_phone_controller.dart';

import '../../flavors/build_config.dart';

class BindPhoneView extends StatefulWidget {
  const BindPhoneView({
    super.key,
    this.showTitle = false,
    this.needConfirm = false,
    this.justBindPhone = false,
    this.cancelBinding,
  });

  final bool showTitle;
  final bool needConfirm;
  final bool justBindPhone;
  final VoidCallback? cancelBinding;

  @override
  State<BindPhoneView> createState() => _BindPhoneState();
}

class _BindPhoneState extends State<BindPhoneView> {
  final controller = Get.put(BindPhoneController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BindPhoneController>(builder: (controller) {
      num appChannelCode = BuildConfig.instance.channelType.code;
      ///华为渠道414，现在所有渠道均走之前华为渠道，绑定手机号3.10.30版本修改
      if (appChannelCode != 0) {
        return BaseView(
          hasAppBar: false,
          backgroundColor: Colors.transparent,
          child: PopScope(
            canPop: false,
            child: Container(
              // padding: EdgeInsets.zero,
              //   child: Column(
              //     children: [
              //       Expanded(
              //        child: GestureDetector(
              //           behavior: HitTestBehavior.translucent,
              //           onTap: () {
              //             if (widget.justBindPhone) {
              //               if (!widget.needConfirm) {
              //                 Get.back();
              //               }
              //             } else {
              //               if (widget.needConfirm) {
              //                 controller.confirmBack();
              //               } else {
              //                 Get.back();
              //               }
              //             }
              //           },
              //           child: Container(),
              //         ),
              //       ),
              //       Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                        color: Colors.white,
                      ),
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.zero,
                            child: Stack(
                              children: [
                                Image.asset(
                                  "assets/login/dengludialog_bj.png",
                                  fit: BoxFit.fitWidth,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(top: 90.h),
                                  child: Image.asset(
                                    "assets/login/denglulogo.png",
                                    width: 100.w,
                                    height: 100.h,
                                  ),
                                ),
            
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child:GestureDetector(
                                    onTap: (){
                                      if (widget.needConfirm) {
                                        controller.confirmBack(cancel: () {
                                          widget.cancelBinding?.call();
                                        },);
                                      } else {
                                        Get.back();
                                        widget.cancelBinding?.call();
                                      }
                                    },
                                    child: SizedBox(
                                      width: 60.w,
                                      height: 80.w,
                                      // color: Colors.red,
                                      child:  CommonButton(
                                        padding: EdgeInsets.only(
                                          left: 12.w,
                                          top: 40.h,
                                        ),
                                        minSize: 13,
                                        onPressed: () {
                                          if (widget.needConfirm) {
                                            controller.confirmBack(
                                              content: "取消绑定有可能导致权益丢失， 是否继续绑定？",
                                              cancel: () {
                                                widget.cancelBinding?.call();
                                              },);
                                          } else {
                                            Get.back();
                                            widget.cancelBinding?.call();
                                          }
                                        },
                                        child: Image.asset(
                                            Assets.loginLoginClose,
                                            width: 36.w,
                                            height: 36.h),
                                      ),
                                    ),
                                  )
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 0.h,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 23.w),
                            child: Text(
                              "根据国家相关规定要求，需要完成手机号绑定才能继续使用后续功能。",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 23.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                !widget.showTitle
                                    ? Image.asset(
                                        Assets.bindBindText,
                                        width: 300.w,
                                        height: 52.h,
                                      )
                                    : Container(),
                                SizedBox(height: 20.h),
                                LoginTextField(
                                  hintText: "请输入手机号",
                                  focusNode: controller.phoneNode,
                                  maxLength: 11,
                                  keyboardType: TextInputType.number,
                                  inputCallBack: (value) {
                                    controller.phoneChanged(value);
                                  },
                                ),
                                Obx(() {
                                  return Offstage(
                                    offstage:
                                        controller.inputPhoneText.value.length ==
                                                11 ||
                                            !controller.isInputing.value,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 3.h),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            Assets.mineIconInfo,
                                            width: 12.w,
                                            height: 12.w,
                                            fit: BoxFit.contain,
                                          ),
                                          SizedBox(width: 5.w),
                                          BYText.instance("请输入正确的手机号码", 12.sp,
                                              color: const Color(0xFF5A4BF7)),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                SizedBox(height: 10.h),
                                Stack(
                                  children: [
                                    LoginTextField(
                                      hintText: "请输入手机验证码",
                                      maxLength: 6,
                                      keyboardType: TextInputType.number,
                                      inputCallBack: (value) {
                                        controller.vCodeChanged(value);
                                      },
                                    ),
                                    Obx(() {
                                      return Positioned(
                                        right: 0,
                                        child: CountDownView(
                                          defaultText: "点击获取",
                                          phoneNum:
                                              controller.inputPhoneText.value,
                                          enable: controller.vCodeEnable.value,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                Obx(() {
                                  final enable = controller.loginEnable.value;
                                  return Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(top: 35.h),
                                    child: CommonButton(
                                      padding: EdgeInsets.zero,
                                      minSize: 50,
                                      borderRadius: BorderRadius.circular(12.w),
                                      disabledColor:
                                          ByColorUtil.LoginBtnBgColor.withOpacity(
                                              0.3),
                                      color: enable
                                          ? ByColorUtil.LoginBtnBgColor
                                          : ByColorUtil.LoginBtnBgColor
                                              .withOpacity(0.3),
                                      onPressed:
                                          enable ? controller.bindPhone : null,
                                      child: BYText.instance('立即绑定', 16.sp,
                                          color: ByColorUtil.WhiteColor,
                                          fontWeight: BYFontWeight.semiBold),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const Spacer(),
                          _checkAgreementWidget(),
                        ],
                      ),
                    ),
          ),
                // ],
              // ),
            // ),
        );
      }
      return BaseView(
        hasAppBar: false,
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: SizedBox(
            height: Get.mediaQuery.size.height,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (widget.justBindPhone) {
                        if (!widget.needConfirm) {
                          Get.back();
                        }
                      } else {
                        if (widget.needConfirm) {
                          controller.confirmBack();
                        } else {
                          Get.back();
                        }
                      }
                    },
                    child: Container(),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: 15.w, top: 15.h, right: 15.w, bottom: 12.h),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            widget.showTitle
                                ? Align(
                                    alignment: Alignment.center,
                                    child: BYText.instance('绑定手机号', 16,
                                        fontWeight: BYFontWeight.medium),
                                  )
                                : Container(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: CommonButton(
                                padding: EdgeInsets.zero,
                                minSize: 13,
                                onPressed: () {
                                  if (widget.needConfirm) {
                                    controller.confirmBack();
                                  } else {
                                    Get.back();
                                  }
                                },
                                child: Image.asset(Assets.loginLoginDialogClose,
                                    width: 13.w, height: 13.h),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 23.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            !widget.showTitle
                                ? Image.asset(
                                    Assets.bindBindText,
                                    width: 300.w,
                                    height: 52.h,
                                  )
                                : Container(),
                            SizedBox(height: 30.h),
                            LoginTextField(
                              hintText: "请输入手机号",
                              focusNode: controller.phoneNode,
                              maxLength: 11,
                              keyboardType: TextInputType.number,
                              inputCallBack: (value) {
                                controller.phoneChanged(value);
                              },
                            ),
                            Obx(() {
                              return Offstage(
                                offstage:
                                    controller.inputPhoneText.value.length ==
                                            11 ||
                                        !controller.isInputing.value,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 3.h),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        Assets.mineIconInfo,
                                        width: 12.w,
                                        height: 12.w,
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(width: 5.w),
                                      BYText.instance("请输入正确的手机号码", 12.sp,
                                          color: const Color(0xFF5A4BF7)),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            SizedBox(height: 10.h),
                            Stack(
                              children: [
                                LoginTextField(
                                  hintText: "请输入手机验证码",
                                  maxLength: 6,
                                  keyboardType: TextInputType.number,
                                  inputCallBack: (value) {
                                    controller.vCodeChanged(value);
                                  },
                                ),
                                Obx(() {
                                  return Positioned(
                                    right: 0,
                                    child: CountDownView(
                                      defaultText: "点击获取",
                                      phoneNum: controller.inputPhoneText.value,
                                      enable: controller.vCodeEnable.value,
                                    ),
                                  );
                                }),
                              ],
                            ),
                            Obx(() {
                              final enable = controller.loginEnable.value;
                              return Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(top: 35.h),
                                child: CommonButton(
                                  padding: EdgeInsets.zero,
                                  minSize: 50,
                                  borderRadius: BorderRadius.circular(12.w),
                                  disabledColor:
                                      ByColorUtil.LoginBtnBgColor.withOpacity(
                                          0.3),
                                  color: enable
                                      ? ByColorUtil.LoginBtnBgColor
                                      : ByColorUtil.LoginBtnBgColor.withOpacity(
                                          0.3),
                                  onPressed:
                                      enable ? controller.bindPhone : null,
                                  child: BYText.instance('立即绑定', 16.sp,
                                      color: ByColorUtil.WhiteColor,
                                      fontWeight: BYFontWeight.semiBold),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      _checkAgreementWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _checkAgreementWidget() {
    return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: 100.h, bottom: 60.h),
        child: GestureDetector(
          onTap: () {
            controller.checkAgreement.value = !controller.checkAgreement.value;
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                return Image.asset(
                    controller.checkAgreement.value
                        ? Assets.loginChecked
                        : Assets.loginUncheck,
                    width: 16.w,
                    height: 16.h);
              }),
              SizedBox(width: 5.w),
              Flexible(
                child: ByWidgetsUtil.commonRichText(
                  texts: [
                    const TextSpan(text: "我已阅读并同意"),
                    TextSpan(
                      text: "《用户协议》",
                      style: BYTextStyle.instance(12.sp,
                          color: ByColorUtil.TabTextColorSelected),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          ByNavRouterUtils.jumpWebViewPage(
                              context,
                              "",
                              controller.launchProvider.launchInfo?.config
                                      .protocol ??
                                  "");
                        },
                    ),
                    TextSpan(
                      text: "《隐私政策》",
                      style: BYTextStyle.instance(12.sp,
                          color: ByColorUtil.TabTextColorSelected),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          ByNavRouterUtils.jumpWebViewPage(
                              context,
                              "",
                              controller.launchProvider.launchInfo?.config
                                      .privacy ??
                                  "");
                        },
                    ),
                  ],
                  fontSize: 12.sp,
                  textColor:
                      ByColorUtil.LoginTextfieldTextColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ));
  }
}
