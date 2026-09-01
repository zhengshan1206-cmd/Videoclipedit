import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/purchase/beans/count_down_config.dart';
import 'package:video_clip_edit/modules/purchase/widgets/count_down_view.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class VIPCountDownWidget extends StatelessWidget {
  const VIPCountDownWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final countdown = context.select<PurchaseProvider, int>(
      (p) => p.vipSpecialBean?.countdown ?? 600,
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: ByWidgetsUtil.gradientBgContainer(
            borderRadius: 8.w,
            padding: EdgeInsets.only(
              top: 6.w,
              left: 24.w,
              right: 7.w,
              bottom: 6.w,
            ),
            gradient: ByColorUtil.lineareGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colorEnd: const Color(0xFFF5704D),
              colorStart: const Color(0xFFEF3E35),
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/purchase/img_title.png",
                  height: 15.h,
                  fit: BoxFit.fitHeight,
                ),
                SizedBox(width: 7.w),
                CountDownView(
                  config: CountDownConfig(
                    dateTime: now.add(Duration(seconds: countdown)),
                    fontSize: 14.sp,
                    timeItemWidh: 24.w,
                    timeItemBorderRadius: 4.w,
                    separatorFontSize: 14.sp,
                    separatorPadding: 3.w,
                    textColor: const Color(0xFFFFE8AA),
                    separatorTextColor: const Color(0xFFFFE8AA),
                    timeItemBgColor: const Color(0xFFBE150C).withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: -18.w,
          bottom: 0,
          height: 46.h,
          child: Image.asset(
            "assets/purchase/icon_clock.png",
            width: 34.w,
            height: 34.h,
            fit: BoxFit.fitHeight,
          ),
        ),
      ],
    );
  }
}
