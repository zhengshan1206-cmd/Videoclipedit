import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class AudioProhibitedWordsDailog extends StatelessWidget {
  const AudioProhibitedWordsDailog({super.key});

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
                    text: "温馨提示",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 43.w),
                    child: ByWidgetsUtil.commonText(
                      fontSize: 14.sp,
                      textAlign: TextAlign.center,
                      text: "请修改敏感词后提交。",
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: ByWidgetsUtil.commonBtn(
                      title: "确定",
                      fontSize: 16.sp,
                      borderRadius: 12.w,
                      fontWeight: FontWeight.bold,
                      onClick: () {},
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
