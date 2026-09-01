import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';

class VideoExtractionDetailsPage extends StatefulWidget {
  const VideoExtractionDetailsPage({
    super.key,
    this.filePath,
    required this.fileName,
  });

  final String fileName;
  final String? filePath;

  @override
  State<VideoExtractionDetailsPage> createState() =>
      _VideoExtractionDetailsPageState();
}

class _VideoExtractionDetailsPageState
    extends State<VideoExtractionDetailsPage> {
  bool _parsing = true;

  String filePath = "";

  @override
  void initState() {
    super.initState();

    _parseVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "视频提取"),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Column(
        children: [
          SizedBox(height: 44.h),
          Expanded(
            child: Center(
              child: _parsing
                  ? ByWidgetsUtil.activityIndicator()
                  : VideoPlayerWidget(url: filePath),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            color: ByColorUtil.WhiteColor,
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              bottom: 8.h + ByScreenUtils.bottomSafeHeight,
            ),
            child: ByWidgetsUtil.commonBtn(
              title: "保存到相册",
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              onClick: () async {
                // BotToast.showText(text: "保存成功");

                ByDownloadUtil.saveVideoToAlbum(filePath);
              },
            ),
          )
        ],
      ),
    );
  }

  void _parseVideo() async {
    if (widget.filePath.byNullSafe.isNotEmpty) {
      setState(() {
        _parsing = false;
        filePath = widget.filePath!;
      });
      return;
    }

    final fileName = "${widget.fileName}.mp4";
    final fileCachePath =
        await ByDownloadUtil.videoCachePathFromFileName(fileName);

    final fileCache = File(fileCachePath);
    final exists = await fileCache.exists();
    if (!exists) {
      BotToast.showText(text: "视频资源不存在或已过期");
      return;
    }

    setState(() {
      _parsing = false;
      filePath = fileCachePath;
    });
  }
}
