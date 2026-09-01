import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/ai_sample_play_page.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_sample_video_item.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_sample_provider.dart';

class AiClipSamplePage extends StatefulWidget {
  const AiClipSamplePage({
    super.key,
    required this.pid,
  });

  final int pid;

  @override
  State<AiClipSamplePage> createState() => _AiClipSamplePageState();
}

class _AiClipSamplePageState extends State<AiClipSamplePage> {
  final EasyRefreshController _controller = EasyRefreshController(
      controlFinishRefresh: true, controlFinishLoad: true);
  @override
  Widget build(BuildContext context) {
    final List<AiSampleVideoItemBean> sampleVideoItemBeans =
        context.select<AiClipSampleProvider, List<AiSampleVideoItemBean>>(
      (value) => value.sampleVideoItemBeans,
    );
    return Scaffold(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: "素材样片",
      ),
      body: EasyRefresh(
        refreshOnStart: true,
        controller: _controller,
        onRefresh: () {
          _loadMaterials(context, reset: true, controller: _controller);
        },
        onLoad: () {
          _loadMaterials(context, reset: false, controller: _controller);
        },
        child: GridView.builder(
          itemCount: sampleVideoItemBeans.length,
          padding: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            top: 12.h,
            bottom: ByScreenUtils.bottomSafeHeight,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 11.w,
            mainAxisSpacing: 10.h,
          ),
          itemBuilder: (context, index) {
            return AiClipSmpleCell(
              index: index,
              bean: sampleVideoItemBeans[index],
            );
          },
        ),
      ),
    );
  }

  void _loadMaterials(
    BuildContext context, {
    bool reset = false,
    required EasyRefreshController controller,
  }) {
    final provider = context.read<AiClipSampleProvider>();
    provider.aiSampleVideoList(
      reset: reset,
      pid: widget.pid,
      controller: controller,
    );
  }
}

class AiClipSmpleCell extends StatelessWidget {
  const AiClipSmpleCell({
    super.key,
    required this.bean,
    required this.index,
  });

  final int index;
  final AiSampleVideoItemBean bean;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.w),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // ByNavRouterUtils.fadeIn(context, const AiSamplePlayPage());
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (ctx) => AiSamplePlayPage(videoUrl: bean.videoUrl),
          );
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: bean.coverUrl,
                placeholder: (context, url) => Container(
                  color: ByColorUtil.CommonPageBgColor,
                ),
                errorWidget: (context, url, error) => Image.asset(
                  "assets/ai/ai_cartoon_video_bg.png",
                  fit: BoxFit.cover,
                ),
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Image.asset(
                "assets/ai/clip/ai_clip_icon_sample_play.png",
                width: 40.w,
                height: 40.w,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 50.h,
              child: ByWidgetsUtil.gradientBgContainer(
                gradient: ByColorUtil.lineareGradient(
                  colorStart: const Color(0xFF000000).withOpacity(0),
                  colorEnd: const Color(0xFF000000).withOpacity(0.7),
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                alignment: Alignment.bottomLeft,
                borderRadius: 0,
                padding: EdgeInsets.only(left: 5.w, bottom: 10.h),
                child: ByWidgetsUtil.commonText(
                  text: bean.videoTitle,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  textColor: const Color(0xFFFFFFFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
