import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class AiVideoGeneratingPage extends StatelessWidget {
  const AiVideoGeneratingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: "视频详情",
        showBottmLine: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: ByWidgetsUtil.commonTipsBar(
              "内容由AI生成仅供参考，禁止利用功能从事违法活动。",
            ),
          ),
          SizedBox(height: 190.h),
          Container(
            alignment: Alignment.center,
            child: Image.asset(
              "assets/common/loading_large.gif",
              width: 120.w,
              height: 124.h,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 40.h),
          ByWidgetsUtil.commonText(
            text: "视频生成中，请耐心等待",
            textColor: ByColorUtil.CommonTextColor,
            fontSize: 14.sp,
          ),
        ],
      ),
    );
  }
}
