import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/minorMode/beans/minor_page_type.dart';
import 'package:video_clip_edit/v2/minorMode/minor_mode_block_reason.dart';

/// 禁用时段或使用时长超限时，拦截首页列表点击的提示弹窗。
class MinorModeDisabledPeriodDialog extends StatelessWidget {
  const MinorModeDisabledPeriodDialog({super.key, required this.reason});

  final MinorModeBlockReason reason;

  static Future<void> show({required MinorModeBlockReason reason}) {
    if (Get.isDialogOpen == true) return Future.value();
    return Get.dialog<void>(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: MinorModeDisabledPeriodDialog(reason: reason),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }

  String get _title => switch (reason) {
    MinorModeBlockReason.disabledPeriod => '禁用时段提示',
    MinorModeBlockReason.usageLimit => '使用时长已达上限',
  };

  String get _message => switch (reason) {
    MinorModeBlockReason.disabledPeriod => '当前处于未成年人禁用时段，请输入密码退出未成年模式',
    MinorModeBlockReason.usageLimit => '今日使用时长已达上限，请输入密码退出未成年模式',
  };

  void _exitMinorMode() {
    Get.back();
    Get.toNamed(
      Routes.minorCreatePage,
      arguments: MinorCreateRouteArgs(
        pageType: MinorPageType.enterPassword,
        verifyIntent: MinorVerifyIntent.closeMinorMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
          decoration: BoxDecoration(
            color: ByColorUtil.WhiteColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: ByColorUtil.CommonTextColor.withOpacity(0.45),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              ByWidgetsUtil.commonText(
                text: _title,
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                textColor: ByColorUtil.CommonTextColor,
              ),
              SizedBox(height: 16.h),
              ByWidgetsUtil.commonText(
                text: _message,
                fontSize: 14.sp,
                textAlign: TextAlign.center,
                maxLines: 3,
                textColor: ByColorUtil.CommonTextColor.withOpacity(0.75),
              ),
              SizedBox(height: 28.h),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44.h,
                      child: ByWidgetsUtil.commonBtn(
                        title: '取消',
                        fontSize: 15.sp,
                        borderRadius: 22.r,
                        bgColor: const Color(0xFF0E1840).withOpacity(0.3),
                        textColor: ByColorUtil.WhiteColor,
                        fontWeight: FontWeight.w600,
                        onClick: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SizedBox(
                      height: 44.h,
                      child: ByWidgetsUtil.commonBtn(
                        title: '退出未成年模式',
                        fontSize: 13.sp,
                        borderRadius: 22.r,
                        bgColor: ByColorUtil.LoginBtnBgColor,
                        textColor: ByColorUtil.WhiteColor,
                        fontWeight: FontWeight.w600,
                        onClick: _exitMinorMode,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
