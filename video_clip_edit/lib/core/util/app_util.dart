import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/widgets/common_button.dart';

class AppUtil {

  static const EXIT_APP_INTERVAL = 2000;
  static var lastClickTime = 0;

  static Future<bool> exitApp() async {
    var currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
    if (currentTimeMillis - lastClickTime > EXIT_APP_INTERVAL) {
      lastClickTime = currentTimeMillis;
      EasyLoading.showToast('再按一次退出程序', dismissOnTap: true);
      return false;
    } else {
      return true;
    }
  }
}

extension BYDialog on GetInterface {
  Future<T?> normalDialog<T>({
    required String content,
    TextAlign contentAlign = TextAlign.center,
    double? width,
    double? radius,
    double? topPadding,
    String? title,
    double? contentSize,
    Color? contentColor,
    bool showCancelBtn = true,
    String? cancelText,
    VoidCallback? cancelAction,
    String? confirmText,
    VoidCallback? confirmAction,
  }) {
    return Get.generalDialog(
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(key.currentContext!)
          .modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.4),
      pageBuilder: (context, animation, secondaryAnimation) => ScaleTransition(
        scale: animation,
        child: Center(
            child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: width ?? 320,
              margin: EdgeInsets.only(top: 30.h),
              decoration: BoxDecoration(
                color: ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(radius ?? 18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: topPadding ?? 60.h),
                  if (title != null && title.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: BYText.instance(
                        title,
                        16.sp,
                        fontWeight: BYFontWeight.semiBold,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: BYText.instance(
                      content,
                      contentSize ?? 14.sp,
                      color: contentColor ?? ByColorUtil.CommonTextColor,
                      textAlign: contentAlign,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.w),
                    child: Row(
                      children: [
                        showCancelBtn
                            ? Expanded(
                                child: CommonButton(
                                  padding: EdgeInsets.zero,
                                  borderRadius: BorderRadius.circular(12),
                                  color:
                                      ByColorUtil.CommonTextColor.withOpacity(
                                          0.3),
                                  minSize: 48,
                                  onPressed: () {
                                    Get.back();
                                    if (cancelAction != null) {
                                      cancelAction();
                                    }
                                  },
                                  child: BYText.instance(
                                    cancelText ?? '取消',
                                    16.sp,
                                    fontWeight: BYFontWeight.semiBold,
                                    color: ByColorUtil.WhiteColor,
                                  ),
                                ),
                              )
                            : Container(),
                        showCancelBtn ? SizedBox(width: 30.w) : Container(),
                        Expanded(
                          child: CommonButton(
                            padding: EdgeInsets.zero,
                            borderRadius: BorderRadius.circular(12),
                            color: ByColorUtil.LoginBtnBgColor,
                            minSize: 48,
                            onPressed: () {
                              Get.back();
                              if (confirmAction != null) {
                                confirmAction();
                              }
                            },
                            child: BYText.instance(
                              confirmText ?? '确定',
                              16.sp,
                              fontWeight: BYFontWeight.semiBold,
                              color: ByColorUtil.WhiteColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 25.h),
                ],
              ),
            ),
            Image.asset(Assets.commonIconNormalDialogTipsBg,
                width: 60.w, height: 60.h),
          ],
        )),
      ),
    );
  }

  Future<T?> customDialog<T>({
    required Widget widget,
    bool? barrierDismissible,
  }) {
    return Get.generalDialog(
      barrierDismissible: barrierDismissible ?? true,
      barrierLabel: MaterialLocalizations.of(key.currentContext!)
          .modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.4),
      pageBuilder: (context, animation, secondaryAnimation) {
        return widget;
      },
    );
  }
}

extension GlobalKeyExtension on GlobalKey {
  RelativeRect get position {
    final RenderBox renderBox = currentContext!.findRenderObject() as RenderBox;
    final buttonSize = renderBox.size;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);

    final overlay =
        Overlay.of(currentContext!).context.findRenderObject() as RenderBox;
    final overlaySize = overlay.size;

    return RelativeRect.fromLTRB(
      buttonPosition.dx,
      buttonPosition.dy,
      overlaySize.width - buttonPosition.dx - buttonSize.width,
      overlaySize.height - buttonPosition.dy - buttonSize.height,
    );
  }
}
