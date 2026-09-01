import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/dubbing_bean.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';

class VoiceSelectCell<T extends MaterialBaseProvider> extends StatefulWidget {
  final int index;
  final DubbingBean dubbingBean;
  const VoiceSelectCell({
    super.key,
    required this.index,
    required this.dubbingBean,
  });

  @override
  State<VoiceSelectCell<T>> createState() => _VoiceSelectCellState<T>();
}

class _VoiceSelectCellState<T extends MaterialBaseProvider>
    extends State<VoiceSelectCell<T>> {
  @override
  Widget build(BuildContext context) {
    final audioPlayer = ByAudioPlayer.sharedInstance;

    /// 选中的试听人员下标
    final int selectedAuditionDubbingIdx =
        context.select<T, int>((p) => p.selectedAuditionDubbingIdx);

    /// 当前选择的配音人员下标
    final int selectedDubbingIdx =
        context.select<T, int>((p) => p.selectedDubbingIdx);

    /// 当前人员是否为试听人员
    bool isAuditionDubbingIdx = widget.index == selectedAuditionDubbingIdx;

    /// 是否正在播放
    bool isPlaying = audioPlayer.isPlaying;
    final isPlayingSelected = isPlaying && isAuditionDubbingIdx;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      margin: EdgeInsets.only(bottom: 5.h),
      decoration: BoxDecoration(
        color: ByColorUtil.WhiteColor,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: ByColorUtil.BlackColor.withOpacity(0.1),
            blurRadius: 2.w,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: Stack(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.w),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.dubbingBean.headerImage,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                    child: Container(
                  color: ByColorUtil.BlackColor.withOpacity(0.3),
                )),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final provider = context.read<T>();
                      if (widget.index != selectedAuditionDubbingIdx) {
                        provider.updateSelectedAuditionDubbingIdx(widget.index);
                        await audioPlayer.play(widget.dubbingBean.demoUrl);
                        setState(() {});
                      } else {
                        if (audioPlayer.isPlaying) {
                          await audioPlayer.pause();
                        } else {
                          await audioPlayer.resume();
                        }

                        setState(() {});
                      }
                    },
                    child: Center(
                        child: ByWidgetsUtil.svgAsset(
                      filePath: isPlayingSelected
                          ? "assets/home/voice_pause.svg"
                          : "assets/home/voice_play.svg",
                      width: 16.w,
                      height: 16.h,
                    )
                        // Image.asset(
                        //   isPlayingSelected
                        //       ? "assets/home/voice_pause.png"
                        //       : "assets/home/voice_play.png",
                        //   width: 16.w,
                        //   height: 16.h,
                        // ),
                        ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ByWidgetsUtil.commonText(
                    text: widget.dubbingBean.showName,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ],
              ),
              SizedBox(height: 9.h),
              ByWidgetsUtil.commonText(
                text: "会员免费",
                textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                fontSize: 12.sp,
              ),
            ],
          ),
          const Spacer(),
          Offstage(
            offstage: widget.index != selectedAuditionDubbingIdx,
            child: StreamBuilder(
              stream: audioPlayer.statusFutuer(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.done:
                  case ConnectionState.waiting:
                    return Container();
                  case ConnectionState.active:
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data == ByAudioPlayerStatus.loading) {
                      return ByWidgetsUtil.activityIndicator(
                        radius: 8.w,
                        color: const Color(0xFFED3F8D),
                      );
                    }
                    return Container();
                }
              },
            ),
          ),
          SizedBox(width: 10.w),
          SizedBox(
            width: 60.w,
            child: ByWidgetsUtil.commonBtn(
              padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 0.w),
              title: widget.index == selectedDubbingIdx ? "已选择" : "选择",
              bgColor: widget.index == selectedDubbingIdx
                  ? const Color(0xFFED3F8D)
                  : ByColorUtil.LoginBtnBgColor,
              onClick: () {
                final provider = context.read<T>();
                provider.updateSelectedDubbingIdx(widget.index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
