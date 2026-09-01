import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiOralVideos/ai_oral_videos_create_page.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_audio_clone_detail_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_copy_voice_rename_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_audio_status_provider.dart';

class AiOralCopyVoiceSaveDialog extends StatefulWidget {
  const AiOralCopyVoiceSaveDialog({
    super.key,
    required this.audioId,
    required this.recordBean,
    required this.provider,
  });

  final String audioId;
  final AiOralAudioCloneDetailBean recordBean;
  final AiOralVideosProvider provider;
  @override
  State<AiOralCopyVoiceSaveDialog> createState() =>
      _AiOralCopyVoiceSaveDialogState();
}

class _AiOralCopyVoiceSaveDialogState extends State<AiOralCopyVoiceSaveDialog> {
  String rename = "";

  @override
  void initState() {
    loadRecord();
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      ByAudioPlayer.sharedInstance.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus =
        context.select<AiCartoonAudioStatusProvider, AiCartoonAudioStatus>(
      (value) => value.currentStatus,
    );
    final playing = [AiCartoonAudioStatus.playing, AiCartoonAudioStatus.resume]
        .contains(currentStatus);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 5.h, width: double.infinity),
        Row(
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () {
                ByNavRouterUtils.goBack(context);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.all(15.w),
                child: Image.asset(
                  "assets/ai/oralVideos/ai_oral_icon_close.png",
                  width: 15,
                  height: 15,
                ),
              ),
            ),
          ],
        ),
        Image.asset(
          "assets/ai/oralVideos/ai_oral_icon_success.png",
          width: 100,
          height: 100,
        ),
        SizedBox(height: 15.h),
        ByWidgetsUtil.commonText(
          text: "复刻成功！",
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          textColor: ByColorUtil.CommonTextColor,
        ),
        SizedBox(height: 34.h),
        ByWidgetsUtil.commonContainer(
          borerRadius: 12.w,
          bgColor: const Color(0xFFF4F6FA),
          padding: EdgeInsets.only(top: 15.h, bottom: 15.h, left: 15.w),
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final audioUrl = widget.recordBean.audioUrl;
                  if (audioUrl == null) return;
                  if (playing) {
                    ByAudioPlayer.sharedInstance.pause();
                  } else {
                    if (currentStatus == AiCartoonAudioStatus.pause) {
                      ByAudioPlayer.sharedInstance.resume();
                    } else {
                      ByAudioPlayer.sharedInstance.play(audioUrl);
                    }
                  }
                },
                child: SizedBox(
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
                        child:
                            // Image.asset(
                            //   playing
                            //       ? "assets/home/voice_pause.png"
                            //       : "assets/home/voice_play.png",
                            //   width: 15.w,
                            //   height: 15.h,
                            //   fit: BoxFit.contain,
                            // ),
                            ByWidgetsUtil.svgAsset(
                          filePath: playing
                              ? "assets/home/voice_pause.svg"
                              : "assets/home/voice_play.svg",
                          width: 15.w,
                          height: 15.h,
                        )),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, // 允许高度自适应
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                          ),
                          builder: (ctx) => ChangeNotifierProvider.value(
                            value: widget.provider,
                            child: AiOralCopyVoiceRenameDialog(
                              onFinish: (name) {
                                widget.provider.renameUserAudioClone(
                                  id: widget.audioId,
                                  name: name,
                                  onSuccess: () {
                                    setState(() {
                                      rename = name;
                                    });
                                  },
                                  onFail: () {
                                    BotToast.showText(text: "重命名失败");
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          ByWidgetsUtil.commonText(
                            text: rename.isEmpty
                                ? widget.recordBean.title
                                : rename, //bean.title.split(".").first,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            textColor: ByColorUtil.CommonTextColor,
                          ),
                          SizedBox(width: 9.w),
                          ByWidgetsUtil.svgAsset(
                            filePath:
                                "assets/ai/oralVideos/ai_oral_icon_my_dubbing_edit.svg",
                            width: 14,
                            height: 14,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ByWidgetsUtil.commonText(
                      text: widget
                          .recordBean.createdAt, //"12秒  2024-12-18  14:19:32",
                      fontSize: 14.sp,
                      textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                    ),
                  ],
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
                  title: "保存音色",
                  fontSize: 16.sp,
                  borderRadius: 12.w,
                  fontWeight: FontWeight.w500,
                  textColor: ByColorUtil.WhiteColor,
                  onClick: () {
                    widget.provider.saveUserAudioClone(
                      id: widget.recordBean.id,
                      onSuccess: () {
                        // widget.provider.selectedMusicModel = MusicModel(id: widget.recordBean.id, name: widget.recordBean.title, type: 1, demoUrl: widget.recordBean.audioUrl, refContent: widget.recordBean.refContent);
                        ByNavRouterUtils.goBack(context);
                        ByNavRouterUtils.goBack(context);
                        widget.provider.getUserAudioCloneList(reset: true,selectFirst: true);
                      },
                    );
                    // ByNavRouterUtils.goBack(context);
                    // showModalBottomSheet(
                    //   context: context,
                    //   isScrollControlled: true, // 允许高度自适应
                    //   shape: const RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.vertical(
                    //       top: Radius.circular(18),
                    //     ),
                    //   ),
                    //   builder: (ctx) => AiOralCopyVoiceRemakeDialog(audioFilePath: wid,),
                    // );
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

  void loadRecord() {
    // final provider = context.read<AiOralVideosProvider>();
  }
}
