import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiClip/widgets/ai_commentary_progress_bar.dart';

class AiCommentaryRewriteDialog extends StatefulWidget {
  const AiCommentaryRewriteDialog({
    super.key,
    // required this.provider,
    this.aiRewrite = false,
    required this.commentaryDesc,
    this.ids = "",
  });

  final bool aiRewrite;
  final String commentaryDesc;
  final String? ids;
  @override
  State<AiCommentaryRewriteDialog> createState() =>
      _AiCommentaryRewriteDialogState();
}

class _AiCommentaryRewriteDialogState extends State<AiCommentaryRewriteDialog> {
  Timer? _timer;

  /// 超时时间 10s
  int timeout = 10;
  double timeCost = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _initTimer();
    final provider = context.read<AiClipProvider>();
    if (widget.aiRewrite) {
      /// 调用AI改写解说接口生成文案
      _rewriteCommentay(
        provider,
        onSuccess: () {
          Navigator.of(context).pop(true);
        },
        onFailed: () {
          Navigator.of(context).pop(false);
        },
      );
    } else {
      /// 调用文案解说接口
      _generateCommentay(
        provider,
        widget.commentaryDesc,
        onSuccess: () {
          if (timeCost < 10) {
            _timer?.cancel();
            provider.updateCommentaryProgress(1.0);
            Future.delayed(const Duration(milliseconds: 100), () {
              Navigator.of(context).pop(true);
            });
          }
        },
        onFailed: () {
          Navigator.of(context).pop(false);
        },
      );
    }
  }

  void _rewriteCommentay(
    AiClipProvider provider, {
    void Function()? onSuccess,
    void Function()? onFailed,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.updateGeneratingCommentary(true);
      provider.rewriteCommentarySimpleTextByAI(
        ids: widget.ids ?? "",
        onSuccess: (taskId) {
          if (taskId.isEmpty) {
            onFailed?.call();
            provider.updateGeneratingCommentary(false);
            BotToast.showText(text: "AI改写文案失败，请稍后再试");
            return;
          }

          provider.updateGeneratingCommentary(false);
          provider.updateDesc(taskId);
          onSuccess?.call();
        },
        onFailed: () {
          onFailed?.call();
          provider.updateGeneratingCommentary(false);
          BotToast.showText(text: "AI改写文案失败，请稍后再试");
        },
      );
    });
  }

  void _generateCommentay(
    AiClipProvider provider,
    String commentaryDesc, {
    void Function()? onSuccess,
    void Function()? onFailed,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.updateGeneratingCommentary(true);
      provider.getCommentarySimpleText(
        text: commentaryDesc,
        onSuccess: (taskId) {
          if (taskId.isEmpty) {
            onFailed?.call();
            provider.updateGeneratingCommentary(false);
            BotToast.showText(text: "生成解说文案失败，请稍后再试");
            return;
          }

          /// 轮询查询生成结果
          provider.queryVoiceStyleOptimizeState(
            taskId: taskId,
            onSuccess: (result) {
              if (result.isNotEmpty) {
                /// 转换解说文案
                provider.updateGeneratingCommentary(false);
                provider.updateDesc(result);
                onSuccess?.call();
              }
            },
          );
        },
        onFailed: () {
          onFailed?.call();
          provider.updateGeneratingCommentary(false);
          BotToast.showText(text: "生成解说文案失败，请稍后再试");
        },
      );
    });
  }

  void _initTimer() {
    _timer?.cancel();

    /// 初始化一个定时器，每0.5秒，让进度增加0.1
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      context.read<AiClipProvider>().updateCommentaryProgress(
            context.read<AiClipProvider>().commentaryProgress + 0.006,
          );
      timeCost += 0.1;
      if (timeCost >= timeout) {
        _timer?.cancel();

        /// 请求超时
        Navigator.of(context).pop(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxW = ByScreenUtils.screenWidth - 24.w;
    double progress = context
        .select<AiClipProvider, double>((value) => value.commentaryProgress);
    if (progress >= 1) {
      progress = 1;
      _timer?.cancel();
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PopScope(
        canPop: false,
        child: Column(
          children: [
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.w),
                  topRight: Radius.circular(12.w),
                ),
              ),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 120.h),
                  Image.asset(
                    "assets/common/loading_large.gif",
                    width: 120.w,
                    height: 124.h,
                  ),
                  SizedBox(height: 25.h),
                  ByWidgetsUtil.commonText(
                    text: "解说文案生成中，请耐心等待。",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                  ),
                  SizedBox(height: 120.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: (maxW - 24.w) * progress,
                          child: Image.asset(
                            "assets/ai/clip/ai_clip_progress.gif",
                            height: 40.h,
                            width: 24.w,
                            // fit: BoxFit.fitHeight,
                          ),
                        ),
                        SizedBox(
                          width: maxW - 24.w,
                          height: 40.h,
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 5.h),
                  SizedBox(
                    width: maxW,
                    height: 5.h,
                    child: AiCommentaryProgressBar(progress: progress),
                  ),
                  SizedBox(height: 5.h),
                  ByWidgetsUtil.commonText(
                    text: "${(progress * 100).toStringAsFixed(0)}%",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    textColor: ByColorUtil.LoginBtnBgColor,
                  ),
                  SizedBox(height: 20.h + ByScreenUtils.bottomSafeHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
