import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

enum VideoClipHandleStatus { parsing, done }

class VideoHandlePage extends StatefulWidget {
  const VideoHandlePage({super.key});

  @override
  State<VideoHandlePage> createState() => _VideoHandlePageState();
}

class _VideoHandlePageState extends State<VideoHandlePage> {
  final TapGestureRecognizer _gestureRecognizer = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _gestureRecognizer.onTap = () {
      byDebugPrint("go to task center", tag: "VideoHandlePage:");
    };
  }

  @override
  void dispose() {
    super.dispose();
    _gestureRecognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.WhiteColor,
      appBar: ByWidgetsUtil.appBar(context: context, title: ""),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 153.h),
            Image.asset(
              "assets/common/loading_large.gif",
              width: 120.w,
              height: 124.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 45.h),
            ByWidgetsUtil.commonRichText(
              texts: [
                const TextSpan(text: "视频正在去重处理中···"),
              ],
              fontSize: 15.sp,
            ),
            const Spacer(),
            ByWidgetsUtil.commonText(
              text: "稍后可在“最近任务”中查看",
              fontSize: 15.sp,
            ),
            SizedBox(height: 30.h + ByScreenUtils.bottomSafeHeight),
          ],
        ),
      ),
    );
  }
}
