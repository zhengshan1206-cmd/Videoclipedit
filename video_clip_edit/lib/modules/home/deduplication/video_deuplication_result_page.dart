import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class VideoDeuplicationResultPage extends StatelessWidget {
  const VideoDeuplicationResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "视频去重"),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Column(
        children: [
          SizedBox(height: 63.h),
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: Colors.red[100],
                ),
                Positioned.fill(
                    child: Center(
                  child: SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: Image.asset("assets/home/icon_audio_play.png"),
                  ),
                ))
              ],
            ),
          ),
          SizedBox(height: 63.h),
          Container(
            color: ByColorUtil.WhiteColor,
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              top: 8.h,
              bottom: 8.h + ByScreenUtils.bottomSafeHeight,
            ),
            child: ByWidgetsUtil.commonBtn(
              title: "保存到相册",
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              borderRadius: 12.w,
              onClick: () {},
            ),
          ),
        ],
      ),
    );
  }
}
