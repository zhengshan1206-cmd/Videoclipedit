import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class AiOralLinkPasteDialog extends StatelessWidget {
  const AiOralLinkPasteDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20.h, width: double.infinity),
              ByWidgetsUtil.commonText(
                text: "输入链接",
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 42.h),
              SizedBox(
                height: 200.h,
                child: ByWidgetsUtil.commonContainer(
                  borerRadius: 12.w,
                  bgColor: const Color(0xFFECF1F3),
                  child: TextField(
                    maxLines: null,
                    expands: true,
                    cursorColor: ByColorUtil.CommonTextColor,
                    // cursorHeight: 16.sp,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 20 - 8.sp),
                      border: InputBorder.none,
                      labelStyle: TextStyle(
                        fontSize: 16.sp,
                        color: ByColorUtil.CommonTextColor,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 16.sp,
                        color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                      ),
                      hintText: "粘贴链接",
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25.h),
              SizedBox(
                height: 50.h,
                child: ByWidgetsUtil.commonBtn(
                  title: "确定",
                  fontSize: 16.sp,
                  borderRadius: 12.w,
                  fontWeight: FontWeight.w500,
                  onClick: () {},
                ),
              ),
              SizedBox(
                height: 12.h +
                    ByScreenUtils.bottomSafeHeight +
                    MediaQuery.of(context).viewInsets.bottom,
              ),
            ],
          ),
        ),
        Positioned(
          top: 10.h,
          right: 0,
          child: GestureDetector(
            onTap: () {
              ByNavRouterUtils.goBack(context);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.all(15.w),
              child: Image.asset(
                "assets/ai/oralVideos/ai_oral_icon_close.png",
                width: 15,
                height: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
