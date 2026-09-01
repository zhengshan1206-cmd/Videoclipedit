import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:video_clip_edit/providers/integral_pay_provider.dart';
import 'package:video_clip_edit/providers/ios_purchase_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:flutter/foundation.dart';

typedef LoginAgreementCallback = void Function();

class LoginAgreementView extends StatelessWidget {
  const LoginAgreementView({
    super.key,
    this.btnTitle,
    this.callback,
    this.onClose,
    this.registerMember = false,
    this.isIntegral = false, //是否积分页面
    this.color1,
    this.isLoginSend = false,
  });

  final String? btnTitle;
  final LoginAgreementCallback? callback;
  final LoginAgreementCallback? onClose;

  final bool registerMember;

  final bool isIntegral;

  final Color? color1;

  //是否是登录页发送弹窗
  final bool isLoginSend;

  dynamic get _provider {
    if (Platform.isIOS) {
      return Get.context!.read<IosPurchaseProvider>();
    } else {
      return Get.context!.read<PurchaseProvider>();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 确保在构建时加载 VIP 数据
    if (!Platform.isIOS) {
      final provider = context.read<PurchaseProvider>();
      if (provider.vipPageBean == null) {
        provider.loadVipData();
      }
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 28.w),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: ByColorUtil.WhiteColor,
              borderRadius: BorderRadius.circular(16.w),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40.h),
                isIntegral
                    ? Text(
                        '积分服务协议',
                        style: TextStyle(
                          color: ByColorUtil.LoginTextfieldTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      )
                    : Text(
                        registerMember ? '服务协议' : "用户协议及隐私保护",
                        style: TextStyle(
                          color: ByColorUtil.LoginTextfieldTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                SizedBox(height: 30.h),
                isLoginSend
                    ? ByWidgetsUtil.commonRichText(
                        texts: [
                          const TextSpan(text: "请仔细阅读"),
                          TextSpan(children: [
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
                            const TextSpan(text: "和"),
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
                          ]),
                          const TextSpan(text: "，确实是否同意"),
                        ],
                        textColor: ByColorUtil.LoginTextfieldTextColor,
                        fontSize: 14.sp,
                      )
                    : ByWidgetsUtil.commonRichText(
                        texts: [
                          const TextSpan(text: "我已阅读并同意"),
                          isIntegral
                              ? TextSpan(
                                  text: "《积分服务协议》",
                                  style: const TextStyle(
                                    color: ByColorUtil.TabTextColorSelected,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      final integralProvider =
                                          Provider.of<IntegralPayProvider>(
                                              context,
                                              listen: false);
                                      if (integralProvider.integralIllustrate ==
                                              null ||
                                          integralProvider
                                              .integralIllustrate!.isEmpty) {
                                        Get.snackbar("提示", "协议链接无效");
                                        return;
                                      }
                                      ByNavRouterUtils.jumpWebViewPage(
                                        context,
                                        "积分服务协议",
                                        integralProvider.integralIllustrate!,
                                      );
                                    })
                              : registerMember
                                  ? TextSpan(children: [
                                      TextSpan(
                                        text: "《会员服务协议》",
                                        style: TextStyle(
                                          color: color1 ??
                                              ByColorUtil.TabTextColorSelected,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            String? protocolUrl;
                                            if (Platform.isIOS) {
                                              final iosProvider = _provider
                                                  as IosPurchaseProvider;
                                              protocolUrl = iosProvider
                                                  .vipPageBean
                                                  ?.user
                                                  .protocolUrl;
                                            } else {
                                              final androidProvider =
                                                  _provider as PurchaseProvider;
                                              protocolUrl = androidProvider
                                                  .vipPageBean
                                                  ?.user
                                                  .protocolUrl;
                                            }

                                            debugPrint(
                                                "open Url: $protocolUrl");
                                            if (protocolUrl?.isEmpty ?? true)
                                              return;

                                            ByNavRouterUtils.jumpWebViewPage(
                                                context, "", protocolUrl ?? "");
                                          },
                                      ),
                                      if (context
                                          .read<PurchaseProvider>()
                                          .isShowIntegralAgreement)
                                        TextSpan(
                                          text: "《积分服务协议》",
                                          style: TextStyle(
                                            color: color1 ??
                                                ByColorUtil
                                                    .TabTextColorSelected,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              String? protocolUrl;
                                              if (Platform.isIOS) {
                                                final iosProvider = _provider
                                                    as IosPurchaseProvider;
                                                protocolUrl = iosProvider
                                                    .vipPageBean
                                                    ?.user
                                                    .integralRule;
                                              } else {
                                                final androidProvider =
                                                    _provider
                                                        as PurchaseProvider;
                                                protocolUrl = androidProvider
                                                    .vipPageBean
                                                    ?.user
                                                    .integralRule;
                                              }

                                              debugPrint(
                                                  "open Url: $protocolUrl");
                                              if (protocolUrl?.isEmpty ?? true)
                                                return;

                                              ByNavRouterUtils.jumpWebViewPage(
                                                  context,
                                                  "",
                                                  protocolUrl ?? "");
                                            },
                                        )
                                    ])
                                  : TextSpan(children: [
                                      TextSpan(
                                        text: "《用户协议》",
                                        style: const TextStyle(
                                          color:
                                              ByColorUtil.TabTextColorSelected,
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
                                          color:
                                              ByColorUtil.TabTextColorSelected,
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
                                    ]),
                        ],
                        textColor: ByColorUtil.LoginTextfieldTextColor,
                        fontSize: 14.sp,
                      ),
                SizedBox(height: 38.h),
                GestureDetector(
                  onTap: () {
                    ByNavRouterUtils.goBack(context);
                    callback?.call();
                    // onClose?.call();
                  },
                  child: Container(
                    height: 44.h,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color1 ?? ByColorUtil.LoginBtnBgColor,
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Text(
                      btnTitle ?? "登录并同意",
                      style: TextStyle(
                        color: ByColorUtil.WhiteColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
          Positioned(
            right: 38.w,
            top: 10.w,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ByNavRouterUtils.goBack(context);
                onClose?.call();
              },
              child: Container(
                  width: 20.w,
                  height: 20.w,
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/login/login_dialog_close.png",
                    width: 10.w,
                    height: 10.w,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
