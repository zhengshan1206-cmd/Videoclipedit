import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/login/widgets/count_down_btn.dart';
import 'package:video_clip_edit/modules/login/widgets/login_agreement_view.dart';
import 'package:video_clip_edit/modules/login/widgets/login_text_field.dart';
import '../../flavors/build_config.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../providers/launch_provider.dart';
import '../../providers/login_provider.dart';
import '../../utils/comon/by_colors.dart';
import '../../utils/comon/by_nav_router_utils.dart';
import '../../utils/comon/by_widgets_util.dart';
import 'login_page.dart';

///仅手机验证码登录弹窗-huawei
class OnlyPhoneLoginPage extends StatefulWidget {
  final double closeIconTopMargin;
  final VoidCallback? cancelLogin;
  final Function()? successLogin;
  const OnlyPhoneLoginPage({super.key, 
  required this.closeIconTopMargin,
  this.successLogin,
  this.cancelLogin});

  @override
  State<OnlyPhoneLoginPage> createState() => _OnlyPhoneLoginPageState();
}

class _OnlyPhoneLoginPageState extends State<OnlyPhoneLoginPage> {
  final FocusNode phoneNode = FocusNode();
  final FocusNode codeNode = FocusNode();
  late LoginProvider provider;
  late LaunchProvider launchProvider;
  final ScrollController _scrollController = ScrollController();

  ///电话号码输入控制器
  TextEditingController phoneController = TextEditingController();

  ///验证码输入控制器
  TextEditingController verifyCodeController = TextEditingController();

  ///是否显示手机号码输入
  bool showPhoneHintText = false;

  bool couldSendCode = false;

  @override
  void initState() {
    super.initState();
    provider = context.read<LoginProvider>();
    launchProvider = context.read<LaunchProvider>();
    provider.updateLoginType(LoginType.phone);
    // 不在 initState 里直接赋值 loginSuccess，由 setLoginSuccess 统一设置（关页后再执行 widget.successLogin）
    // phoneNode.addListener(() {
    //   if (phoneNode.hasFocus) {
    //   }
    // });
    phoneController.addListener(() {
      provider.changePhoneNO(phoneController.text);
      if (phoneController.text.length < 11) {
        showPhoneHintText = true;
        couldSendCode = false;
      } else {
        showPhoneHintText = false;
        couldSendCode = true;
      }
      if (mounted) {
        setState(() {});
      }
    });

    verifyCodeController.addListener(() {
      provider.changeVCode(verifyCodeController.text);
      // if(verifyCodeController.text.length<11){
      //   showPhoneHintText = true;
      //   if(mounted){
      //     setState(() {
      //
      //     });
      //   }
      // }
    });
    checkAgreement();
  }

  ///检查协议弹窗是否同意勾选
  checkAgreement() {
    final isAudit = launchProvider.launchInfo!.isAudit;
    if (isAudit == 1) {
      provider.agreementCheckedStatusChanged(false);
    }
  }

  ///验证码登录
  Widget _buildPhoneCodeWidget() {
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
                  provider.changePhoneNO(value);
                },
                controller: phoneController,
              ),
              if (showPhoneHintText) SizedBox(height: 3.h),
              if (showPhoneHintText)
                Row(
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
                    hintText: "请输入验证码",
                    focusNode: codeNode,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    inputCallBack: (value) {
                      provider.changeVCode(value);
                    },
                    controller: verifyCodeController,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 23.w,
              child: CountDownBtn(
                  getCodeText: "发送",
                  // fontSize: 16.sp,
                  resendAfterText: "重新发送",
                  showBorder: true,
                  couldSendCode: couldSendCode,
                  onTap: () {
                    if (!provider.agreementChecked) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return LoginAgreementView(
                            btnTitle: "确认同意",
                            isLoginSend: true,
                            callback: () {
                              provider.agreementCheckedStatusChanged(true);
                            },
                          );
                        },
                      );
                    }
                  }
                  // getVCode: provider.getVCode,
                  ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 23.w),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (!provider.loginEnbled) return;
              if (!provider.agreementChecked) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return LoginAgreementView(
                      callback: () {
                        if (!provider.loginEnbled) return;
                        _startLogin(provider);
                      },
                    );
                  },
                );
              } else {
                if (!provider.loginEnbled) return;
                _startLogin(provider);
              }
            },
            child: Container(
              height: 50.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: provider.loginEnbled
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
        SizedBox(
          height: 10.h,
        ),
        // _weiXinLoginBtn(),
      ],
    );
  }

  Widget _buildBottomView() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        provider.agreementCheckedStatusChanged(!provider.agreementChecked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            const Spacer(),
            Image.asset(
              provider.agreementChecked
                  ? "assets/login/checked.png"
                  : "assets/login/uncheck.png",
              width: 16,
              height: 16,
            ),
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
              textColor: ByColorUtil.LoginTextfieldTextColor.withOpacity(0.6),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void _startLogin(LoginProvider provider) {
    setLoginSuccess(provider);
    provider.loginWithVCode(navigatorKey.currentState!.context);
  }

  void setLoginSuccess(LoginProvider provider) {
    // 登录成功时：先关闭登录页，再执行调用方传入的 successLogin（如 checkLogin 的 nextStepEvent）
    provider.loginSuccess = () async {
      final BuildContext? ctx = navigatorKey.currentState?.context;
      if (ctx != null) {
        ByNavRouterUtils.goBack(ctx);
      }
      widget.successLogin?.call();
    };
  }

  ///WEI XIN
  Widget _weiXinLoginBtn() {
    num appChannelCode = BuildConfig.instance.channelType.code;
    if (appChannelCode != 414 || Platform.isIOS) {
      return const SizedBox();
    }
    return Column(
      children: [
        SizedBox(
          height: 10.w,
        ),
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
                text: "其它登录方式",
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
          image: "assets/login/wei_xin_logo_icon.png",
          width: 36.w,
          height: 36.w,
          imageWidth: 36.w,
          imageHeight: 36.w,
          bgColor: Colors.transparent,
          onClick: () {
            provider.updateLoginType(LoginType.wx);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    provider.changeVCode("");
    provider.changePhoneNO("");
    phoneController.dispose();
    verifyCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<LoginProvider>(builder: (
        BuildContext ctx,
        LoginProvider provider,
        Widget? child,
      ) {
        if (provider.loginType == LoginType.wx) {
          return LoginPage(
            type: LoginPageType.half,
            showClose: true,
            isPlay: false,
          );
        }
        return Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  "assets/login/dengludialog_bj.png",
                  fit: BoxFit.fitWidth,
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 122),
                      child: Image.asset(
                        "assets/login/denglulogo.png",
                        width: 100,
                        height: 100,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Image.asset(
                      "assets/login/login_ai_model.png",
                      height: 16.h,
                      fit: BoxFit.fitHeight,
                    )
                  ],
                ),

                //关闭
                Positioned(
                  top: MediaQuery.of(context).padding.top + 0.0.h,
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      widget.cancelLogin?.call();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 45.w,
                      height: 45.w,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 16.w),
                      child: Image.asset(Assets.loginLoginClose,
                          width: 36.w, height: 36.w),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            _buildPhoneCodeWidget(),
            const Spacer(),
            _buildBottomView(),
            SizedBox(height: 34.h),
          ],
        );
      }),
    );
  }
}
