//  description:  倒计时按钮

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/network/provider/user_provider.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/widgets/common_button.dart';

const String _defaultText = '获取验证码'; // 默认按钮文字
const String _resendText = '重新获取'; // 重新获取文字
const int _normalTime = 60; // 默认倒计时时间
const double _fontSize = 16.0; // 文字大小

class CountDownView extends StatefulWidget {
  CountDownView({
    super.key,
    required this.phoneNum,
    this.defaultText = _defaultText,
    this.resendText = _resendText,
    this.fontSize = _fontSize,
    this.enable = false,
  });

  final String defaultText;
  final String resendText;
  final double fontSize;
  final String phoneNum;
  bool enable;

  @override
  State<CountDownView> createState() => _CountDownViewState();
}

class _CountDownViewState extends State<CountDownView> {

  UserProvider get _userProvider => Get.find<UserProvider>();

  String _changeText = _defaultText;
  Timer? _countDownTimer;
  int _countDownNum = _normalTime;
  // bool ticking = false;

  @override
  void initState() {
    super.initState();
    _changeText = widget.defaultText;
  }

  @override
  void dispose() {
    _countDownTimer?.cancel();
    _countDownTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      width: 80.w,
      child: CommonButton(
        minSize: 50.h,
        padding: EdgeInsets.zero,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12.0),
          bottomRight: Radius.circular(12.0)),
        color: /*!ticking && */widget.enable ? ByColorUtil.LoginBtnBgColor : ByColorUtil.LoginBtnBgColor.withOpacity(0.3),
        disabledColor: ByColorUtil.LoginBtnBgColor.withOpacity(0.3),
        onPressed: /*!ticking && */widget.enable ? _getVCode : null,
        child: BYText.instance(_changeText, widget.fontSize, color: const Color(0xFFF3F3F5)),
      ),
    );
  }

  _getVCode() {
    widget.enable = false;
    _userProvider.getVCode(
      phoneNum: widget.phoneNum,
      onSuccess: (_) {
        startCountdown();
        // ticking = true;
      },
      onFailed: (p0, p1) {
        setState(() {
          widget.enable = true;
          // ticking = false;
        });
      },
    );
  }

  /// 开始倒计时
  void startCountdown() {
    setState(() {
      if (_countDownTimer != null) {
        return;
      }
      // Timer的第一秒倒计时是有一点延迟的，为了立刻显示效果可以添加下一行。
      // _btnStr = '重新获取(${_countDownNum--}s)';
      _changeText = '${_countDownNum--}s';
      _countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_countDownNum > 0) {
            // _btnStr = '重新获取(${_countDownNum--}s)';
            _changeText = '${_countDownNum--}s';
          } else {
            // _btnStr = _normalText;
            _changeText = widget.resendText;
            _countDownNum = _normalTime;
            _countDownTimer?.cancel();
            _countDownTimer = null;
            widget.enable = true;
            // ticking = false;
          }
        });
      });
    });
  }
}
