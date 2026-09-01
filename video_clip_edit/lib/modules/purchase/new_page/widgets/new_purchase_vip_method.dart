import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/purchase/beans/pay_method_bean.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class NewVipMethodViewNew extends StatelessWidget {
  final PayMethodBean payMethodBean;

  ///传入颜色
  final Color? textColor;

  const NewVipMethodViewNew({
    super.key,
    required this.payMethodBean,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          payMethodBean.icon,
          width: 18.w,
          height: 18.w,
        ),
        SizedBox(width: 5.w),
        ByWidgetsUtil.commonText(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          text: payMethodBean.payName,
          textColor: textColor ?? const Color(0xFF999999).withOpacity(0.6),
        ),
      ],
    );
  }
}
