import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/modules/home/widgets/svga_player.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_dubbing_clone_detail_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_copy_voice_modify_dialog.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_copy_voice_rename_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_audio_status_provider.dart';

class AiOralMyAudioListView extends StatelessWidget {
  const AiOralMyAudioListView({
    super.key,
    required this.showSelect,
  });

  final bool showSelect;

  @override
  Widget build(BuildContext context) {
    final dubbingBeanList = context
        .select<AiOralVideosProvider, List<AiOralDubbingCloneDetailBean>>(
            (value) => value.dubbingCloneDetailBeanList);
    return ListView.builder(
      itemCount: dubbingBeanList.length,
      itemBuilder: (context, index) {
        return AiOralAnchorDubbingListCell(
          index: index,
          showSelect: showSelect,
          bean: dubbingBeanList[index],
        );
      },
    );
  }
}

class AiOralAnchorDubbingListCell extends StatelessWidget {
  AiOralAnchorDubbingListCell({
    super.key,
    required this.bean,
    required this.index,
    required this.showSelect,
  });

  final int index;
  final bool showSelect;
  final AiOralDubbingCloneDetailBean bean;
  final ByAudioPlayer audioPlayer = ByAudioPlayer.sharedInstance;

  @override
  Widget build(BuildContext context) {
    final dubbingCloneDetailBean =
        context.select<AiOralVideosProvider, AiOralDubbingCloneDetailBean?>(
      (value) => value.dubbingCloneDetailBean,
    );
    bool selected = false;
    if (dubbingCloneDetailBean != null) {
      selected = dubbingCloneDetailBean.id == bean.id;
    }

    /// 试听的下标
    final listeningDubbingId = context.select<AiOralVideosProvider, int>(
      (value) => value.listeningDubbingId,
    );

    final currentListening = listeningDubbingId == bean.id;

    /// 播放状态
    final status =
        context.select<AiCartoonAudioStatusProvider, AiCartoonAudioStatus>(
      (val) => val.currentStatus,
    );

    final isPlaying = status == AiCartoonAudioStatus.playing ||
        status == AiCartoonAudioStatus.resume;
    final provider = context.read<AiOralVideosProvider>();
    return ByWidgetsUtil.commonContainer(
      boxShadow: [
        BoxShadow(
          color: ByColorUtil.BlackColor.withOpacity(0.05),
          blurRadius: 2.w,
        )
      ],
      margin: EdgeInsets.symmetric(vertical: 5.h),
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 10.h,
      ),
      borerRadius: 10.w,
      bgColor: const Color(0xFFF4F6FA),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              provider.updateListeningDubbingId(bean.id);
              if (currentListening) {
                if (isPlaying) {
                  audioPlayer.pause();
                } else {
                  audioPlayer.resume();
                }
                return;
              }
              audioPlayer.play(bean.audioUrl);
            },
            child: ClipOval(
              child: Stack(
                children: [
                  SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: Image.asset("assets/mine/mine_avarta.png")
                      // CachedNetworkImage(
                      //   errorWidget: (context, url, error) =>
                      //       Image.asset("assets/ai/bgm_default.png"),
                      //   imageUrl: bean,
                      //   fit: BoxFit.cover,
                      // ),
                      ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                        child: currentListening && isPlaying
                            ?
                            // Image.asset(
                            //     "assets/home/voice_pause.png",
                            //     width: 15.w,
                            //     height: 15.h,
                            //     fit: BoxFit.contain,
                            //   )
                            // : Image.asset(
                            //     "assets/home/voice_play.png",
                            //     width: 15.w,
                            //     height: 15.h,
                            //     fit: BoxFit.contain,
                            //   )
                            ByWidgetsUtil.svgAsset(
                                filePath: "assets/home/voice_pause.svg",
                                width: 15.w,
                                height: 15.h,
                              )
                            : ByWidgetsUtil.svgAsset(
                                filePath: "assets/home/voice_play.svg",
                                width: 15.w,
                                height: 15.h,
                              )),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // 上报点击埋点（配音只需要上报id，不需要封面图）
                ByNavigatorUtil.reportDataPoint(
                  pageTag: "myworks_list_dub_works",
                  operateType: "click",
                  funcDetailTag: bean.id.toString(),
                  funcDetailImg: "",
                );
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true, // 允许高度自适应
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  builder: (ctx) => AiOralCopyVoiceModifyDialog(
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          return CommonDialog(
                            reverse: false,
                            maxLine: 10,
                            contents: "请确认是否删除，删除后将不可回恢复，请谨慎操作",
                            confirmBtnTitle: "删除",
                            confirmCallback: () {
                              provider.deleteUserAudioTTS(
                                id: bean.id,
                              );
                            },
                          );
                        },
                      );
                    },
                    onRename: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true, // 允许高度自适应
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                        ),
                        builder: (ctx) => AiOralCopyVoiceRenameDialog(
                          onFinish: (name) {
                            provider.renameUserAudioTTS(
                              id: bean.id.toString(),
                              name: name,
                              onSuccess: () {
                                provider.getUserAudioTTSList();
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ByWidgetsUtil.commonText(
                        text: bean.title,
                        fontSize: 14.sp,
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
                  SizedBox(height: 2.h),
                  ByWidgetsUtil.commonText(
                    text: bean.createAt,
                    fontSize: 12.sp,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
          Offstage(
            offstage: !(currentListening && isPlaying),
            child: SizedBox(
              width: 19.w,
              height: 15.h,
              child: const SvgaPlayer(url: "assets/ai/ai_music_play.svga"),
            ),
          ),
          SizedBox(width: 20.w),
          Offstage(
            offstage: showSelect == false,
            child: SizedBox(
              width: 60.w,
              height: 28.h,
              child: ByWidgetsUtil.commonBtn(
                padding: EdgeInsets.zero,
                borderColor: selected
                    ? ByColorUtil.TabTextColorSelected
                    : const Color(0xFFEAEEFF),
                bgColor: selected
                    ? ByColorUtil.TabTextColorSelected
                    : const Color(0xFFEAEEFF),
                title: selected ? "已选择" : "选择",
                textColor: selected
                    ? ByColorUtil.WhiteColor
                    : ByColorUtil.TabTextColorSelected,
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
                onClick: () {
                  provider.updateDubbingCloneDetailBean(selected ? null : bean);
                  Get.back();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
