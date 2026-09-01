import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

class CountDownConfig {
  Color timeItemBgColor;
  Color textColor;
  double fontSize;
  double separatorFontSize;
  Color separatorTextColor;
  double separatorPadding;
  double timeItemWidh;
  double timeItemBorderRadius;
  DateTime dateTime;
  // String hour;
  // String mins;
  // String seconds;

  CountDownConfig({
    Color? timeItemBgColor,
    Color? textColor,
    double? fontSize,
    double? separatorFontSize,
    Color? separatorTextColor,
    double? separatorPadding,
    double? timeItemWidh,
    double? timeItemBorderRadius,
    DateTime? dateTime,
    // String? hour,
    // String? mins,
    // String? seconds,
  })  : timeItemBgColor =
            timeItemBgColor ?? ByColorUtil.WhiteColor.withOpacity(0.9),
        textColor = textColor ?? ByColorUtil.PurchaseTagNewBgColor,
        fontSize = fontSize ?? 16.sp,
        separatorFontSize = separatorFontSize ?? 16.sp,
        separatorTextColor =
            separatorTextColor ?? ByColorUtil.PurchaseTagNewBgColor,
        separatorPadding = separatorPadding ?? 3.w,
        timeItemWidh = timeItemWidh ?? 20.w,
        timeItemBorderRadius = timeItemBorderRadius ?? 4.w,
        dateTime = dateTime ?? DateTime.now()
  // hour = hour ?? "00",
  // mins = mins ?? "00",
  // seconds = seconds ?? "00"
  ;
}
