import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/core/util/fonts.dart';

class MinorFormSection extends StatelessWidget {
  const MinorFormSection({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BYText.instance(
          title,
          16.sp,
          fontWeight: BYFontWeight.semiBold,
          color: const Color(0xFF0B1843),
        ),
        SizedBox(height: 6.h),
        BYText.instance(
          description,
          12.sp,
          color: const Color(0xFF697088),
          height: 1.4,
        ),
        SizedBox(height: 12.h),
        child,
      ],
    );
  }
}
