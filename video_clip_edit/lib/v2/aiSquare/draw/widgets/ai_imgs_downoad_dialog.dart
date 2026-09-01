import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/download/providers/sync_download_util.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class AiImgsDownoadDialog extends StatefulWidget {
  final String contents;
  final String? title;
  final String? confirmBtnTitle;
  final String? cancelBtnTitle;
  final Function? confirmCallback;
  final Function? cancelCallback;
  final int? maxLine;
  final bool reverse;
  final List<String> imgUrls;
  final String? toast;

  const AiImgsDownoadDialog({
    super.key,
    required this.contents,
    this.title,
    this.confirmBtnTitle,
    this.confirmCallback,
    this.cancelBtnTitle,
    this.cancelCallback,
    this.maxLine,
    this.reverse = false,
    required this.imgUrls,
    this.toast,
  });

  @override
  State<AiImgsDownoadDialog> createState() => _AiImgsDownoadDialogState();
}

class _AiImgsDownoadDialogState extends State<AiImgsDownoadDialog> {
  final DownloadManager _downloadManager = DownloadManager();
  double _currentProgress = 0.0;
  int _currentVideoIndex = 0;
  bool _isCanceled = false;

  @override
  void initState() {
    super.initState();

    _downloadImgs();
  }

  void _downloadImgs() async {
    setState(() {
      _isCanceled = false;
      _currentProgress = 0.0;
      _currentVideoIndex = 0;
    });

    await _downloadManager.downloadMultipleImages(
      widget.imgUrls,
      (int videoIndex, double progress) {
        if (_isCanceled) return;
        setState(() {
          _currentVideoIndex = videoIndex;
          _currentProgress = progress;
        });
      },
    );
    if (_currentVideoIndex == widget.imgUrls.length && _currentProgress >= 1) {
      BotToast.showText(text: widget.toast ?? "保存完成");
    }
    ByNavRouterUtils.goBack(context);
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
                            "${widget.imgUrls.length == 1 ? "图片下载中\n当前进度:${(_currentProgress * 100).toStringAsFixed(0)}%" : "第$_currentVideoIndex张(共${widget.imgUrls.length}个)图片下载中\n当前进度:${(_currentProgress * 100).toStringAsFixed(0)}%"}\n如果提前离开将取消下载。",
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
                                Navigator.of(context).pop(false);
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
