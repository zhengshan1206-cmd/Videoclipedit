// 当需要拦截手机物理返回键点击事件
// 或者需要截手机屏幕边缘返回手势事件时
// 可以在需要的组件外层包裹此组件

import 'package:flutter/material.dart';
import 'package:video_clip_edit/utils/comon/by_dialog_util.dart';

class PopScopeWidget extends StatelessWidget {
  const PopScopeWidget({
    super.key,
    required this.child,
    this.contents,
    this.title,
    this.confirmBtnTitle,
    this.confirmCallback,
    this.cancelBtnTitle,
    this.cancelCallback,
    this.whiteList,
    this.canPop = false,
  });

  /// 子组件
  final Widget child;

  /// 拦截警告框的内容
  final String? contents;

  /// 拦截警告框的标题
  final String? title;

  /// 拦截警告框的确认按钮标题
  final String? confirmBtnTitle;

  /// 拦截警告框的确认按钮点击事件
  final Function? confirmCallback;

  /// 拦截警告框的取消按钮的标题
  final String? cancelBtnTitle;

  /// 拦截警告框的取消按钮点击事件
  final Function? cancelCallback;

  /// 放行的白名单，当为true时，直接返回
  final bool Function()? whiteList;


  ///能否滑动返回
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) async {
        /// didPop 为 true 时直接返回
        if (didPop) return;

        /// 在白名单内时直接返回
        final inWhiteList = whiteList?.call() ?? false;
        if (inWhiteList) return;

        /// 弹出拦截警告框
        final navigator = Navigator.of(context);
        final shouldPop = await ByDialogUtil.showPopScopeDialog(
              context: context,
              contents: contents ?? "现在返回将中断提取，是否继续退出?",
              title: title,
              confirmBtnTitle: confirmBtnTitle ?? "退出",
              confirmCallback: confirmCallback,
              cancelBtnTitle: cancelBtnTitle,
              cancelCallback: cancelCallback,
            ) ??
            false;

        /// 如果 shouldPop 为 true，则pop回上个页面
        if (shouldPop) {
          navigator.pop(shouldPop);
        }
      },
      child: child,
    );
  }
}
