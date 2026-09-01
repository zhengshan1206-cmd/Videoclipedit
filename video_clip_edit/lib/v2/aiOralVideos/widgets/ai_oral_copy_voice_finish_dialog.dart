import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_time_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_copy_voice_remake_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_audio_status_provider.dart';

import '../../../modules/home/providers/words_extract_provider.dart';
import '../../../modules/home/words/beans/upload_info_bean.dart';
import '../../../utils/comon/by_ffmpeg_util.dart';
import '../../aiSquare/widgets/ai_video_player.dart';
import '../ai_oral_videos_create_page.dart';

class AiOralCopyVoiceFinishDialog extends StatefulWidget {
  const AiOralCopyVoiceFinishDialog({
    super.key,
    required this.audioFilePath,
    required this.provider,
  });

  final String audioFilePath;
  final AiOralVideosProvider provider;

  @override
  State<AiOralCopyVoiceFinishDialog> createState() =>
      _AiOralCopyVoiceFinishDialogState();
}

class _AiOralCopyVoiceFinishDialogState
    extends State<AiOralCopyVoiceFinishDialog> {
  int duration = 0;
  int progress = 0;

  @override
  void initState() {
    super.initState();

    _audioInitialize();
  }

  @override
  void dispose() {
    /// 停止播放器，释放资源
    ByAudioPlayer.sharedInstance.playerDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus =
        context.select<AiCartoonAudioStatusProvider, AiCartoonAudioStatus>(
      (value) => value.currentStatus,
    );
    bool isPlaying = ByAudioPlayer.sharedInstance.isPlaying &&
        [AiCartoonAudioStatus.playing, AiCartoonAudioStatus.resume].contains(
          currentStatus,
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20.h, width: double.infinity),
        ByWidgetsUtil.commonText(
          text: "录制完成",
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 20.h),
        ByWidgetsUtil.commonContainer(
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          bgColor: const Color(0xFFF4F6FA),
          padding: EdgeInsets.only(
            bottom: 15.h,
            left: 15.w,
            right: 15.w,
            top: 20.h,
          ),
          borerRadius: 18.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ByWidgetsUtil.commonText(
                text: "请试听录音效果，满意后再保存提交，我们将使用此 音频来复刻您的音色。",
                fontWeight: FontWeight.normal,
                maxLines: 100,
                fontSize: 14.sp,
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () {
                  if (isPlaying) {
                    ByAudioPlayer.sharedInstance.pause();
                  } else {
                    if (progress == 0) {
                      log("文件路径===>${widget.audioFilePath}");

                      ByAudioPlayer.sharedInstance.play(
                        widget.audioFilePath,
                        releaseMode: ReleaseMode.release,
                      );
                    } else {
                      ByAudioPlayer.sharedInstance.resume();
                    }
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: ByWidgetsUtil.commonContainer(
                  borerRadius: 12.w,
                  padding: EdgeInsets.only(top: 15.h, bottom: 15.h, left: 15.w),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50.w,
                        height: 50.w,
                        child: ByWidgetsUtil.commonContainer(
                          bgColor: ByColorUtil.TabTextColorSelected,
                          borerRadius: 12.w,
                          padding: EdgeInsets.all(9.w),
                          child: ByWidgetsUtil.commonContainer(
                              borerRadius: 100,
                              bgColor: ByColorUtil.BlackColor.withOpacity(0.2),
                              alignment: Alignment.center,
                              child: ByWidgetsUtil.svgAsset(
                                filePath: isPlaying
                                    ? "assets/home/voice_pause.svg"
                                    : "assets/home/voice_play.svg",
                                width: 15.w,
                                height: 15.h,
                              )
                              // Image.asset(
                              //   isPlaying
                              //       ? "assets/home/voice_pause.png"
                              //       : "assets/home/voice_play.png",
                              //   width: 15.w,
                              //   height: 15.h,
                              //   fit: BoxFit.contain,
                              // ),
                              ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.zero,
                              margin: EdgeInsets.zero,
                              height: 25.h,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    left: -15,
                                    right: -5.w,
                                    height: 25.h,
                                    child: SfSlider(
                                      min: 0,
                                      max: duration == 0 ? 1 : duration,
                                      value: progress,
                                      showTicks: false,
                                      showLabels: false,
                                      enableTooltip: false,
                                      minorTicksPerInterval: 1,
                                      thumbShape: const SfThumbShape(),
                                      activeColor:
                                          ByColorUtil.TabTextColorSelected,
                                      inactiveColor: ByColorUtil.CommonTextColor
                                          .withOpacity(0.1),
                                      onChanged: (value) async {
                                        final valueChanged =
                                            (value as double).toInt();
                                        byDebugPrint(valueChanged,
                                            tag: "---seek to:");
                                        if (progress > 0) {
                                          await ByAudioPlayer.sharedInstance
                                              .seekTo(valueChanged);
                                          if (!isPlaying) {
                                            ByAudioPlayer.sharedInstance
                                                .pause();
                                          }
                                        } else {
                                          final st = isPlaying;
                                          await ByAudioPlayer.sharedInstance
                                              .play(
                                            widget.audioFilePath,
                                            releaseMode: ReleaseMode.stop,
                                            position:
                                                Duration(seconds: valueChanged),
                                          );
                                          if (!st) {
                                            ByAudioPlayer.sharedInstance
                                                .pause();
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Padding(
                              padding: EdgeInsets.only(left: 0.w), //23
                              child: ByWidgetsUtil.commonRichText(
                                texts: [
                                  TextSpan(
                                    text: ByTimeUtils.timeWithSeconds(progress),
                                    style: const TextStyle(
                                      color: ByColorUtil.CommonTextColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        "/ ${ByTimeUtils.timeWithSeconds(duration)}",
                                    style: TextStyle(
                                      color: ByColorUtil.CommonTextColor
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                textColor: ByColorUtil.CommonTextColor,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 175.h),
        Container(
          height: 50.h,
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              Expanded(
                child: ByWidgetsUtil.commonBtn(
                  title: "重新录制",
                  fontSize: 16.sp,
                  borderRadius: 12.w,
                  fontWeight: FontWeight.w500,
                  textColor: ByColorUtil.TabTextColorSelected,
                  bgColor: const Color(0xFFEAEEFF),
                  onClick: () {
                    ByNavRouterUtils.goBack(context);
                  },
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: ByWidgetsUtil.commonBtn(
                  title: "提交",
                  fontSize: 16.sp,
                  borderRadius: 12.w,
                  fontWeight: FontWeight.w500,
                  textColor: ByColorUtil.WhiteColor,
                  onClick: () {
                    // ByNavRouterUtils.goBack(context);

                    // showModalBottomSheet(
                    //   context: context,
                    //   isScrollControlled: true, // 允许高度自适应
                    //   shape: const RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.vertical(
                    //       top: Radius.circular(18),
                    //     ),
                    //   ),
                    //   builder: (ctx) => AiOralCopyVoiceRemakeDialog(
                    //       audioFilePath: widget.audioFilePath,
                    //       provider: widget.provider),
                    // );

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
                            // final provider =  Get.context!.read<AiOralVideosProvider>();
                            widget.provider.createUserAudioClone(
                              url: infoBean.objectUrl,
                              directSave: 1,
                              onSuccess: (int tid, dynamic data) {
                                widget.provider.ttsId = tid;
                                Get.log("创建的克隆音频文件====> $data ");
                                eventBus.fire(InsertCloneMusicModelEvent(
                                    model: MusicModel(
                                  id: data["id"],
                                  name: data["title"] ?? "",
                                  type: 1,
                                  demoUrl: data["audio_url"] ?? "",
                                  refContent: data["ref_content"] ?? "",
                                  coverUrl: data["cover_url"],
                                )));

                                Get.back();
                              },
                              onFail: () {
                                BotToast.showText(text: '录音上传失败，请稍后再试');
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h + ByScreenUtils.bottomSafeHeight),
      ],
    );
  }

  void _audioInitialize() async {
    await ByAudioPlayer.sharedInstance.setSource(widget.audioFilePath);

    ByAudioPlayer.sharedInstance.onPositionChanged(
      (duration) {
        byDebugPrint(duration.inSeconds, tag: "----XXXXXXXXXXXX:");
        if (mounted) {
          setState(() {
            progress = duration.inSeconds;
          });
        }
      },
    );

    final len = await ByAudioPlayer.sharedInstance.getDuration();
    if (mounted) {
      setState(() {
        duration = len?.inSeconds ?? 0;
      });
    }
  }
}
