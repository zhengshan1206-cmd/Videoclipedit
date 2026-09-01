//  description:  倒计时按钮

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/providers/login_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

const String _normalText = '获取验证码'; // 默认按钮文字
const String _resendAfterText = '重新获取'; // 重新获取文字
const int _normalTime = 60; // 默认倒计时时间
const double _fontSize = 16.0; // 文字大小
const double _borderRadius = 12.0; // 边框圆角

class CountDownBtn extends StatefulWidget {
  const CountDownBtn({
    super.key,
    this.getVCode,
    this.getCodeText = _normalText,
    this.resendAfterText = _resendAfterText,
    this.textColor,
    this.bgColor,
    this.fontSize = _fontSize,
    this.borderColor,
    this.borderRadius = _borderRadius,
    this.showBorder = false,
    this.onTap,
    this.couldSendCode = false,
  });

  final void Function({
    void Function(dynamic)? onSuccess,
    void Function(int, String)? onFaild,
  })? getVCode;
  final String getCodeText;
  final String resendAfterText;
  final Color? textColor;
  final Color? bgColor;
  final double? fontSize;
  final Color? borderColor;
  final double? borderRadius;
  final bool showBorder;
  final Function()? onTap;
  final bool couldSendCode;




  @override
  State<CountDownBtn> createState() => _CountDownBtnState();
}

class _CountDownBtnState extends State<CountDownBtn> {
  Timer? _countDownTimer;
  String _btnStr = _normalText;
  int _countDownNum = _normalTime;

  @override
  void initState() {
    super.initState();

    _btnStr = widget.getCodeText;
  }

  /// 释放掉Timer
  @override
  void dispose() {
    _countDownTimer?.cancel();
    _countDownTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  _body() {
    return Consumer<LoginProvider>(builder: (context, provider, child) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.onTap?.call();
          _getVCode();
        },
        child: Container(
          height: 50.h,
          width: 80.w,
          alignment: Alignment.center,
          // padding: EdgeInsets.symmetric(horizontal: 25.w),
          decoration: BoxDecoration(
            color: (provider.vCodeBtnEnabled||widget.couldSendCode)
                ? ByColorUtil.TabTextColorSelected
                : ByColorUtil.LoginBtnBgColor.withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12.0),
              bottomRight: Radius.circular(12.0),
            ),
          ),
          child: Text(
            _btnStr,
            style: TextStyle(
              fontSize: widget.fontSize,
              color: const Color(0xFFF3F3F5),
            ),
          ),
        ),
      );
    });

    // if (widget.getVCode == null) {
    //   return Container();
    // } else {
    //   return Consumer<LoginProvider>(builder: (context, provider, child) {
    //     return GestureDetector(
    //       behavior: HitTestBehavior.opaque,
    //       onTap: () => _getVCode(),
    //       child: Container(
    //         height: 45.h,
    //         width: 80.w,
    //         alignment: Alignment.center,
    //         // padding: EdgeInsets.symmetric(horizontal: 25.w),
    //         decoration: BoxDecoration(
    //           color: provider.vCodeBtnEnabled
    //               ? ByColorUtil.TabTextColorSelected
    //               : ByColorUtil.LoginBtnBgColor.withOpacity(0.3),
    //           borderRadius: const BorderRadius.only(
    //             topRight: Radius.circular(12.0),
    //             bottomRight: Radius.circular(12.0),
    //           ),
    //         ),
    //         child: Text(
    //           _btnStr,
    //           style: TextStyle(
    //             fontSize: widget.fontSize,
    //             color: const Color(0xFFF3F3F5),
    //           ),
    //         ),
    //       ),
    //     );
    //   });
    // }
  }

  _getVCode() {
    final provider = Provider.of<LoginProvider>(context, listen: false);

    if (provider.vCodeBtnEnabled == false) return;
    provider.vCodeBtnEnabled = false;
    if (!provider.checkVCodeBtnEnabled()) return;
    provider.getVCode(
      onSuccess: (_) {
        startCountdown();
      },
      onFailed: (p0, p1) {
        provider.vCodeBtnEnabled = true;
      },
    );
    // if (widget.getVCode != null) {
    //   widget.getVCode!(
    //     onSuccess: (data) {},
    //     onFaild: (code, msg) {},
    //   );
    // }
  }

  /// 开始倒计时
  void startCountdown() {
    setState(() {
      if (_countDownTimer != null) {
        return;
      }
      // Timer的第一秒倒计时是有一点延迟的，为了立刻显示效果可以添加下一行。
      // _btnStr = '重新获取(${_countDownNum--}s)';
      _btnStr = '${_countDownNum--}s';
      _countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_countDownNum > 0) {
            // _btnStr = '重新获取(${_countDownNum--}s)';
            _btnStr = '${_countDownNum--}s';
          } else {
            // _btnStr = _normalText;
            _btnStr = widget.resendAfterText;
            _countDownNum = _normalTime;
            _countDownTimer?.cancel();
            _countDownTimer = null;
            final provider = Provider.of<LoginProvider>(context, listen: false);
            provider.vCodeBtnEnabled = true;
          }
        });
      });
    });
  }
}
