import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/providers/ios_purchase_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';

typedef LoginAgreementCallback = void Function();

class IosPurchaseAgreementView extends StatelessWidget {
  final IosPurchaseProvider iosPurchaseProvider;
  const IosPurchaseAgreementView({
    super.key,
    this.btnTitle,
    this.callback,
    this.registerMember = false,
    required this.iosPurchaseProvider,
    this.color1,
  });

  final String? btnTitle;
  final LoginAgreementCallback? callback;

  final bool registerMember;
  final Color? color1;

  @override
  Widget build(BuildContext context) {
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
                SizedBox(height: 20.h),
                Text(
                  "协议确认",
                  style: TextStyle(
                    color: ByColorUtil.LoginTextfieldTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "进入下一步之前，请先阅读并同意",
                  style: TextStyle(
                    color: ByColorUtil.LoginTextfieldTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
                ByWidgetsUtil.commonRichText(
                  texts: [
                    TextSpan(
                      text: "《会员服务协议》",
                      style: TextStyle(
                        color: color1 ?? ByColorUtil.TabTextColorSelected,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          debugPrint(
                              "open Url:${iosPurchaseProvider.vipPageBean?.user.protocolUrl}");
                          if (iosPurchaseProvider
                              .vipPageBean!.user.protocolUrl.isEmpty) return;
                          ByNavRouterUtils.jumpWebViewPage(
                              context,
                              "",
                              iosPurchaseProvider
                                      .vipPageBean?.user.protocolUrl ??
                                  "");
                        },
                    ),
                    TextSpan(
                      text: "《自动续费服务协议》",
                      style: TextStyle(
                        color: color1 ?? ByColorUtil.TabTextColorSelected,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          debugPrint(
                              "open Url:${iosPurchaseProvider.vipPageBean?.user.subScribeProtocolUrl}");
                          if (iosPurchaseProvider
                              .vipPageBean!.user.protocolUrl.isEmpty) return;
                          ByNavRouterUtils.jumpWebViewPage(
                              context,
                              "",
                              iosPurchaseProvider
                                      .vipPageBean?.user.subScribeProtocolUrl ??
                                  "");
                        },
                    ),
                    if (iosPurchaseProvider.isShowIntegralAgreement)
                      TextSpan(
                        text: "《积分服务协议》",
                        style: TextStyle(
                          color: color1 ?? ByColorUtil.TabTextColorSelected,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            debugPrint(
                                "open Url:${iosPurchaseProvider.vipPageBean?.user.integralRule}");
                            if (iosPurchaseProvider
                                .vipPageBean!.user.integralRule.isEmpty) return;
                            ByNavRouterUtils.jumpWebViewPage(
                                context,
                                "",
                                iosPurchaseProvider
                                        .vipPageBean?.user.integralRule ??
                                    "");
                          },
                      ),
                  ],
                  fontSize: 12.sp,
                  textColor:
                      ByColorUtil.LoginTextfieldTextColor.withOpacity(0.6),
                ),
                SizedBox(height: 38.h),
                GestureDetector(
                  onTap: () {
                    ByNavRouterUtils.goBack(context);
                    callback?.call();
                  },
                  child: Container(
                    height: 44.h,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      // color: ByColorUtil.LoginBtnBgColor,
                      color: color1 ?? ByColorUtil.TabTextColorSelected,
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Text(
                      "确认并解锁会员",
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
