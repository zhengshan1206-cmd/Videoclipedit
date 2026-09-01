import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

class NoDataView extends StatelessWidget {
  final RichText? desc;
  final void Function()? onTap;
  final double? gap;
  const NoDataView({
    super.key,
    this.desc,
    this.onTap,
    this.gap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      color: ByColorUtil.WhiteColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/mine/mine_no_data.png",
            width: 180.w,
            height: 100.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: gap ?? 30.h),
          desc ??
              RichText(
                text: TextSpan(
                    text: "暂无内容，",
                    style: TextStyle(
                      color: ByColorUtil.CommonTextColor,
                      fontSize: 12.sp,
                    ),
                    children: [
                      TextSpan(
                        text: "去创作",
                        style: TextStyle(
                          color: ByColorUtil.TabTextColorSelected,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            onTap?.call();
                          },
                      ),
                    ]),
              ),
        ],
      ),
    );
  }
}
