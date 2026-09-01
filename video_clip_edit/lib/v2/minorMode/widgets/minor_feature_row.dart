import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/v2/minorMode/beans/minor_feature_item.dart';

class MinorFeatureRow extends StatelessWidget {
  const MinorFeatureRow({super.key, required this.item});

  final MinorFeatureItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(item.icon, width: 56.w, height: 56.w, fit: BoxFit.contain),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BYText.instance(
                item.title,
                16.sp,
                fontWeight: BYFontWeight.semiBold,
                color: const Color(0xFF0B1843),
              ),
              SizedBox(height: 8.h),
              BYText.instance(
                item.description,
                13.sp,
                color: const Color(0xFF697088),
                height: 1.5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
