import 'package:flutter/material.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';

/// 用于控制全局警告框弹出
class ByDialogUtil {
  /// 弹出返回确认警告框
  /// [context] 当前上下文
  /// [contents] 警告框的内容
  /// [title] 警告框标题
  /// [confirmBtnTitle] 确认按钮文本
  /// [confirmCallback] 确认按钮回调
  /// [cancelBtnTitle] 取消按钮文本
  /// [cancelCallback] 取消按钮回调
  static Future<bool?> showPopScopeDialog({
    required BuildContext context,
    String? contents,
    String? title,
    String? confirmBtnTitle,
    Function? confirmCallback,
    String? cancelBtnTitle,
    Function? cancelCallback,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return CommonDialog(
          contents: contents ?? "现在返回将中断提取，是否继续退出?",
          title: title,
          confirmBtnTitle: confirmBtnTitle ?? "退出",
          confirmCallback: confirmCallback,
          cancelBtnTitle: cancelBtnTitle,
          cancelCallback: cancelCallback,
          maxLine: 10,
          reverse: false,
        );
      },
    );
  }
}
