/*
 * @Author: cold-x
 * @Date: 2025-05-23 10:42:38
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-15 09:07:26
 * @FilePath: /video_clip_edit/lib/modules/login/controller/login_manager.dart
 * @Description: 
 */

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:video_clip_edit/flavors/build_config.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import '../../../providers/login_provider.dart';
import '../../../utils/channel/channel_config.dart';
import '../login_page.dart';
import '../login_page_ex.dart';
import 'shanyan_login.dart';

class LoginManager {
  static void initShanYan() {
    ShanyanLogin.initShanYan();
  }

  static Future<void> showLoginPage({
    bool? onlyPhone = false,
    bool? isScrollControlled = true,
    bool? useSafeArea = false,
    VoidCallback? cancelLogin,
    VoidCallback? successLogin,
  }) async {
    if (Platform.isIOS) {
      _showLoginNormalPage(
          onlyPhone: onlyPhone,
          isScrollControlled: isScrollControlled,
          useSafeArea: useSafeArea,
          cancelLogin: cancelLogin,
          successLogin: successLogin,
          type: LoginType.phone);
      return;
    }
    bool privacy = ShanyanLogin.getDefaultAgreementChecked();
    ShanyanLogin.login(
      onSuccess: successLogin,
      loginActon: (p0) {
        _showLoginNormalPage(
            onlyPhone: onlyPhone,
            isScrollControlled: isScrollControlled,
            useSafeArea: useSafeArea,
            cancelLogin: cancelLogin,
            successLogin: successLogin,
            privacy: privacy,
            type: p0);
      },
      privacyAction: (p0) {
        privacy = p0;
      },
    );
  }

  static void _showLoginNormalPage({
    bool? onlyPhone = false,
    bool? isScrollControlled = true,
    bool? useSafeArea = false,
    LoginType? type,
    bool? privacy,
    VoidCallback? cancelLogin,
    VoidCallback? successLogin,
  }) async {
    await showGeneralDialog(
      context: Get.context!,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Platform.isAndroid
                  ? LoginPage(
                      type: LoginPageType.entire,
                      showClose: true,
                      isPlay: false,
                      loginType: type,
                      privacy: privacy,
                      cancelLogin: cancelLogin,
                      successLogin: successLogin,
                    )
                  : OnlyPhoneLoginPage(
                      closeIconTopMargin: 20.w,
                      cancelLogin: cancelLogin,
                      successLogin: successLogin,
                    ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeOutCubic.transform(animation.value);
        return Transform.translate(
          offset: Offset(0, (1 - curve) * 200),
          child: Opacity(opacity: curve, child: child
              // child: ClipRRect(
              //   borderRadius: BorderRadius.circular(curve * 20),
              //   child: child,
              // ),
              ),
        );
      },
    );
    // await showDialog(
    // context: Get.context!,
    // barrierColor: Colors.transparent,
    // useSafeArea: false,
    // barrierDismissible: true, // 点击外部是否关闭
    // builder: (BuildContext context) {
    //   return const AnimatedDialog();
    // },
    // );
    // await showDialog(
    //       // isScrollControlled: true,
    //       useSafeArea: false,
    //       context: Get.context!,
    //       barrierColor: Colors.transparent,
    //       builder: (context) => KeyboardVisibilityBuilder(
    //         builder: (context, show) {
    //           return Container(
    //             alignment: Alignment.bottomCenter,
    //             // height: 0.75.sh,
    //             child: ClipRRect(
    //               borderRadius: BorderRadius.only(
    //                 topLeft: Radius.circular(15.w),
    //                 topRight: Radius.circular(15.w),
    //               ),
    //               child: Platform.isAndroid
    //                   ? LoginPage(
    //                       type: LoginPageType.entire,
    //                       showClose: true,
    //                       isPlay: false,
    //                     )
    //                   : OnlyPhoneLoginPage(
    //                       closeIconTopMargin:  20.w,
    //                     ),
    //             ),
    //           );
    //         },
    //       ),
    //     );
  }
}

class AnimatedDialog extends StatefulWidget {
  const AnimatedDialog({
    super.key,
  });
  @override
  State<AnimatedDialog> createState() => _AnimatedDialogState();
}

class _AnimatedDialogState extends State<AnimatedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // 从底部
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Container(
          // height: double.infinity,
          // width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Center(
            child: Platform.isAndroid
                ? LoginPage(
                    type: LoginPageType.entire,
                    showClose: true,
                    isPlay: false,
                  )
                : OnlyPhoneLoginPage(
                    closeIconTopMargin: 20.w,
                  ),
          ),
        ),
      ),
    );
  }
}
