import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/commn_alert_dailog.dart';
import 'package:video_clip_edit/modules/login/widgets/count_down_btn.dart';
import 'package:video_clip_edit/modules/login/widgets/login_agreement_view.dart';
import 'package:video_clip_edit/modules/login/widgets/login_text_field.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/login_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class BindDialog extends StatefulWidget {
  final Function call;
  bool showTitle;

  BindDialog({
    super.key,
    required this.call,
    this.showTitle = true,
  });

  @override
  State<BindDialog> createState() => _BindDialogState();
}

class _BindDialogState extends State<BindDialog> {
  final FocusNode phoneNode = FocusNode();
  final FocusNode codeNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final isAudit = context.read<LaunchProvider>().launchInfo!.isAudit;
    if (isAudit == 1) {
      context.read<LoginProvider>().agreementCheckedStatusChanged(false);
    }
  }

  @override
  void dispose() {
    final isAudit = context.read<LaunchProvider>().launchInfo!.isAudit;
    if (isAudit == 1) {
      context.read<LoginProvider>().agreementChecked = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<LoginProvider>(
        builder: (c, p, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.symmetric(horizontal: 23.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.showTitle
                          ? Container(
                              padding: EdgeInsets.only(top: 40.h),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/bind/bind_text.png",
                                    width: 300.w,
                                    height: 52.h,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      SizedBox(height: widget.showTitle ? 20.h : 60.h),
                      LoginTextField(
                        // text: p.phoneNO,
                        hintText: "请输入手机号",
                        focusNode: phoneNode,
                        maxLength: 11,
                        keyboardType: TextInputType.number,
                        inputCallBack: (value) {
                          p.changePhoneNO(value);
                        },
                      ),
                      Offstage(
                        offstage: (p.phoneNO?.length ?? 0) == 11 ||
                            !phoneNode.hasFocus,
                        child: SizedBox(height: 3.h),
                      ),
                      Offstage(
                        offstage: (p.phoneNO?.length ?? 0) == 11 ||
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
                      ),
                      SizedBox(height: 10.h),
                      Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LoginTextField(
                                // text: p.vCode,
                                hintText: "请输入手机验证码",
                                focusNode: codeNode,
                                maxLength: 6,
                                keyboardType: TextInputType.number,
                                inputCallBack: (value) {
                                  p.changeVCode(value);
                                },
                              ),
                            ],
                          ),
                          const Positioned(
                            right: 0,
                            child: CountDownBtn(
                              getCodeText: "点击获取",
                              resendAfterText: "重新获取",
                              showBorder: true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 35.h),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (!p.loginEnbled) return;
                          if (!p.agreementChecked) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return LoginAgreementView(
                                  callback: () {
                                    if (!p.loginEnbled) return;
                                    _startBind(p, confirm: 0);
                                  },
                                );
                              },
                            );
                          } else {
                            if (!p.loginEnbled) return;
                            _startBind(p, confirm: 0);
                          }
                        },
                        child: Container(
                          height: 50.h,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: p.loginEnbled
                                ? ByColorUtil.TabTextColorSelected
                                : ByColorUtil.LoginBtnBgColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                          child: Text(
                            "立即绑定",
                            style: TextStyle(
                              color: ByColorUtil.WhiteColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              closeWidget(),
              Positioned(
                bottom: 30.h,
                child: xyWidget(p),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget closeWidget() {
    var right = 13.0.w;
    var height = 10.0.h;
    var img = Image.asset(
      "assets/login/login_dialog_close.png",
      width: 12.9,
      height: 12.7,
    );

    return Positioned(
      top: height,
      right: right,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 36,
          height: 44,
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 16.w),
          child: img,
        ),
      ),
    );
  }

  Widget xyWidget(LoginProvider provider) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        provider.agreementCheckedStatusChanged(!provider.agreementChecked);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: Row(
          children: [
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
          ],
        ),
      ),
    );
  }

  void _startBind(LoginProvider provider, {int? confirm}) {
    HttpUtils.post(
      showLoading: true,
      APIs.bindPhone,
      {
        "phone": provider.phoneNO,
        "is_confirm": confirm ?? 0,
        "code": provider.vCode,
      },
      success: (data) {
        BotToast.showText(text: data["message"]);
        ByNavRouterUtils.goBack(context);
        if (widget.call != null) {
          widget.call();
        }
      },
      fail: (code, msg) {
        if (code == 100) {
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (c) {
              return CommonAlertDialog(
                contents: msg,
                showCancel: true,
                cancelBtnTitle: "取消",
                manLine: 3,
                cancelCallback: (_) {
                  // Navigator.of(_).pop(false);
                },
                confirmBtnTitle: "确定",
                confirmCallback: (_) {
                  _startBind(provider, confirm: 1);
                  // Navigator.of(_).pop(true);
                },
              );
            },
          );
          return;
        }

        BotToast.showText(text: msg);
      },
    );
  }
}
