import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/widgets/svga_player.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_dubbing_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_audio_status_provider.dart';

class AiCartoonVideoVoiceDialog<T extends AiSettingsMixin>
    extends StatefulWidget {
  const AiCartoonVideoVoiceDialog({
    super.key,
    required this.itemBean,
    this.isNeedData = false,
    this.dubbingBeans = const [],
    this.updateSelectedDubbingId,
    this.updateSectionConfigBeansFrom,
    this.selectedDubbingId,
  });

  final AiCartoonItemBean itemBean;
  final bool isNeedData;///这里新增了外部数据===>是因为有新的页面需要调用此弹窗
  final List<AiCartoonDubbingBean> dubbingBeans;

  final Function(int id)? updateSelectedDubbingId;
  final Function(AiCartoonItemBean itemBean, String value)? updateSectionConfigBeansFrom;
  final int? selectedDubbingId;



  @override
  State<AiCartoonVideoVoiceDialog<T>> createState() =>
      _AiCartoonVideoVoiceDialogState<T>();
}

class _AiCartoonVideoVoiceDialogState<T extends AiSettingsMixin>
    extends State<AiCartoonVideoVoiceDialog<T>> {
  @override
  void dispose() {
    ByAudioPlayer.sharedInstance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiCartoonVideoVoiceDialog_build");
    var dubbingBeans = context
        .select<T, List<AiCartoonDubbingBean>>((value) => value.dubbingBeans);

    if(widget.isNeedData){
      if(widget.dubbingBeans.isNotEmpty){
        dubbingBeans = widget.dubbingBeans;
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: SizedBox(
              height: 130.h,
              width: double.infinity,
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.w),
                  topRight: Radius.circular(18.w),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  _buildTitle(context),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: dubbingBeans.length,
                      itemBuilder: (context, index) {
                        return AiCartoonVideoVoiceCell<T>(
                          index: index,
                          dubbingBean: dubbingBeans[index],
                          itemBean: widget.itemBean,
                          updateSectionConfigBeansFrom: widget.updateSectionConfigBeansFrom,
                          updateSelectedDubbingId: widget.updateSelectedDubbingId,
                          selectedDubbingId: widget.selectedDubbingId,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.only(
                      left: 12.w,
                      right: 12.w,
                      bottom: 8.h,
                    ),
                    height: 50.h,
                    child: ByWidgetsUtil.commonBtn(
                      title: "确定",
                      fontSize: 16.sp,
                      borderRadius: 12.w,
                      padding: EdgeInsets.zero,
                      fontWeight: FontWeight.w500,
                      textColor: ByColorUtil.WhiteColor,
                      onClick: () {
                        ByNavRouterUtils.goBack(context);
                      },
                    ),
                  ),
                  SizedBox(height: 18.h),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          SizedBox(
            width: 18.w,
            height: 14.h,
          ),
          const Spacer(),
          ByWidgetsUtil.commonText(
            text: "选择配音",
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
             Get.back();
            },
            child: Container(
              // color: Colors.blue,
              width: 33.w,
              height: 33.h,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/home/icon_close_dark.png",
                width: 14.w,
                height: 14.h,
                fit: BoxFit.fill,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AiCartoonVideoVoiceCell<T extends AiSettingsMixin>
    extends StatefulWidget {
  const AiCartoonVideoVoiceCell({
    super.key,
    required this.index,
    required this.dubbingBean,
    required this.itemBean,
    this.updateSelectedDubbingId,
    this.updateSectionConfigBeansFrom,
    this.selectedDubbingId,
  });

  final int index;
  final AiCartoonDubbingBean dubbingBean;
  final AiCartoonItemBean itemBean;

  final Function(int id)? updateSelectedDubbingId;
  final Function(AiCartoonItemBean itemBean, String value)? updateSectionConfigBeansFrom;
  final int? selectedDubbingId;


  @override
  State<AiCartoonVideoVoiceCell<T>> createState() =>
      _AiCartoonVideoVoiceCellState<T>();
}

class _AiCartoonVideoVoiceCellState<T extends AiSettingsMixin>
    extends State<AiCartoonVideoVoiceCell<T>> {
  final ByAudioPlayer audioPlayer = ByAudioPlayer.sharedInstance;
  @override
  void dispose() {
    audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiBgmRecommentedCell: build");

    /// 试听的下标
    final listeningDubbingId =
        context.select<T, int>((value) => value.listeningDubbingId);
    final currentListening = listeningDubbingId == widget.dubbingBean.id;

    /// 选中的下标
    final selectedDubbingId =
        context.select<T, int>((value) => value.selectedDubbingId);
    var selected = selectedDubbingId == widget.dubbingBean.id;

    // if(widget.selectedDubbingId!=null){
    //   selected = widget.selectedDubbingId==widget.dubbingBean.id;
    // }

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
      margin: EdgeInsets.symmetric(
        horizontal: 2.w,
        vertical: 2.5.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 10.h,
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final provider = context.read<T>();
              provider.updateListeningDubbingId(widget.dubbingBean.id);
              if (currentListening) {
                if (isPlaying) {
                  audioPlayer.pause();
                } else {
                  audioPlayer.resume();
                }
                return;
              }
              audioPlayer.play(widget.dubbingBean.demoUrl);
            },
            child: ClipOval(
              child: Stack(
                children: [
                  SizedBox(
                    width: 50.w,
                    height: 50.w,
                    child: CachedNetworkImage(
                      imageUrl: widget.dubbingBean.headerImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                        child: currentListening && isPlaying
                            ?
                            // Image.asset(
                            //     "assets/home/voice_pause.png",
                            //     width: 16.w,
                            //     height: 16.h,
                            //     fit: BoxFit.contain,
                            //   )
                            // : Image.asset(
                            //     "assets/home/voice_play.png",
                            //     width: 16.w,
                            //     height: 16.h,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ByWidgetsUtil.commonText(
                      text: widget.dubbingBean.name,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(width: 5.w),
                    Image.asset(
                      "assets/ai/ai_cartoon_vip.png",
                      width: 18.w,
                      height: 14.h,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    )
                  ],
                ),
                // SizedBox(height: 7.h),
                // ByWidgetsUtil.commonText(
                //   text: "会员免费5000字/天",
                //   fontSize: 12.sp,
                //   textColor: const Color(0xFFD97A16),
                //   fontWeight: FontWeight.normal,
                // ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
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
              borderColor: ByColorUtil.TabTextColorSelected,
              bgColor: selected
                  ? ByColorUtil.TabTextColorSelected
                  : ByColorUtil.WhiteColor,
              title: selected ? "已选" : "选择",
              textColor: selected
                  ? ByColorUtil.WhiteColor
                  : ByColorUtil.TabTextColorSelected,
              fontSize: 14.sp,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              onClick: () {
                final provider = context.read<T>();provider.updateSelectedDubbingId(widget.dubbingBean.id);
                final name = widget.dubbingBean.name;
                provider.updateSectionConfigBeansFrom(widget.itemBean, name);

                ///新增加的入口事件 -->3.10.13
                if(widget.updateSelectedDubbingId!=null){
                  widget.updateSelectedDubbingId!(widget.dubbingBean.id);
                }

                if(widget.updateSectionConfigBeansFrom!=null){
                  widget.updateSectionConfigBeansFrom!(widget.itemBean,name);
                }

              },
            ),
          ),
        ],
      ),
    );
  }
}
