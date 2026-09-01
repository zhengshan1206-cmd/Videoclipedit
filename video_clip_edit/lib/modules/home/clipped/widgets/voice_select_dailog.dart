import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/dubbing_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/bgm_item_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/bgm_category_bean.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/bgm_select_cell.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/voice_select_cell.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/voice_volume_control_widget.dart';

enum VoiceSelectDailogType {
  /// 配乐
  bgm,

  /// 配音
  dubbing,
}

extension VoiceSelectDailogTypeExt on VoiceSelectDailogType {
  String get rawValue {
    switch (this) {
      case VoiceSelectDailogType.dubbing:
        return "选择配音";

      case VoiceSelectDailogType.bgm:
        return "选择配乐";
    }
  }
}

class VoiceSelectDailog<T extends MaterialBaseProvider> extends StatefulWidget {
  const VoiceSelectDailog({
    super.key,
    this.type = VoiceSelectDailogType.dubbing,
  });

  final VoiceSelectDailogType type;

  @override
  State<VoiceSelectDailog> createState() => _VoiceSelectDailogState<T>();
}

class _VoiceSelectDailogState<T extends MaterialBaseProvider>
    extends State<VoiceSelectDailog<T>> {
  double volume = 0;
  @override
  void initState() {
    super.initState();

    final provider = context.read<T>();
    if (widget.type == VoiceSelectDailogType.dubbing) {
      provider.loadDubbingList();
    } else {
      provider.loadBgmCateoryList();
    }
  }

  @override
  void dispose() {
    ByAudioPlayer.sharedInstance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDubbing = widget.type == VoiceSelectDailogType.dubbing;
    final dubingBeans =
        context.select<T, List<DubbingBean>?>((p) => p.dubbingBeans);
    final bgmBeans = context.select<T, List<BgmItemBean>>((p) => p.bgmBeans);
    final bgmCategoryBeans =
        context.select<T, List<BgmCategoryBean>?>((p) => p.bgmCategoryBeans);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const Spacer(),
          Container(
            width: double.infinity,
            height: ByScreenUtils.screenHeight * 0.85,
            decoration: BoxDecoration(
              color: ByColorUtil.CommonPageBgColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.w),
                topRight: Radius.circular(18.w),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20.h),
                _buildTitle(context),
                SizedBox(height: 10.h),
                _buildVolumeSlider(),
                // SizedBox(height: 10.h),
                if (!isDubbing && (bgmCategoryBeans?.isNotEmpty ?? false))
                  _buildBgmCateListView(context, bgmCategoryBeans),
                if (!isDubbing) SizedBox(height: 10.h),
                if (isDubbing)
                  Expanded(
                    child: dubingBeans == null
                        ? ByWidgetsUtil.activityIndicator()
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 12.w,
                            ),
                            itemCount: dubingBeans.length,
                            itemBuilder: (context, index) {
                              return VoiceSelectCell<T>(
                                dubbingBean: dubingBeans[index],
                                index: index,
                              );
                            },
                          ),
                  ),
                if (!isDubbing)
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12.w,
                      ),
                      itemCount: bgmBeans.length,
                      itemBuilder: (context, index) {
                        return BgmSelectCell<T>(
                          bgmItemBean: bgmBeans[index],
                          index: index,
                        );
                      },
                    ),
                  ),
                SizedBox(height: 20.h),
                _buildConfimBtn(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  VoiceVolumeControlWidget _buildVolumeSlider() {
    return const VoiceVolumeControlWidget();
  }

  Container _buildConfimBtn(BuildContext context) {
    return Container(
      color: ByColorUtil.WhiteColor,
      height: 44.h,
      margin: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 8.h,
        bottom: 8.h + ByScreenUtils.bottomSafeHeight,
      ),
      child: ByWidgetsUtil.commonBtn(
        title: "确定",
        fontSize: 16.sp,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        onClick: () async {
          final navigator = Navigator.of(context);
          await ByAudioPlayer.sharedInstance.stop();
          navigator.pop();
        },
      ),
    );
  }

  /// 标题
  Row _buildTitle(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 30.w),
        const Spacer(),
        ByWidgetsUtil.commonText(
          text: widget.type.rawValue,
          textColor: ByColorUtil.CommonTextColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final navigator = Navigator.of(context);
            await ByAudioPlayer.sharedInstance.stop();
            navigator.pop();
          },
          child: Container(
            width: 30.w,
            height: 30.w,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/login/login_dialog_close.png",
              width: 12,
              height: 12,
            ),
          ),
        ),
        SizedBox(width: 12.w),
      ],
    );
  }

  _buildBgmCateListView(
    BuildContext context,
    List<BgmCategoryBean>? bgmCategoryBeans,
  ) {
    final provider = context.watch<T>();
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: bgmCategoryBeans!.length,
        itemBuilder: (context, index) {
          final selected = index == provider.selectedBgmCategoryIdx;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              provider.updateSelectedBgmCategoryIdx(index);
              provider.loadBgmList(reset: true);
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 15.h),
              margin: EdgeInsets.only(
                  right: (index == bgmCategoryBeans.length - 1) ? 0 : 10.w),
              decoration: BoxDecoration(
                  color: selected
                      ? ByColorUtil.TabTextColorSelected
                      : ByColorUtil.WhiteColor,
                  borderRadius: BorderRadius.circular(8.w)),
              child: ByWidgetsUtil.commonText(
                text: bgmCategoryBeans[index].title,
                fontSize: selected ? 15.sp : 14.sp,
                textColor: selected
                    ? ByColorUtil.WhiteColor
                    : ByColorUtil.CommonTextColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
