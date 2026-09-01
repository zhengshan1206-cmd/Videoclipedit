import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';

class AiSamplePlayPage extends StatelessWidget {
  const AiSamplePlayPage({
    super.key,
    required this.videoUrl,
  });

  final String videoUrl;

  @override
  Widget build(BuildContext context) {
    log("1111=====");
    return Scaffold(
      backgroundColor: const Color(0xFF090A0B).withOpacity(0.0),
      body: PopScope(child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ByNavRouterUtils.goBack(context);
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: AiVideoPlayer(
                  videoUrl: videoUrl,
                  autoPlay: true,
                ),
              ),
            ),
            Positioned(
              left: 12.w,
              top: (kToolbarHeight - 32) * 0.5,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ByNavRouterUtils.goBack(context);
                },
                child: ByWidgetsUtil.svgAsset(
                  filePath: "assets/ai/clip/ai_clip_sample_preview_back.svg",
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          ],
        ),
      ),canPop: false,)
    );
  }
}
