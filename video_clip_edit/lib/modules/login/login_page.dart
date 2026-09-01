/*
 * @Author: cold-x
 * @Date: 2025-05-13 14:30:08
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-14 22:00:17
 * @FilePath: /video_clip_edit/lib/modules/login/login_page.dart
 * @Description: 
 */
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/providers/login_provider.dart';
import 'package:video_clip_edit/modules/login/widgets/login_content_view.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';

import '../../flavors/build_config.dart';
import '../../providers/launch_provider.dart';
import '../../routes/app_pages.dart';
import '../../utils/channel/channel_config.dart';
import '../../utils/comon/by_colors.dart';
import '../../utils/comon/by_nav_router_utils.dart';
import '../../utils/comon/by_widgets_util.dart';

enum LoginPageType { half, entire }

// ignore: must_be_immutable
class LoginPage extends StatefulWidget {
  //是否自动支付
  bool isPlay;

  final LoginPageType type;
  final bool showClose;
  final VoidCallback? cancelLogin;
  final LoginType? loginType;
  final bool? privacy;
  final Function()? successLogin;
  LoginPage({
    super.key,
    required this.type,
    this.cancelLogin,
    this.showClose = true,
    this.isPlay = true,
    this.privacy,
    this.successLogin,
    this.loginType = LoginType.phone,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<LoginContentViewState> _contentViewKey =
      GlobalKey<LoginContentViewState>();
  @override
  void initState() {
    super.initState();
    provider = context.read<LoginProvider>();
    //默认登录方式
    provider.loginType = widget.loginType!;
    provider.pages = [];
    ByNavigatorUtil.reportDataPoint(
      pageTag: "login_page",
      operateType: "view",
      funcDetailTag: widget.loginType == LoginType.oneKey
          ? "1"
          : widget.loginType == LoginType.phone
              ? "2"
              : "3",
      funcDetailImg: "",
    );
  }

  late LoginProvider provider;
  @override
  Widget build(BuildContext context) {
    provider = context.watch<LoginProvider>();
    return Opacity(
      opacity: 1.0,
      child: PopScope(
        canPop: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Consumer<LoginProvider>(builder: (
                BuildContext ctx,
                LoginProvider provider,
                Widget? child,
              ) {
                return Column(
                  children: [
                    Stack(
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
                      ],
                    ),
                    SizedBox(height: 12.h),
                    LoginContentView(
                      privacy: widget.privacy,
                      key: _contentViewKey,
                      type: widget.type,
                      isPlay: widget.isPlay,
                      successLogin: widget.successLogin,
                    ),
                    const Spacer(),
                    _checkBox(),
                    SizedBox(height: 34.h),
                  ],
                );
              }),
              closeWidget(),
              // if (appChannelCode != 414)
              // _backBtn(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget closeWidget() {
    if (!widget.showClose) return Container();
    final isHalf = widget.type == LoginPageType.half;
    var height = isHalf ? 12.5.w : MediaQuery.of(context).padding.top + 10.0.h;
    var img = isHalf
        ? Image.asset("assets/login/login_dialog_close.png",
            // width: 12.9,
            // height: 12.7,
            width: 13.w,
            height: 13.h)
        : Image.asset(
            "assets/login/login_close.png",
            width: 36,
            height: 36,
          );

    return Positioned(
      top: height,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          widget.cancelLogin?.call();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          // width: 36,
          // height: 44,
          width: 45.w,
          height: 45.w,
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 16.w),
          child: img,
        ),
      ),
    );
  }

  @override
  void dispose() {
    provider.loginType = LoginType.oneKey;
    super.dispose();
  }

  _backBtn(BuildContext context) {
    final isHalf = widget.type == LoginPageType.half;
    var height = isHalf ? 12.5.w : MediaQuery.of(context).padding.top + 10.0.h;
    final pages =
        context.select<LoginProvider, List<LoginType>>((value) => value.pages);
    final loginType =
        context.select<LoginProvider, LoginType>((value) => value.loginType);
    return Positioned(
      left: 0,
      top: height,
      child: Offstage(
        offstage: loginType == LoginType.wx || loginType == LoginType.oneKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (loginType == LoginType.phone) {
              provider.updateLoginType(LoginType.wx);
            }
          },
          child: Container(
            width: 45,
            height: 45,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/home/icon_back.png",
              width: 16,
              height: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _checkBox() {
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
}
