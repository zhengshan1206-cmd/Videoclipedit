import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/words/beans/upload_info_bean.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_audio_clone_detail_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_copy_voice_save_dialog.dart';

class AiOralCopyVoiceRemakeDialog extends StatefulWidget {
  const AiOralCopyVoiceRemakeDialog({
    super.key,
    required this.audioFilePath,
    required this.provider,
  });

  final String audioFilePath;
  final AiOralVideosProvider provider;

  @override
  State<AiOralCopyVoiceRemakeDialog> createState() =>
      _AiOralCopyVoiceRemakeDialogState();
}

class _AiOralCopyVoiceRemakeDialogState
    extends State<AiOralCopyVoiceRemakeDialog> {
  final failMsg = "录音内容与给定文案不符，请按给定内容 重新录制。";

  late ValueNotifier<double> valueNotifier;
  Timer? _timer;
  Timer? _timerRecording;
  int _value = 0;
  int taskId = -1;
  bool recordGenerated = false;
  AiOralAudioCloneDetailBean? recordDetailBean;
  final CancelToken _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    valueNotifier = ValueNotifier(0);

    _createAudio();

    _resetTimer();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      byDebugPrint(_value, tag: "-------------当前进度:");
      if (_value < 120) {
        if (_value >= 75 && recordGenerated == false) {
          return;
        }
        _value += 1;
        valueNotifier.value = _value * 1.0;
      } else {
        _resetTimer();
        _saveVoice();
      }
    });
  }

  @override
  void dispose() {
    _resetTimer();
    _timerRecording?.cancel();
    _timerRecording = null;
    valueNotifier.dispose();
    super.dispose();
  }

  _resetTimer() {
    _timer?.cancel();
    _timer = null;
    _value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20.h, width: double.infinity),
        ByWidgetsUtil.commonText(
          text: "复刻音色",
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 100.h),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 180.w,
              height: 180.w,
              child: ByWidgetsUtil.commonContainer(
                borerRadius: 180.w,
                alignment: Alignment.center,
                bgColor: const Color(0xFFEAEEFF),
                child: ByWidgetsUtil.svgAsset(
                  filePath:
                      "assets/ai/oralVideos/ai_oral_voice_icon_remake.svg",
                  width: 80,
                  height: 80,
                ),
              ),
            ),
            Positioned(
              left: 10.w,
              top: 10.w,
              width: 160.w,
              height: 160.w,
              child: SimpleCircularProgressBar(
                size: 160.w,
                valueNotifier: valueNotifier,
                progressStrokeWidth: 12,
                backStrokeWidth: 12,
                mergeMode: true,
                progressColors: const [
                  ByColorUtil.TabTextColorSelected,
                  // Colors.purpleAccent,
                  // ByColorUtil.BandedWordsColor,
                  ByColorUtil.TabTextColorSelected,
                ],
                backColor: Colors.transparent,
              ),
            )
          ],
        ),
        SizedBox(height: 30.h),
        ByWidgetsUtil.commonText(
          text: "正在为您复刻声音，请不要离开！",
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
        ),
        SizedBox(height: 94.h + ByScreenUtils.bottomSafeHeight),
      ],
    );
  }

  void _saveVoice() {
    ByNavRouterUtils.goBack(context);
    if (mounted) {
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
                value: ByAudioPlayer.sharedInstance.statusProvider),
          ],
          child: AiOralCopyVoiceSaveDialog(
            audioId: taskId.toString(),
            recordBean: recordDetailBean!,
            provider: widget.provider,
          ),
        ),
      );
    }
  }

  void _createAudio() {
    /// 上传录音
    ByFfmpegUtil.loadUploadInfo(
      type: MediaType.audio,
      onSuccess: (UploadInfoBean infoBean) {
        /// 上传
        ByFfmpegUtil.uploadFile(
          infoBean: infoBean,
          filePath: widget.audioFilePath,
          showLoading: false,
          onSuccess: (resp) {
            final provider = widget.provider;
            provider.createUserAudioClone(
              url: infoBean.objectUrl,
              onSuccess: (int tid,data) {
                taskId = tid;
                _checkStatus();
              },
              onFail: () {
                BotToast.showText(text: '录音上传失败，请稍后再试');
              },
            );
          },
        );
      },
    );
  }

  Future<void> _checkStatus() async {
    final provider = widget.provider;
    _stopCheckingStatus();

    try {
      provider.getUserAudioTTS(
        audioId: taskId.toString(),
        cancelToken: _cancelToken,
        onSuccess: (bean) {
          _stopCheckingStatus();
          recordDetailBean = bean;
          recordGenerated = true;
        },
        onFail: () {
          _startTimer();
        },
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        // BotToast.showText(text: '查询已取消');
      }
    }
  }

  void _startTimer() {
    _timerRecording?.cancel();
    _timerRecording = Timer(const Duration(seconds: 2), _checkStatus);
  }

  void _stopCheckingStatus() {
    _timerRecording?.cancel();
    _timerRecording = null;
  }
}
