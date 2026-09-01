// ignore_for_file: use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/download/providers/sync_download_util.dart';

class AiVideosDownoadDialog extends StatefulWidget {
  final String contents;
  final String? title;
  final String? confirmBtnTitle;
  final String? cancelBtnTitle;
  final Function? confirmCallback;
  final Function? cancelCallback;
  final int? maxLine;
  final bool reverse;
  final List<String> videoUrls;
  final String? toast;
  final bool save;
  const AiVideosDownoadDialog({
    super.key,
    required this.contents,
    this.title,
    this.confirmBtnTitle,
    this.confirmCallback,
    this.cancelBtnTitle,
    this.cancelCallback,
    this.maxLine,
    this.reverse = false,
    required this.videoUrls,
    this.toast,
    this.save = true,
  });

  @override
  State<AiVideosDownoadDialog> createState() => _AiVideosDownoadDialogState();
}

class _AiVideosDownoadDialogState extends State<AiVideosDownoadDialog> {
  final DownloadManager _downloadManager = DownloadManager();
  double _currentProgress = 0.0;
  int _currentVideoIndex = 0;
  bool _isCanceled = false;

  @override
  void initState() {
    super.initState();

    _downloadVideos();
  }

  void _downloadVideos() async {
    setState(() {
      _isCanceled = false;
      _currentProgress = 0.0;
      _currentVideoIndex = 0;
    });

    final List<String> savePaths = [];
    await _downloadManager.downloadMultipleVideos(
      widget.videoUrls,
      (int videoIndex, double progress, String filePath) {
        if (progress >= 1) {
          savePaths.add(filePath);
        }
        if (_isCanceled) return;
        setState(() {
          _currentVideoIndex = videoIndex;
          _currentProgress = progress;
        });
      },
      save: widget.save,
    );
    if (_currentVideoIndex == widget.videoUrls.length &&
        _currentProgress >= 1) {
      Get.back(result: true);
      BotToast.showText(text: widget.toast ?? "下载完成");
    }
    if (mounted) {
      // Navigator.of(context).pop(savePaths.isNotEmpty ? savePaths.first : "");
    }
  }

  @override
  void dispose() {
    _downloadManager.cancelDownloads();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 28.w),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: ByColorUtil.WhiteColor,
                    borderRadius: BorderRadius.circular(18.w)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 60.h),
                    ByWidgetsUtil.commonText(
                      text: widget.title ?? "温馨提示",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 43.w),
                      child: ByWidgetsUtil.commonText(
                        fontSize: 14.sp,
                        maxLines: widget.maxLine ?? 1,
                        textAlign: TextAlign.center,
                        text:
                            "${widget.videoUrls.length == 1 ? "视频下载中\n当前进度:${(_currentProgress * 100).toStringAsFixed(0)}%" : "第$_currentVideoIndex个(共${widget.videoUrls.length}个)视频下载中\n当前进度:${(_currentProgress * 100).toStringAsFixed(0)}%"}\n如果提前离开将取消下载。",
                      ),
                    ),
                    SizedBox(height: 50.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Row(children: [
                        Expanded(
                          child: SizedBox(
                            height: 48.h,
                            child: ByWidgetsUtil.commonBtn(
                              title: widget.cancelBtnTitle ?? "取消",
                              // padding:
                              //     EdgeInsets.symmetric(vertical: 15.h),
                              fontSize: 16.sp,
                              borderRadius: 12.w,
                              bgColor: const Color(0xFF0E1840).withOpacity(0.3),
                              textColor: ByColorUtil.WhiteColor,
                              fontWeight: FontWeight.bold,
                              onClick: () {
                                Navigator.of(context).pop("");
                                widget.cancelCallback?.call();
                              },
                            ),
                          ),
                        ),
                      ]),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -25.h,
              left: ByScreenUtils.screenWidth * 0.5 - 30.w,
              child: Image.asset(
                "assets/home/icon_bell.png",
                width: 60.w,
                height: 60.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///新的弹窗
class ReplicaDialog extends StatefulWidget {
  final String contents;
  final String? title;
  final String? confirmBtnTitle;
  final String? cancelBtnTitle;
  final Function? confirmCallback;
  final Function? cancelCallback;
  final int? maxLine;
  final bool reverse;
  final List<String> videoUrls;
  final String? toast;
  final bool save;

  final String title2;
  final String title3;
  final Function()? clickEvent;
  final Function()? confirmEvent;

  const ReplicaDialog({
    super.key,
    required this.contents,
    this.title,
    this.confirmBtnTitle,
    this.confirmCallback,
    this.cancelBtnTitle,
    this.cancelCallback,
    this.maxLine,
    this.reverse = false,
    required this.videoUrls,
    this.toast,
    this.save = true,
    this.title2 = "",
    this.title3 = "",
    this.clickEvent,
    this.confirmEvent,
  });

  @override
  State<ReplicaDialog> createState() => _ReplicaDialogState();
}

class _ReplicaDialogState extends State<ReplicaDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 28.w),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: ByColorUtil.WhiteColor,
                    borderRadius: BorderRadius.circular(18.w)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 40.h),
                    ByWidgetsUtil.commonText(
                      text: widget.title ?? "温馨提示",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.only(left: 25.w, right: 25.w),
                      child: Column(
                        children: [
                          if (widget.title2.isNotEmpty)
                            RichText(
                                text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                text: "${widget.title2}",
                                style: TextStyle(
                                  color: const Color(0XFF0B1843),
                                  fontSize: 14.sp,
                                ),
                              ),
                              if (widget.title3.isNotEmpty)
                                TextSpan(
                                    text: "${widget.title3}",
                                    style: TextStyle(
                                      color: const Color(0XFF5B4BF7),
                                      fontSize: 14.sp,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        if (widget.clickEvent != null) {
                                          widget.clickEvent!();
                                        }
                                      }),
                            ])),
                        ],
                      ),
                    ),
                    SizedBox(height: 50.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Row(children: [
                        Expanded(
                          child: SizedBox(
                            height: 48.h,
                            child: ByWidgetsUtil.commonBtn(
                              title: "${widget.confirmBtnTitle}",
                              fontSize: 16.sp,
                              borderRadius: 12.w,
                              bgColor: const Color(0xFF5B4BF7),
                              textColor: ByColorUtil.WhiteColor,
                              fontWeight: FontWeight.bold,
                              onClick: () {
                                if (widget.confirmEvent != null) {
                                  widget.confirmEvent!();
                                }
                                Get.back(result: true);
                                widget.cancelCallback?.call();
                              },
                            ),
                          ),
                        ),
                      ]),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -25.h,
              left: ByScreenUtils.screenWidth * 0.5 - 30.w,
              child: Image.asset(
                "assets/home/icon_bell.png",
                width: 60.w,
                height: 60.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
