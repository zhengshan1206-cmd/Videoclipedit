import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

typedef CommonAlertDialogConfirmCallback = void Function(BuildContext);

class CommonAlertDialog extends StatelessWidget {
  final String contents;
  final String? title;
  final String? confirmBtnTitle;
  final bool? showCancel;
  final String? cancelBtnTitle;
  final CommonAlertDialogConfirmCallback? confirmCallback;
  final CommonAlertDialogConfirmCallback? cancelCallback;
  final BuildContext? pageContext;
  final int? manLine;
  const CommonAlertDialog({
    super.key,
    required this.contents,
    this.title,
    this.confirmBtnTitle,
    this.confirmCallback,
    this.showCancel,
    this.cancelBtnTitle,
    this.cancelCallback,
    this.pageContext,
    this.manLine,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 28.w),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: ByColorUtil.WhiteColor,
                  borderRadius: BorderRadius.circular(18.w)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 60.h),
                  ByWidgetsUtil.commonText(
                    text: title ?? "温馨提示",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 43.w),
                    child: ByWidgetsUtil.commonText(
                      fontSize: 14.sp,
                      maxLines: manLine ?? 3,
                      textAlign: TextAlign.center,
                      text: contents,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: (showCancel ?? false)
                        ? Row(
                            children: [
                              Expanded(
                                child: ByWidgetsUtil.commonBtn(
                                  title: cancelBtnTitle ?? "取消",
                                  padding: EdgeInsets.symmetric(vertical: 15.h),
                                  fontSize: 16.sp,
                                  borderRadius: 12.w,
                                  bgColor:
                                      const Color(0xFF0E1840).withOpacity(0.3),
                                  textColor: ByColorUtil.WhiteColor,
                                  fontWeight: FontWeight.bold,
                                  onClick: () {
                                    ByNavRouterUtils.goBack(context);

                                    cancelCallback
                                        ?.call(pageContext ?? context);
                                  },
                                ),
                              ),
                              SizedBox(width: 25.w),
                              Expanded(
                                child: ByWidgetsUtil.commonBtn(
                                  title: confirmBtnTitle ?? "确定",
                                  padding: EdgeInsets.symmetric(vertical: 15.h),
                                  fontSize: 16.sp,
                                  borderRadius: 12.w,
                                  fontWeight: FontWeight.bold,
                                  onClick: () {
                                    ByNavRouterUtils.goBack(context);

                                    confirmCallback
                                        ?.call(pageContext ?? context);
                                  },
                                ),
                              ),
                            ],
                          )
                        : ByWidgetsUtil.commonBtn(
                            title: confirmBtnTitle ?? "确定",
                            fontSize: 16.sp,
                            borderRadius: 12.w,
                            fontWeight: FontWeight.bold,
                            onClick: () {
                              ByNavRouterUtils.goBack(context);
                              confirmCallback?.call(pageContext ?? context);
                            },
                          ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          Positioned(
            top: -25.h,
            left: ByScreenUtils.screenWidth * 0.5 - 30.w,
            child: Image.asset(
              "assets/home/icon_bell.png",
              width: 60.w,
              height: 60.w,
            ),
          ),
        ],
      ),
    );
  }
}
