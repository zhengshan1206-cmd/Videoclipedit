import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_encrypt_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/download/providers/download_provider.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/video_extraction_detail_page.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import 'package:video_clip_edit/widgets/pop_scope_widget.dart';

class VideoDownloadingPage<T extends MaterialBaseProvider>
    extends StatefulWidget {
  const VideoDownloadingPage({
    super.key,
    required this.videoUrl,
    required this.md5Source,
  });

  final String videoUrl;
  final String md5Source;
  @override
  State<VideoDownloadingPage<T>> createState() =>
      _VideoDownloadingPageState<T>();
}

class _VideoDownloadingPageState<T extends MaterialBaseProvider>
    extends State<VideoDownloadingPage<T>> {
  final TapGestureRecognizer _gestureRecognizer = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();

    /// 下载提取的视频
    _downloadVideo();
  }

  @override
  void dispose() {
    super.dispose();
    _gestureRecognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        context.select<DownloadProvider, double>((p) => p.progress);
    return PopScopeWidget(
      contents: "现在返回将中断提取，是否继续退出?",
      confirmBtnTitle: "退出",
      whiteList: () => progress >= 100,
      confirmCallback: () {
        /// 取消下载
        final downloadProvider = context.read<DownloadProvider>();
        downloadProvider.cancelAllDownloads();

        /// 更新任务状态
      },
      child: Scaffold(
        backgroundColor: ByColorUtil.WhiteColor,
        appBar: ByWidgetsUtil.appBar(
          context: context,
          popScop: true,
          title: "视频下载",
          contents: "现在返回将中断提取，是否继续退出?",
          popScopConfirmBtnTitle: "退出",
          onPop: () {
            /// 取消下载
            final downloadProvider = context.read<DownloadProvider>();
            downloadProvider.cancelAllDownloads();
          },
        ),
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
                  TextSpan(text: "视频下载中${progress.toStringAsFixed(0)}%"),
                ],
                fontSize: 15.sp,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /// 下载提取的视频
  void _downloadVideo() async {
    final videoUrl = widget.videoUrl;
    final downloadProvider = context.read<DownloadProvider>();
    final md5Str = ByEncryptUtils.md5String(widget.md5Source);
    downloadProvider.downloadVideo(
      videoUrl,
      fileName: md5Str,
      saveToAlbum: true,
      showLoading: false,
      deleteWhenFinished: true,
      onSuccess: (filePath) {
        ByNavRouterUtils.pushReplacement(
          context,
          ChangeNotifierProvider.value(
            value: context.read<VideoExtractionProvider>(),
            child: VideoExtractionDetailsPage(
                fileName: md5Str, filePath: filePath),
          ),
        );
      },
    );
  }
}
