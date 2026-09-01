import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/modules/home/widgets/svga_player.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_dubbing_anchor_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_dubbing_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_audio_status_provider.dart';

class AiOralAnchorDubbingListView extends StatefulWidget {
  const AiOralAnchorDubbingListView({
    super.key,
  });

  @override
  State<AiOralAnchorDubbingListView> createState() => _AiOralAnchorDubbingListViewState();
}

class _AiOralAnchorDubbingListViewState extends State<AiOralAnchorDubbingListView> {

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final provider = context.read<AiOralDubbingAnchorProvider>();
    int selectAIMusicIndex = provider.selectAiMusicIndex;
    Get.log("===克隆AI声音index====> ${selectAIMusicIndex}");
    if (selectAIMusicIndex != -1) {
      if (selectAIMusicIndex > 2) {
        double moveSpace = (selectAIMusicIndex - 2) * 70;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          /// 此时视图已经完成构建，可以安全地调用animateTo()
          scrollController.animateTo(
            moveSpace.w,
            duration: const Duration(milliseconds: 500),
            curve: Curves.linear,
          );
          Get.log("执行自动滚动=== ${selectAIMusicIndex}");
          if (mounted) {
            setState(() {});
          }
        });
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    final dubbingBeans =
        context.select<AiOralDubbingAnchorProvider, List<AiCartoonDubbingBean>>(
      (value) => value.dubbingBeans,
    );
    return ListView.builder(
      controller: scrollController,
      itemCount: dubbingBeans.length,
      itemBuilder: (context, index) => AiOralAnchorDubbingListCell(
        index: index,
        bean: dubbingBeans[index],
      ),
      padding: EdgeInsets.only(bottom: 150.w),
    );
  }
}

class AiOralAnchorDubbingListCell extends StatelessWidget {
  AiOralAnchorDubbingListCell({
    super.key,
    required this.bean,
    required this.index,
  });

  final int index;
  final AiCartoonDubbingBean bean;
  final ByAudioPlayer audioPlayer = ByAudioPlayer.sharedInstance;

  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiOralMyDubbingListCell: build");
    final selectedDubbingId = context.select<AiOralDubbingAnchorProvider, int>(
      (value) => value.selectedDubbingId,
    );
    final selected = selectedDubbingId == bean.id;
    final provider = context.read<AiOralDubbingAnchorProvider>();

    /// 试听的下标
    final listeningDubbingId = context.select<AiOralDubbingAnchorProvider, int>(
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
              audioPlayer.play(bean.demoUrl);
            },
            child: ClipOval(
              child: Stack(
                children: [
                  SizedBox(
                    width: 40.w,
                    height: 40.w,
                    child: CachedNetworkImage(
                      errorWidget: (context, url, error) =>
                          Image.asset("assets/ai/bgm_default.png"),
                      imageUrl: bean.headerImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                        color: const Color(0xFF000000).withOpacity(0.2)),
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
                            ByWidgetsUtil.svgAsset(
                                filePath: "assets/home/voice_pause.svg",
                                width: 15.w,
                                height: 15.h,
                              )
                            : ByWidgetsUtil.svgAsset(
                                filePath: "assets/home/voice_play.svg",
                                width: 15.w,
                                height: 15.h,
                              )
                        // Image.asset(
                        //     "assets/home/voice_play.png",
                        //     width: 15.w,
                        //     height: 15.h,
                        //     fit: BoxFit.contain,
                        //   )
                        ),
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
                // showModalBottomSheet(
                //   context: context,
                //   isScrollControlled: true, // 允许高度自适应
                //   shape: const RoundedRectangleBorder(
                //     borderRadius: BorderRadius.vertical(
                //       top: Radius.circular(18),
                //     ),
                //   ),
                //   builder: (ctx) => const AiOralCopyVoiceRenameDialog(),
                // );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ByWidgetsUtil.commonText(
                    text: bean.name,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    textColor: ByColorUtil.CommonTextColor,
                  ),
                  SizedBox(height: 2.h),
                  ByWidgetsUtil.commonText(
                    text: bean.title,
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
          SizedBox(
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
                provider.updateSelectedDubbingId(selected ? -1 : bean.id);
              },
            ),
          ),
        ],
      ),
    );
  }
}
