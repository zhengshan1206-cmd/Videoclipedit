import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/bgm_item_bean.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class BgmSelectCell<T extends MaterialBaseProvider> extends StatelessWidget {
  final int index;
  final BgmItemBean bgmItemBean;
  const BgmSelectCell({
    super.key,
    required this.index,
    required this.bgmItemBean,
  });

  @override
  Widget build(BuildContext context) {
    final int selectedAuditionBgmIdx =
        context.select<T, int>((p) => p.selectedAuditionBgmIdx);
    final int selectedBgmIdx = context.select<T, int>((p) => p.selectedBgmIdx);
    final audioPlayer = ByAudioPlayer.sharedInstance;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      margin: EdgeInsets.only(bottom: 5.h),
      decoration: BoxDecoration(
          color: ByColorUtil.WhiteColor,
          borderRadius: BorderRadius.circular(6.w)),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.w),
              ),
              child: bgmItemBean.icon == null
                  ? Container()
                  : CachedNetworkImage(
                      imageUrl: bgmItemBean.icon,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: ByWidgetsUtil.commonText(
              text: bgmItemBean.title,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          _buildPalyBtn(selectedAuditionBgmIdx, context),
          Offstage(
            offstage: index != selectedAuditionBgmIdx,
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
                        color: const Color(0xFF5B4BF7),
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
              padding: EdgeInsets.symmetric(vertical: 7.h),
              title: index == selectedBgmIdx ? "已选择" : "选择",
              bgColor: index == selectedBgmIdx
                  ? const Color(0xFF5B4BF7)
                  : ByColorUtil.LoginBtnBgColor,
              onClick: () {
                final provider = context.read<T>();
                provider.updateSelectedBgm(bgmItemBean.url, 1);
                Navigator.of(context).pop();
                // provider.updateSelectedBgmIdx(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildPalyBtn(int selectedBGMIdx, BuildContext context) {
    /// 当前是否选中
    bool selected = index == selectedBGMIdx;
    final audioPlayer = ByAudioPlayer.sharedInstance;
    bool isPlaying = ByAudioPlayer.sharedInstance.isPlaying;

    return StreamBuilder(
      stream: audioPlayer.statusFutuer(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            byDebugPrint("snapshot.hasData");
            if (snapshot.hasData && selected) {
              return ByWidgetsUtil.btnWithIcon(
                title: "试听",
                iconH: 10.h,
                iconW: 10.w,
                fontSize: 12.sp,
                bgColor: Colors.transparent,
                textColor: selected
                    ? const Color(0xFF5B4BF7)
                    : ByColorUtil.TabTextColorSelected,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                iconPath:
                    "assets/home/${isPlaying ? "icon_audio_play_selected" : "icon_audio_pause_selected"}.png",
                onClick: () async {
                  final provider = context.read<T>();
                  provider.updateSelectedAuditionsBgmIdx(index);

                  if (audioPlayer.isPlaying) {
                    await audioPlayer.pause();
                  } else {
                    await audioPlayer.resume();
                  }
                  isPlaying = ByAudioPlayer.sharedInstance.isPlaying;
                },
              );
            }
            return ByWidgetsUtil.btnWithIcon(
              title: "试听",
              iconH: 10.h,
              iconW: 10.w,
              fontSize: 12.sp,
              bgColor: Colors.transparent,
              textColor: selected
                  ? const Color(0xFF5B4BF7)
                  : ByColorUtil.TabTextColorSelected,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              iconPath:
                  "assets/home/${isPlaying ? "icon_audio_play_selected" : "icon_audio_pause_selected"}.png",
              onClick: () async {
                final provider = context.read<T>();
                provider.updateSelectedAuditionDubbingIdx(index);
                await audioPlayer.play(bgmItemBean.url);
                isPlaying = ByAudioPlayer.sharedInstance.isPlaying;
              },
            );
          default:
            return ByWidgetsUtil.btnWithIcon(
              title: "试听",
              iconH: 10.h,
              iconW: 10.w,
              fontSize: 12.sp,
              bgColor: Colors.transparent,
              textColor: selected
                  ? const Color(0xFF5B4BF7)
                  : ByColorUtil.TabTextColorSelected,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              iconPath:
                  "assets/home/${isPlaying ? "icon_audio_play_selected" : "icon_audio_pause_selected"}.png",
              onClick: () async {
                final provider = context.read<T>();
                provider.updateSelectedAuditionDubbingIdx(index);
                await audioPlayer.play(bgmItemBean.url);
                isPlaying = ByAudioPlayer.sharedInstance.isPlaying;
              },
            );
        }
      },
    );
  }
}
