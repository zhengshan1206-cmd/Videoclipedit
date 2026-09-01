import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class CustomFooter extends Footer {
  final void Function() onClick;
  CustomFooter({
    required this.onClick,
  }) : super(
          triggerOffset: 10.0, // 触发刷新的偏移量
          clamping: true, // 限制回弹
          position: IndicatorPosition.locator, // 让 Footer 处于列表底部
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    if (state.result == IndicatorResult.noMore) {
      /// 没有更多数据时，显示 "查看更多" 按钮
      return Container(
        width: 120.w,
        height: 32.h,
        margin: EdgeInsets.only(bottom: 10.h),
        child: ByWidgetsUtil.commonBtn(
          borderWidth: 1,
          fontSize: 14.sp,
          borderRadius: 50,
          title: "点击查看更多",
          padding: EdgeInsets.zero,
          fontWeight: FontWeight.normal,
          bgColor: ByColorUtil.WhiteColor,
          textColor: ByColorUtil.LoginBtnBgColor,
          borderColor: ByColorUtil.LoginBtnBgColor,
          onClick: onClick,
        ),
      );
    } else {
      // 加载完成后显示
      return const ClassicFooter(
        position: IndicatorPosition.locator, // 让 Footer 处于底部
      ).build(context, state);
    }
  }
}
