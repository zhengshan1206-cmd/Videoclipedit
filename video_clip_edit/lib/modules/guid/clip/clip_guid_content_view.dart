// ignore_for_file: must_be_immutable, use_build_context_synchronously, unused_field

import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/providers/clipped_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class ClipGuidContentView extends StatefulWidget {
  bool type;
  final int index;

  ClipGuidContentView({
    super.key,
    this.showCommentary = true,
    this.type = true,
    required this.index,
  });

  ///  是否显示顶部的解说列表
  final bool showCommentary;
  @override
  State<ClipGuidContentView> createState() => _ClipGuidContentViewState();
}

class _ClipGuidContentViewState extends State<ClipGuidContentView> {
  @override
  void initState() {
    super.initState();
  }

  late ClippedProvider _provider;
// ignore: slash_for_doc_comments
/************************************************ UI构建 ************************************************/

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        /// 视频比例
        ..._buildVideoRatiosSection(context),

        /// 解说字幕
        ..._buildSubtitlesSection(context),

        /// 选择模式
        ..._buildModesSection(context),

        /// 选择特效
        ..._buildSpecialEffectsSection(context),

        /// 背景音乐
        ..._buildBgmSection(context),

        _buildSectionTitle(
          title: "去除视频原声",
          rightWidget: Selector<ClippedProvider, Tuple2<ClippedProvider, bool>>(
              selector: (p0, p1) => Tuple2(p1, p1.removeVideoAudio),
              builder: (
                context,
                tuple,
                child,
              ) {
                return Switch(
                  value: tuple.item2,
                  activeColor: ByColorUtil.WhiteColor,
                  activeTrackColor: ByColorUtil.LoginBtnBgColor,
                  inactiveTrackColor:
                      ByColorUtil.CommonTextColor.withOpacity(0.2),
                  inactiveThumbColor: const Color(0xFFF8F8F8),
                  trackOutlineColor:
                      const WidgetStatePropertyAll(Colors.transparent),
                  onChanged: (value) {
                    tuple.item1.updateRemoveVideoAudioStatus(!tuple.item2);
                  },
                );
              }),
        ),

        /// 安全距离
        SliverToBoxAdapter(
          child: SizedBox(height: ByScreenUtils.bottomSafeHeight + 60.h),
        ),
      ],
    );
  }

  /// 背景音乐组
  List<Widget> _buildBgmSection(BuildContext context) {
    final provider = context.watch<ClippedProvider>();
    return [
      _buildSectionTitle(title: "背景音乐"),
      _buildSectionGride(
        itemCount: provider.bgms.length,
        crossAxisCount: 3,
        childAspectRatio: 109 / 36,
        itemBuilder: (ctx, index) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: _buildBGMCell(provider, index),
          );
        },
      ),
    ];
  }

  Container _buildBGMCell(ClippedProvider provider, int index) {
    bool select = provider.selectedBgmIndex == index;
    if (select) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ByColorUtil.LoginBtnBgColor,
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(width: 16.w),
            ByWidgetsUtil.commonText(
              text: provider.bgms[provider.selectedBgmIndex],
              textColor: ByColorUtil.WhiteColor,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ByColorUtil.WhiteColor,
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: ByWidgetsUtil.commonText(
          text: provider.bgms[index],
          textColor: ByColorUtil.CommonTextColor,
          fontWeight: FontWeight.normal,
        ),
      );
    }
  }

  /// 模式组
  _buildModesSection(BuildContext context) {
    final provider = context.watch<ClippedProvider>();
    return [
      _buildSectionTitle(title: "选择模式"),
      _buildSectionGride(
        itemCount: provider.modes.length,
        crossAxisCount: 4,
        childAspectRatio: 20 / 9,
        itemBuilder: (ctx, index) {
          final modes = provider.modes;
          var selected = provider.selectedModes.contains(modes[index]);
          return GestureDetector(
            onTap: () {
              provider.updateSelectedModes(modes[index]);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? ByColorUtil.LoginBtnBgColor
                    : ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: ByWidgetsUtil.commonText(
                text: provider.modes[index],
                textColor: selected
                    ? ByColorUtil.WhiteColor
                    : ByColorUtil.CommonTextColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    ];
  }

  /// 特效组
  _buildSpecialEffectsSection(BuildContext context) {
    final provider = context.watch<ClippedProvider>();
    return [
      _buildSectionTitle(title: "选择特效"),
      _buildSectionGride(
        itemCount: provider.speciaEffects.length,
        crossAxisCount: 4,
        childAspectRatio: 20 / 9,
        itemBuilder: (ctx, index) {
          final speciaEffects = provider.speciaEffects;
          var selected =
              provider.selectedSpeciaEffect.contains(speciaEffects[index]);
          return GestureDetector(
            onTap: () {
              provider.updateSelectedSpeciaEffect(speciaEffects[index]);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? ByColorUtil.LoginBtnBgColor
                    : ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: ByWidgetsUtil.commonText(
                text: provider.speciaEffects[index],
                textColor: selected
                    ? ByColorUtil.WhiteColor
                    : ByColorUtil.CommonTextColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    ];
  }

  /// 视频比例组
  _buildVideoRatiosSection(BuildContext context) {
    final Tuple3<List<String>, String, ClippedProvider> ratiosTuple = context
        .select<ClippedProvider, Tuple3<List<String>, String, ClippedProvider>>(
      (p) => Tuple3(p.ratios, p.selectedRatio, p),
    );
    return [
      _buildSectionTitle(title: "视频比例"),
      _buildSectionGride(
        itemCount: ratiosTuple.item1.length,
        crossAxisCount: 5,
        childAspectRatio: 5 / 3,
        itemBuilder: (ctx, index) {
          final ratios = ratiosTuple.item1;
          var selected = ratios[index] == ratiosTuple.item2;
          return GestureDetector(
            onTap: () {},
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? ByColorUtil.LoginBtnBgColor
                    : ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: ByWidgetsUtil.commonText(
                text: ratiosTuple.item1[index],
                textColor: selected
                    ? ByColorUtil.WhiteColor
                    : ByColorUtil.CommonTextColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    ];
  }

  /// 字幕组
  _buildSubtitlesSection(BuildContext context) {
    final provider = context.watch<ClippedProvider>();
    return [
      _buildSectionTitle(title: "解说字幕"),
      _buildSectionGride(
        itemCount: provider.subTitles.length,
        crossAxisCount: 4,
        childAspectRatio: 20 / 9,
        itemBuilder: (ctx, index) {
          final current = provider.subTitles[index];
          var selected = current == provider.selectedSubTitle;
          return GestureDetector(
            onTap: () {
              provider.updateSelectedSubTitle(current);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? ByColorUtil.LoginBtnBgColor
                    : ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: ByWidgetsUtil.commonText(
                text: provider.subTitles[index],
                textColor: selected
                    ? ByColorUtil.WhiteColor
                    : ByColorUtil.CommonTextColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    ];
  }

  /// 组标题
  _buildSectionTitle({
    required String title,
    Widget? rightWidget,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 10.h,
        ),
        child: Row(
          children: [
            ByWidgetsUtil.commonText(
              text: title,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
            const Spacer(),
            if (rightWidget != null) rightWidget
          ],
        ),
      ),
    );
  }

  /// 九宫格
  _buildSectionGride({
    required int crossAxisCount,
    required int? itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    double childAspectRatio = 1.0,
  }) {
    return SliverPadding(
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        bottom: 10.h,
      ),
      sliver: SliverGrid.builder(
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: childAspectRatio),
        itemBuilder: (context, index) {
          return itemBuilder(context, index);
        },
      ),
    );
  }

/************************************************ UI构建 ************************************************/
}
