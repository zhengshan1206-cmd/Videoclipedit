import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/modules/tool_box/beans/video_tutor_bean.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/video_player_page.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/short_show_details_provider.dart';

class ShortPlayDetailListCell extends StatefulWidget {
  const ShortPlayDetailListCell({
    super.key,
    required this.index,
    required this.videoBean,
    this.fromMyWorks = false,
    this.maxCount = -1,
    this.canPreview = false,
  });

  final int index;
  final int maxCount;
  final Detail videoBean;
  final bool fromMyWorks;
  final bool canPreview;

  @override
  State<ShortPlayDetailListCell> createState() => _CloudMaterialCellState();
}

class _CloudMaterialCellState extends State<ShortPlayDetailListCell> {
  bool fileExists = false;
  @override
  void initState() {
    super.initState();

    _checkExists();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ShortShowDetailsProvider>();
    final selectedVideoIdxs = provider.selectedVideoIdxs;
    final currentUrl = widget.videoBean.videoUrl;
    bool selected = selectedVideoIdxs.contains(widget.index);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (widget.fromMyWorks && !fileExists) return;
        final selectedCout = selectedVideoIdxs.length;
        if (widget.maxCount > 0 &&
            selectedCout >= widget.maxCount &&
            !selected) {
          BotToast.showText(text: "最多选择${widget.maxCount}个素材");
          return;
        }
        provider.updateSelectedVideoIdxsWithIndex(widget.index);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: Stack(
          children: [
            currentUrl.startsWith("http")
                ? Positioned.fill(
              child:  CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: widget.videoBean.coverUrl,
              ),
                  )
                : Positioned.fill(
                    child: fileExists
                        ? ByDownloadUtil.videoCover(currentUrl)
                        : Container(
                            color: ByColorUtil.BlackColor.withOpacity(0.1),
                          ),
                  ),
            Positioned.fill(
              child: Container(
                color: ByColorUtil.BlackColor.withOpacity(selected ? 0.4 : 0.1),
              ),
            ),
            Positioned.fill(
              child: Offstage(
                offstage: currentUrl.startsWith("http") || fileExists,
                child: Container(
                  color: const Color(0xFFE5E9EC),
                  child: Center(
                    child: Image.asset(
                      width: 82.w,
                      height: 82.w,
                      fit: BoxFit.contain,
                      "assets/mine/work_missed.png",
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10.w,
              top: 10.w,
              child: Offstage(
                offstage: widget.fromMyWorks && !fileExists,
                child: Image.asset(
                  selected
                      ? "assets/home/mat_icon_selected.png"
                      : "assets/home/mat_icon_unselected.png",
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            Positioned(
              bottom: 0.h,
              child: Offstage(
                offstage: widget.fromMyWorks,
                child: SizedBox(
                  width: (ByScreenUtils.screenWidth - 24.w) / 2,
                  child: Container(
                    height: 40.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF000000).withOpacity(0.8),
                          const Color(0xFF000000).withOpacity(0.01),
                        ],
                        end: Alignment.topCenter,
                        begin: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 6.w),
                        ByWidgetsUtil.commonText(
                            text: widget.videoBean.videoTitle,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            textColor: ByColorUtil.WhiteColor),
                        const Spacer(),
                        ByWidgetsUtil.commonText(
                            text:
                                "约${(widget.videoBean.duration.floor() / 60).toStringAsFixed(0)}分钟",
                            fontSize: 12,
                            textColor: ByColorUtil.WhiteColor),
                        SizedBox(width: 8.w),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
                child: Offstage(
              offstage: !currentUrl.startsWith("http") && !fileExists,
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            VideoPlayerPage(
                          bean: VideoTutorBean.fromJson({
                            "id": widget.videoBean.id,
                            "avatar": "",
                            "nickname": "",
                            "create_time":
                                "${DateTime.now().year.toString().padLeft(4, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                            "title": "",
                            "content": "",
                            "video_cover": widget.videoBean.coverUrl,
                            "video_url": widget.videoBean.videoUrl,
                          }),
                          index: widget.index,
                        ),
                        transitionDuration: const Duration(milliseconds: 150),
                        reverseTransitionDuration:
                            const Duration(milliseconds: 150),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          var begin = 0.8;
                          var end = 1.0;
                          var curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));

                          return FadeTransition(
                            opacity: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    width: 50.w,
                    height: 50.h,
                    alignment: Alignment.center,
                    child: Hero(
                      tag: "${widget.videoBean.id}_${widget.index}",
                      child: Image.asset(
                        "assets/home/audio_bar_play.png",
                        width: 40.w,
                        height: 40.h,
                      ),
                    ),
                  ),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  _checkExists() async {
    if (!widget.fromMyWorks) return;
    final fileUrl = widget.videoBean.videoUrl;
    if (fileUrl.isEmpty) {
      setState(() {
        fileExists = false;
      });
      return false;
    }
    final exists = await File(fileUrl).exists();
    if (exists == false) {
      setState(() {
        fileExists = false;
      });
      return false;
    }
    setState(() {
      fileExists = true;
    });
    return true;
  }
}
