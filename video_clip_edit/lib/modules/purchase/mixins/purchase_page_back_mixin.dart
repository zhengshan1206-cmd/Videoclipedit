import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/providers/ios_purchase_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';

/// 付费页返回逻辑 Mixin
/// 用于统一处理付费页的返回拦截和挽留弹窗逻辑
mixin PurchasePageBackMixin<T extends StatefulWidget> on State<T> {
  /// 获取 UserController
  UserController get userController => Get.find<UserController>();

  /// 处理返回逻辑
  /// [onPay] 支付回调
  /// [onGoBack] 直接返回的回调（可选，默认使用 _defaultGoBack）
  /// 是否弹出挽留弹窗由缓存与 maxShowLimit 控制，与 closeBtnType 无关
  Future<void> handlePurchasePageBack({
    required BuildContext context,
    required VoidCallback onPay,
    void Function()? onGoBack,
  }) async {
    // 检查是否是VIP用户
    if (userController.user.value?.isVip == 1) {
      if (onGoBack != null) {
        onGoBack();
      } else {
        _defaultGoBack(context);
      }
      return;
    }

    /// 仅执行返回（关闭会员页），仅在「无挽留弹窗可展示」时由 triggerRetentionDialog 内部调用
    void doClose() {
      if (onGoBack != null) {
        onGoBack();
      } else {
        _defaultGoBack(context);
      }
    }

    /// 触发支付挽留弹窗（是否展示由 popConfigList + 当日缓存 + maxShowLimit 决定）
    if (Platform.isIOS) {
      final iosProvider = context.read<IosPurchaseProvider>();
      iosProvider.triggerRetentionDialog(
        context: context,
        onPay: onPay,
        onImageTap: () {},
        onClose: doClose,
      );
    } else {
      final androidProvider = context.read<PurchaseProvider>();
      androidProvider.triggerRetentionDialog(
        context: context,
        onPay: onPay,
        onImageTap: () {},
        onClose: doClose,
      );
    }

    // // 新版本逻辑3.10.41
    // // 如果已经关闭过挽留弹窗，直接返回
    // if (hasClosedRetentionDialog) {
    //   if (onGoBack != null) {
    //     onGoBack();
    //   } else {
    //     _defaultGoBack(context);
    //   }
    //   return;
    // }

    // if (userController.retentionPackageId.isNotEmpty &&
    //     userController.retentionPopupImage.isNotEmpty &&
    //     userController.user.value?.needRetentionPop == 1) {
    //   ///触发支付挽留弹窗
    //   if (Platform.isIOS) {
    //     final iosProvider = context.read<IosPurchaseProvider>();
    //     iosProvider.triggerRetentionDialog(
    //       context: context,
    //       onPay: onPay,
    //       onImageTap: () {
    //         _defaultGoBack(context);
    //       },
    //       onClose: () {
    //         _defaultGoBack(context);
    //       },
    //     );
    //   } else {
    //     final androidProvider = context.read<PurchaseProvider>();
    //     androidProvider.triggerRetentionDialog(
    //       context: context,
    //       onPay: onPay,
    //       onImageTap: () {
    //         _defaultGoBack(context);
    //       },
    //       onClose: () {
    //         _defaultGoBack(context);
    //       },
    //     );
    //   }
    // } else {
    //   if (onGoBack != null) {
    //     onGoBack();
    //   } else {
    //     _defaultGoBack(context);
    //   }
    // }
  }

  /// 默认的返回逻辑
  void _defaultGoBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    } else {
      Get.offNamed(Routes.main);
    }
  }
}
