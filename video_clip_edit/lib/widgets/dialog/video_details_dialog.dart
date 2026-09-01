import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/comon/by_colors.dart';
import '../../utils/comon/by_widgets_util.dart';

///视频详情相关页面的弹窗
class VideoDetailsDialog extends StatelessWidget {
  final String iconPath;
  final String proTitle;
  final String btnName;
  final VoidCallback btnClickEvent;
  const VideoDetailsDialog({
    super.key,
    required this.iconPath,
    required this.proTitle,
    required this.btnName,
    required this.btnClickEvent,
  });
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        margin: EdgeInsets.only(left: 25.5.w, right: 25.5.w),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18.w)),
        child: Column(
          children: [
            // Image.asset(iconPath,width: 70.w,height: 70.w,),
            SizedBox(
              height: 60.w,
            ),
            Text(
              proTitle,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: const Color(0XFF0B1843)),
            ),
            SizedBox(height: 10.w,),
            ByWidgetsUtil.commonRichText(
              texts: [
                 TextSpan(
                    text: "发布前需要先下载视频到您的手机，同时为保障您的收益，有效规避作品违规风险，请您务必观看并学习",
                    style: TextStyle(
                      color: Color(0XFF0B1843),
                      fontSize: 14.sp
                    )
                 ),
                TextSpan(
                  text: "[快手推广教程]",
                  style: const TextStyle(
                    color: ByColorUtil.TabTextColorSelected,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ],
              fontSize: 12.sp,
              textColor: ByColorUtil.LoginTextfieldTextColor.withOpacity(0.6),
            ),
            GestureDetector(
              onTap: btnClickEvent,
              child: Container(
                decoration: BoxDecoration(
                  color:ByColorUtil.TabTextColorSelected,
                  borderRadius: BorderRadius.circular(12.w),
                ),
                child: Text(btnName,style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600
                ),),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
