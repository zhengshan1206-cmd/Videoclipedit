// ignore_for_file: must_be_immutable

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/main.dart';
import 'package:video_clip_edit/modules/login/controller/login_controller.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/login/login_page.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/login/widgets/count_down_btn.dart';
import 'package:video_clip_edit/modules/login/widgets/login_text_field.dart';
import 'package:video_clip_edit/modules/login/widgets/login_agreement_view.dart';
import 'package:video_clip_edit/controller/user_controller.dart';

class LoginContentPage extends StatefulWidget {
  final LoginPageType type;
  //是否自动支付
  bool isPlay;
  LoginContentPage({super.key, required this.type, this.isPlay = true});

  @override
  State<LoginContentPage> createState() => LoginContentPageState();
}

class LoginContentPageState extends State<LoginContentPage> {
  final FocusNode phoneNode = FocusNode();
  final FocusNode codeNode = FocusNode();
  final LoginController controller = Get.find<LoginController>();
  late bool isAudit = true;

  @override
  void initState() {
    super.initState();
    isAudit = context.read<LaunchProvider>().launchInfo!.isAudit == 1;
    controller.agreementChecked.value = _getDefaultAgreementChecked();
    // 如果一键登录不可用，直接切换到手机号登录
    if (controller.loginType.value == LoginType.oneKey &&
        !controller.oneKeyGetPhone.value) {
      controller.updateLoginType(LoginType.phone);
    } else if (controller.loginType.value == LoginType.oneKey) {
      // ByPermissionUtils.phone().then((v) {
      //   if (v) {
      //     _initOneKeyWidget();
      //   } else {
      //     provider.oneKeyloginEnbled = false;
      //     provider.notifyListeners();
      //     // ByNavRouterUtils.goBack(context);
      //   }
      // });
      initOneKey();
    }

    controller.subscribeWXLoginResp(context);
  }

  /// 获取协议默认勾选状态
  /// 1. 审核状态（isAudit==1）：默认不勾选
  /// 2. 非审核状态（isAudit==0）：
  ///    - isNewAttributionUser==1：默认勾选
  ///    - isNewAttributionUser==0 或 null：默认不勾选
  bool _getDefaultAgreementChecked() {
    // 审核状态：默认不勾选
    if (isAudit) {
      return false;
    }

    // 非审核状态：根据 isNewAttributionUser 判断
    try {
      if (Get.isRegistered<UserController>()) {
        final userInfo = Get.find<UserController>().user.value;
        final isNewAttributionUser = userInfo?.isNewAttributionUser ?? 0;
        // isNewAttributionUser==1：默认勾选
        return isNewAttributionUser == 1;
      }
    } catch (e) {
      // 如果获取失败，默认不勾选
    }

    // 默认不勾选
    return false;
  }

  initOneKey() {
    try {
      controller.initOneKeyWidget();
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  @override
  void dispose() {
    controller.cancelSubscribeWXLoginResp();
    byDebugPrint("------------dispose");
    if (isAudit) {
      controller.agreementChecked.value = false;
    }
    phoneNode.dispose();
    codeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 如果是一键登录但一键登录不可用，自动切换到手机号登录
    Obx(() {
      if (controller.loginType.value == LoginType.oneKey &&
          !controller.oneKeyGetPhone.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (controller.loginType.value == LoginType.oneKey) {
            controller.updateLoginType(LoginType.phone);
          }
        });
      }
      return const SizedBox.shrink();
    });

    return SingleChildScrollView(
      child: Column(
        children: [
          Obx(() {
            // 如果是一键登录但不可用，也显示手机号登录界面
            final shouldShowPhone =
                controller.loginType.value == LoginType.phone ||
                    (controller.loginType.value == LoginType.oneKey &&
                        !controller.oneKeyGetPhone.value);
            return Offstage(
              offstage: !shouldShowPhone,
              child: _buildPhoneCodeWidgetr(),
            );
          }),
          Obx(() => Offstage(
                offstage: controller.loginType.value != LoginType.wx,
                child: _buildOtherMehods(context),
              )),
          Obx(() {
            final shouldShowSpacer =
                controller.loginType.value == LoginType.phone ||
                    (controller.loginType.value == LoginType.oneKey &&
                        !controller.oneKeyGetPhone.value);
            return Offstage(
              offstage: !shouldShowSpacer,
              child: SizedBox(height: 18.w),
            );
          }),
          if (!controller.onlyPhone! && controller.oneKeyGetPhone.value)
            Obx(() => Offstage(
                  offstage: controller.loginType.value != LoginType.phone,
                  child: GestureDetector(
                    onTap: () {
                      final isAudit =
                          context.read<LaunchProvider>().launchInfo!.isAudit;
                      if (isAudit == 1) {
                        controller.agreementCheckedStatusChanged(false);
                      }

                      /// 切换为一键登录
                      controller.updateLoginType(LoginType.oneKey);
                      controller.initOneKeyWidget();
                    },
                    child: Text(
                      "本机号码一键登录",
                      style: TextStyle(color: Colors.black, fontSize: 14.sp),
                    ),
                  ),
                )),
          SizedBox(height: controller.onlyPhone! ? 15.w : 5.w),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.agreementCheckedStatusChanged(
                  !controller.agreementChecked.value);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  const Spacer(),
                  Obx(() => Image.asset(
                        controller.agreementChecked.value
                            ? "assets/login/checked.png"
                            : "assets/login/uncheck.png",
                        width: 16,
                        height: 16,
                      )),
                  const SizedBox(width: 5),
                  ByWidgetsUtil.commonRichText(
                    texts: [
                      const TextSpan(text: "我已阅读并同意"),
                      TextSpan(
                        text: "《用户协议》",
                        style: const TextStyle(
                          color: ByColorUtil.TabTextColorSelected,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            ByNavRouterUtils.jumpWebViewPage(
                                context,
                                "",
                                context
                                        .read<LaunchProvider>()
                                        .launchInfo
                                        ?.config
                                        .protocol ??
                                    "");
                          },
                      ),
                      TextSpan(
                        text: "《隐私政策》",
                        style: const TextStyle(
                          color: ByColorUtil.TabTextColorSelected,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            ByNavRouterUtils.jumpWebViewPage(
                                context,
                                "",
                                context
                                        .read<LaunchProvider>()
                                        .launchInfo
                                        ?.config
                                        .privacy ??
                                    "");
                          },
                      ),
                    ],
                    fontSize: 12.sp,
                    textColor:
                        ByColorUtil.LoginTextfieldTextColor.withOpacity(0.6),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///验证码登录
  Widget _buildPhoneCodeWidgetr() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 23.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoginTextField(
                hintText: "请输入手机号",
                focusNode: phoneNode,
                maxLength: 11,
                keyboardType: TextInputType.number,
                inputCallBack: (value) {
                  controller.changePhoneNO(value);
                },
              ),
              Offstage(
                offstage: (controller.phoneNO?.length ?? 0) == 11 ||
                    !phoneNode.hasFocus,
                child: SizedBox(height: 3.h),
              ),
              Offstage(
                offstage: (controller.phoneNO?.length ?? 0) == 11 ||
                    !phoneNode.hasFocus,
                child: Row(
                  children: [
                    Image.asset(
                      "assets/mine/icon_info.png",
                      width: 12.w,
                      height: 12.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 5.w),
                    ByWidgetsUtil.commonText(
                      text: "请输入正确的手机号码",
                      fontSize: 12.sp,
                      textColor: const Color(0xFF5A4BF7),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 23.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoginTextField(
                    // text: provider.vCode,
                    hintText: "请输入验证码",
                    focusNode: codeNode,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    inputCallBack: (value) {
                      controller.changeVCode(value);
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              right: 23.w,
              child: const CountDownBtn(
                getCodeText: "发送",
                // fontSize: 16.sp,
                resendAfterText: "重新发送",
                showBorder: true,
                // getVCode: provider.getVCode,
              ),
            ),
          ],
        ),
        SizedBox(height: 35.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 23.w),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (!controller.loginEnbled.value) return;
              if (!controller.agreementChecked.value) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return LoginAgreementView(
                      callback: () {
                        if (!controller.loginEnbled.value) return;
                        _startLogin();
                      },
                    );
                  },
                );
              } else {
                if (!controller.loginEnbled.value) return;
                _startLogin();
              }
            },
            child: Container(
              height: 50.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: controller.loginEnbled.value
                    ? ByColorUtil.TabTextColorSelected
                    : ByColorUtil.LoginBtnBgColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Text(
                "立即登录",
                style: TextStyle(
                  color: ByColorUtil.WhiteColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _startLogin() {
    controller.setLoginSuccess();
    controller.loginWithVCode(navigatorKey.currentState!.context);
  }

  Widget _buildOtherMehods(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 101.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: ByWidgetsUtil.btnWithIcon(
            title: "微信一键登录",
            borderRadius: 12.w,
            contentGap: 10.w,
            iconW: 25.w,
            iconH: 25.w,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            bgColor: const Color(0xFF20BF64),
            iconPath: "assets/login/third_wx.png",
            onClick: () {
              controller.setLoginSuccess();
              if (!controller.agreementChecked.value) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return LoginAgreementView(
                      callback: () {
                        controller.wxLogin();
                      },
                    );
                  },
                );
                return;
              }
              controller.wxLogin();
            },
          ),
        ),
        SizedBox(height: 25.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 42.w),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 1,
                  child: ByWidgetsUtil.gradientBgContainer(
                    gradient: ByColorUtil.lineareGradient(
                      colorStart: const Color(0xFF101E48).withOpacity(0.05),
                      colorEnd: const Color(0xFF101E48).withOpacity(0.3),
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: 10,
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              ByWidgetsUtil.commonText(
                text: "其它号码登录",
                textColor: const Color(0xFF101E48).withOpacity(0.5),
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SizedBox(
                  height: 1,
                  child: ByWidgetsUtil.gradientBgContainer(
                    gradient: ByColorUtil.lineareGradient(
                      colorStart: const Color(0xFF101E48).withOpacity(0.05),
                      colorEnd: const Color(0xFF101E48).withOpacity(0.3),
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: 10,
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.h),
        ByWidgetsUtil.imageBtn(
          image: "assets/login/login_method_phone.png",
          width: 36.w,
          height: 36.w,
          imageWidth: 36.w,
          imageHeight: 36.w,
          bgColor: Colors.transparent,
          onClick: () {
            controller.updateLoginType(LoginType.phone);
          },
        ),
      ],
    );
  }
}
