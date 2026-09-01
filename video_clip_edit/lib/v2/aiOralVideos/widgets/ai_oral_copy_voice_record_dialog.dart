// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_recorder.dart';
import 'package:video_clip_edit/utils/comon/by_time_utils.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_copy_voice_finish_dialog.dart';

class AiOralCopyVoiceRecordDialog extends StatefulWidget {
  const AiOralCopyVoiceRecordDialog({
    super.key,
    required this.provider,
  });
  final AiOralVideosProvider provider;

  @override
  State<AiOralCopyVoiceRecordDialog> createState() =>
      _AiOralCopyVoiceRecordDialogState();
}

class _AiOralCopyVoiceRecordDialogState
    extends State<AiOralCopyVoiceRecordDialog> {
  final ByRecorder _audioRecorder = ByRecorder();

  Timer? _timer;
  int _seconds = 0;
  final minSeconds = 10;
  final maxSeconds = 30;

  late AiOralVideosProvider provider ;

  @override
  void initState() {
    _audioRecorder.initialize().then((value) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _audioRecorder.startRecording();
        _startTimer();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      provider = context.read<AiOralVideosProvider>();
      provider.pickRandomDefaultTxtIndex();
    });

    super.initState();
  }

  @override
  void dispose() {
    byDebugPrint("--------dispose");
    _timer?.cancel();
    _seconds = 0;
    _audioRecorder.dispose();
    super.dispose();
  }

  void _startTimer() {
    byDebugPrint("--------_startTimer");
    _timer?.cancel();
    _seconds = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      setState(() {
        _seconds++;
      });
      if (_seconds >= maxSeconds) {
        _finish();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentDefaultTxtIndex = context.select<AiOralVideosProvider, int>(
      (value) => value.currentDefaultTxtIndex,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20.h, width: double.infinity),
        ByWidgetsUtil.commonText(
          fontSize: 16.sp,
          text: "录音中，请朗读",
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 20.h),
        ByWidgetsUtil.commonContainer(
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          bgColor: const Color(0xFFF4F6FA),
          padding: EdgeInsets.only(bottom: 17.h, left: 12.w, right: 12.w),
          borerRadius: 18.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.h, bottom: 16.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      "assets/ai/oralVideos/ai_oral_icon_dubbing_tips.png",
                      width: 16,
                      height: 16,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: ByWidgetsUtil.commonRichText(
                        texts: [
                          const TextSpan(
                              text: "我们将录制一段您说话的声音，用于数据训练，从而复刻 出您的声音，"),
                          const TextSpan(
                            text: "最低录制10秒，最大支持30秒",
                            style: TextStyle(
                              color: ByColorUtil.CommonTextColor,
                            ),
                          ),
                        ],
                        fontSize: 12.sp,
                        fontWeight: FontWeight.normal,
                        textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                color: ByColorUtil.CommonTextColor.withOpacity(0.05),
              ),
              SizedBox(height: 18.h),
              ByWidgetsUtil.commonText(
                fontSize: 14.sp,
                text: "请在安静的环境下，认真朗读以下内容：",
              ),
              SizedBox(height: 20.h),
              ByWidgetsUtil.commonText(
                height: 1.5,
                maxLines: 1000,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                textColor: ByColorUtil.TabTextColorSelected,
                text: currentDefaultTxtIndex == -1
                    ? "默认文案获取中..."
                    : context
                        .read<AiOralVideosProvider>()
                        .defaultTxts[currentDefaultTxtIndex],
              ),
              // SizedBox(height: 8.h),
            ],
          ),
        ),
        SizedBox(height: 60.h),
        ByWidgetsUtil.commonContainer(
          bgColor: const Color(0xFFF4F6FA),
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 20.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ByWidgetsUtil.commonText(
                      fontSize: 14.sp,
                      text: "正在录音中...",
                      fontWeight: FontWeight.normal,
                    ),
                    SizedBox(height: 5.h),
                    ByWidgetsUtil.commonText(
                      fontSize: 32.sp,
                      text: ByTimeUtils.timeWithSeconds(_seconds),
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ByNavRouterUtils.goBack(context);
                },
                child: Image.asset(
                  "assets/ai/oralVideos/ai_oral_icon_dubbing_cancel.png",
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 30.w),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_seconds < minSeconds) {
                    BotToast.showText(text: "请录制${minSeconds}秒以上的音频");
                    return;
                  }
                  _finish();
                  // ByNavRouterUtils.goBack(context);
                  // showModalBottomSheet(
                  //   context: context,
                  //   isScrollControlled: true, // 允许高度自适应
                  //   shape: const RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.vertical(
                  //       top: Radius.circular(18),
                  //     ),
                  //   ),
                  //   builder: (context) => const AiOralCopyVoiceFinishDialog(),
                  // );
                },
                child: Image.asset(
                  "assets/ai/oralVideos/ai_oral_icon_dubbing_finish.png",
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h + ByScreenUtils.bottomSafeHeight),
      ],
    );
  }

  void _finish() async {
    _timer?.cancel();
    final recordingPath = await _audioRecorder.stopRecording();
    byDebugPrint(recordingPath, tag: "录音路径:");
    bool cannotNext =
        recordingPath == null || File(recordingPath).existsSync() == false;

    if (cannotNext) {
      BotToast.showText(text: "保存录音失败,请稍后重试");
      return;
    }
    ByNavRouterUtils.goBack(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许高度自适应
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      builder: (ctx) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: ByAudioPlayer.sharedInstance.statusProvider,
          ),
          ChangeNotifierProvider(
            create: (context) => AiOralVideosProvider(),
          ),
        ],
        child: AiOralCopyVoiceFinishDialog(
          audioFilePath: recordingPath,
          provider: provider,
        ),
      ),
    );
  }
}
