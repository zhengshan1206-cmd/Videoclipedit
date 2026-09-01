import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/routes/route_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

enum VideoClipHandleStatus { parsing, done }

class VideoClipHandlePage<T extends MaterialBaseProvider>
    extends StatefulWidget {
  const VideoClipHandlePage({super.key});

  @override
  State<VideoClipHandlePage<T>> createState() => _VideoClipHandlePageState<T>();
}

class _VideoClipHandlePageState<T extends MaterialBaseProvider>
    extends State<VideoClipHandlePage<T>> {
  final TapGestureRecognizer _gestureRecognizer = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _gestureRecognizer.onTap = () {
      // ByNavRouterUtils.jumpWebViewPage(context, "",
      //     context.read<LaunchProvider>().launchInfo?.config.privacy ?? "");
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
                const TextSpan(text: "视频制作中，稍后在"),
                TextSpan(
                  text: "我的任务",
                  style: const TextStyle(
                    color: ByColorUtil.TabTextColorSelected,
                  ),
                  recognizer: _gestureRecognizer,
                ),
                const TextSpan(text: "中查看"),
              ],
              fontSize: 12.sp,
            ),
            const Spacer(),
            ByWidgetsUtil.outlinedBtn(
              padding: EdgeInsets.symmetric(
                horizontal: 30.w,
                vertical: 5.h,
              ),
              title: "去创作",
              onClick: () {
                RouteUtils.gotoPage(context, "/voideCreate");
              },
            ),
            SizedBox(height: 30.h + ByScreenUtils.bottomSafeHeight),
          ],
        ),
      ),
    );
  }
}
