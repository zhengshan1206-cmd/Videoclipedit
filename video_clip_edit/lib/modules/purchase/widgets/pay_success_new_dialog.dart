import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';

class PaySuccessNewDialog extends StatefulWidget {
  PaySuccessNewDialog({
    super.key,
    this.title,
    this.isFromIntegral = false,
    this.onAddBtnTap,
    this.onCloseBtnTap,
  });

  final String? title;
  final bool isFromIntegral;
  final VoidCallback? onAddBtnTap;
  final VoidCallback? onCloseBtnTap;

  @override
  State<PaySuccessNewDialog> createState() => _PaySuccessNewDialogState();
}

class _PaySuccessNewDialogState extends State<PaySuccessNewDialog> {
  final UserController userController = Get.find<UserController>();
  Timer? _timer;
  int _currentCountdown = 0;
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    _initializeCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 初始化倒计时
  void _initializeCountdown() {
    _currentCountdown = userController.payJumpCountdown;
    if (_currentCountdown > 0) {
      _startCountdown();
    } else {
      _canClose = true;
    }
  }

  /// 开始倒计时
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentCountdown > 0) {
        setState(() {
          _currentCountdown--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _canClose = true;
        });
      }
    });
  }

  /// 关闭对话框
  void _closeDialog() {
    if (_canClose) {
      // 调用关闭按钮回调
      widget.onCloseBtnTap?.call();
      Get.back();
    }
  }

  /// 点击图片跳转
  void _onImageTap() {
    // 调用立即添加按钮回调
    widget.onAddBtnTap?.call();
    // Get.back();
    if (userController.payJumpUrl.isNotEmpty) {
      ///跳转外链
      ByNavRouterUtils.jumpWebViewPage(
        context,
        "咨询",
        userController.payJumpUrl,
      );
    }
  }

  ///倒计时组件
  Widget _countdownWidget() {
    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32.w),
        border: Border.all(
          color: Colors.white,
          width: 1.w,
        ),
      ),
      child: Center(
        child: Text(
          "${_currentCountdown}s",
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFFFFFBFF),
          ),
        ),
      ),
    );
  }

  ///关闭按钮
  Widget _closeButton() {
    return GestureDetector(
      onTap: _closeDialog,
      child: Image.asset(
        "assets/purchase/dailog_bonus_close.png",
        width: 32.w,
        height: 32.h,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canClose,
      onPopInvoked: (didPop) {
        if (!didPop && !_canClose) {
          // 如果倒计时未结束，阻止关闭
          return;
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _onImageTap,
            child: Image.network(
              userController.payJumpImage,
              width: 320.w,
              fit: BoxFit.fitWidth,
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: Center(
              child:
                  _currentCountdown > 0 ? _countdownWidget() : _closeButton(),
            ),
          )
        ],
      ),
    );
  }
}
