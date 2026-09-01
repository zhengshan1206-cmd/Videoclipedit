import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/providers/video_erase_provider.dart';
import 'package:video_clip_edit/modules/home/erase/picture_erase_result_page.dart';

enum VideoHandlePageType { video, picture }

class VideoHandlePage extends StatefulWidget {
  final VideoHandlePageType type;
  const VideoHandlePage({
    super.key,
    required this.type,
  });

  @override
  State<VideoHandlePage> createState() => _VideoHandlePageState();
}

class _VideoHandlePageState extends State<VideoHandlePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      ByNavRouterUtils.pushReplacement(
        context,
        ChangeNotifierProvider.value(
          value: context.read<VideoEraseProvider>(),
          child: const PictureEraseResultPage(asset: null),
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
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
                TextSpan(
                    text:
                        "${widget.type == VideoHandlePageType.video ? "视频" : "图片"}正在擦除处理中···"),
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
