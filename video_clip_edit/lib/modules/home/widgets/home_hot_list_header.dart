import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

class HomeHotListHeader extends StatelessWidget {
  const HomeHotListHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          "assets/home/home_hot.png",
          width: 20.w,
          height: 20.w,
        ),
        SizedBox(width: 6.w),
        Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 70.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: ByColorUtil.HomeHotAuthTitleBg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(2.h),
                    bottomLeft: Radius.circular(2.h),
                    bottomRight: Radius.circular(2.h),
                    topRight: Radius.circular(6.h),
                  ),
                ),
              ),
            ),
            Text(
              "热门短剧",
              style: TextStyle(
                fontSize: 16.sp,
                color: ByColorUtil.MainTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
      ],
    );
  }
}
