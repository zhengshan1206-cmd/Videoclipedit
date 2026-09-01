import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

class HotRankView extends StatelessWidget {
  final String rank;
  final Color gradientColorStart;
  final Color gradientColorEnd;
  const HotRankView({
    super.key,
    required this.rank,
    required this.gradientColorStart,
    required this.gradientColorEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45.w,
      height: 20.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.h), bottomLeft: Radius.circular(10.h)),
        gradient: LinearGradient(
          colors: [
            gradientColorStart,
            gradientColorEnd,
          ],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        rank,
        style: TextStyle(
          color: ByColorUtil.WhiteColor,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
