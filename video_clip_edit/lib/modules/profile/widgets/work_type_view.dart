import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

// enum WorkType {

// }

class WorkTypeView extends StatelessWidget {
  final String typeName;
  const WorkTypeView({
    super.key,
    required this.typeName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.w,
      height: 24.h,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(12.h),
              topLeft: Radius.circular(12.h)),
          color: const Color(0xFF000000).withOpacity(0.3)),
      alignment: Alignment.center,
      child: Text(
        typeName,
        style: TextStyle(
          color: ByColorUtil.WhiteColor,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
