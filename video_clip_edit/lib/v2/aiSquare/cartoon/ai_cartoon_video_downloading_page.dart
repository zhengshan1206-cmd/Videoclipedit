// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/modules/download/providers/sync_download_util.dart';

class AiCartoonVideoDownloadingPage extends StatefulWidget {
  const AiCartoonVideoDownloadingPage({
    super.key,
    required this.videoUrls,
  });

  final List<String> videoUrls;

  @override
  State<AiCartoonVideoDownloadingPage> createState() =>
      _AiCartoonVideoDownloadingPageState();
}

class _AiCartoonVideoDownloadingPageState
    extends State<AiCartoonVideoDownloadingPage> {
  final DownloadManager _downloadManager = DownloadManager();
  double _currentProgress = 0.0;
  bool _isDownloading = false;
  int _currentVideoIndex = 0;
  bool _isCanceled = false;

  @override
  void initState() {
    super.initState();

    _downloadVideos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = _isDownloading == false;
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        _onPopInvoked(didPop, context);
      },
      child: Scaffold(
        backgroundColor: ByColorUtil.WhiteColor,
        appBar: ByWidgetsUtil.appBar(
          context: context,
          title: "视频下载",
          onPop: () {
            _onPopInvoked(
              canPop,
              context,
              fromAppbBar: true,
            );
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
                  TextSpan(
                    text: widget.videoUrls.length == 1
                        ? "视频下载中(${(_currentProgress * 100).toStringAsFixed(0)}%)"
                        : "第$_currentVideoIndex个(共${widget.videoUrls.length}个)视频下载中(${(_currentProgress * 100).toStringAsFixed(0)}%)",
                  ),
                ],
                fontSize: 15.sp,
              ),
              SizedBox(height: 45.h),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _downloadVideos() async {
    setState(() {
      _isCanceled = false;
      _isDownloading = true;
      _currentProgress = 0.0;
      _currentVideoIndex = 0;
    });

    await _downloadManager.downloadMultipleVideos(
      widget.videoUrls,
      (int videoIndex, double progress, String path) {
        if (_isCanceled) return;
        setState(() {
          _currentVideoIndex = videoIndex;
          _currentProgress = progress;
        });
      },
    );

    setState(() {
      _isDownloading = false;
    });

    ByNavRouterUtils.goBack(context);
  }

  void _onPopInvoked(
    bool didPop,
    BuildContext context, {
    bool fromAppbBar = false,
  }) async {
    final navigator = Navigator.of(context);
    if (didPop) {
      if (fromAppbBar) navigator.pop();
      return;
    }

    if (_isDownloading) {
      final result = await showDialog(
        context: context,
        builder: (c) {
          return CommonDialog(
            contents: "素材正在下载中，离开将会中断，确定要返回吗？",
            maxLine: 10,
            cancelBtnTitle: "取消",
            confirmBtnTitle: "确定",
            confirmCallback: () {
              _downloadManager.cancelDownloads();
              setState(() {
                _isCanceled = true;
                _isDownloading = false;
              });
            },
          );
        },
      );
      if (result) {
        navigator.pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }
}
