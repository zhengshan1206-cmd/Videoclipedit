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
        (p) => p.vipSpecialBean?.countdown ?? 600);
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: ByWidgetsUtil.gradientBgContainer(
            borderRadius: 6.w,
            padding: EdgeInsets.only(
              top: 4.w,
              left: 40.w,
              right: 4.w,
              bottom: 4.w,
            ),
            gradient: ByColorUtil.lineareGradient(
              end: Alignment.topLeft,
              begin: Alignment.bottomRight,
              colorEnd: const Color(0xFFFCDB32),
              colorStart: const Color(0xFFF9A84A),
            ),
            child: CountDownView(
              config: CountDownConfig(
                dateTime: now.add(Duration(seconds: countdown)),
                fontSize: 12.sp,
                separatorFontSize: 12.sp,
                separatorTextColor: ByColorUtil.WhiteColor,
                timeItemBgColor: ByColorUtil.WhiteColor.withOpacity(0.9),
              ),
            ),
          ),
        ),
        Positioned(
          left: 3.w,
          child: Image.asset(
            "assets/purchase/icon_clock.png",
            width: 34.w,
            height: 34.h,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
