// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/guid/vip_guid_page.dart';
import 'package:video_clip_edit/modules/guid/vip_guid_page_recreate.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';

class VideoLoadingGuidPage<T extends MaterialBaseProvider>
    extends StatefulWidget {
  const VideoLoadingGuidPage({
    super.key,
    this.isRecreate = false,
  });
  final bool isRecreate;

  @override
  State<VideoLoadingGuidPage> createState() => _VideoLoadingGuidPageState<T>();
}

class _VideoLoadingGuidPageState<T extends MaterialBaseProvider>
    extends State<VideoLoadingGuidPage<T>> {
  final index = Random().nextInt(100) % 4 + 3;
  List<String> taskNames = ["音频分离", "台词解析", "配音生成", "视频合成"];
  int taskIdx = 0;
  int progress = 0;
  Timer? _timer;
  @override
  void initState() {
    super.initState();

    _parseVideos();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: "生成视频",
        onPop: () {
          ByNavRouterUtils.goBack(context);
        },
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 26.h),
            ByWidgetsUtil.commonText(
                text: "视频生成中，预计 $index 秒～",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                textColor: ByColorUtil.CommonTextColor),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              child: ByWidgetsUtil.commonContainer(
                bgColor: const Color(0xFFF8f8f8),
                borerRadius: 12.w,
                padding: EdgeInsets.symmetric(
                  horizontal: 15.w,
                  vertical: 16.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ByWidgetsUtil.commonText(
                    //   text: "1.退出不影响生成和排队",
                    //   textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                    //   fontSize: 14.sp,
                    // ),
                    // SizedBox(height: 1.h),
                    ByWidgetsUtil.commonText(
                      text: "视频剪辑所需时长与视频大小和集数有关",
                      textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                      fontSize: 14.sp,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 86.h),
            Container(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/common/loading_large.gif",
                width: 120.w,
                height: 124.h,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 43.h),
            Container(
              alignment: Alignment.center,
              child: ByWidgetsUtil.commonRichText(
                texts: [
                  TextSpan(text: "${taskNames[taskIdx]}中：当前进度"),
                  TextSpan(
                    text: "$progress%",
                    style: const TextStyle(
                      color: Color(0xFF5F51F8),
                    ),
                  ),
                ],
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                textColor: ByColorUtil.CommonTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 视频解析
  /// 1、视频合成 45%
  /// 2、提取音频 70%
  /// 3、解析音频文本 100%
  void _parseVideos() async {
    _timer = Timer.periodic(
      const Duration(milliseconds: 20),
      (timer) {
        setState(
          () {
            progress += 2;
            if (progress >= 100) {
              progress = 0;
              taskIdx += 1;
            }
            if (taskIdx == 3) {
              _timer?.cancel();
              ByNavRouterUtils.pushReplacement(
                  context,
                  widget.isRecreate
                      ? const VipGuidPageRecreate()
                      : const VipGuidPage());
            }
          },
        );
      },
    );
  }
}
