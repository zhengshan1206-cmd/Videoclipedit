import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuple/tuple.dart';
import 'package:video_clip_edit/modules/home/deduplication/video_handle_page.dart';
import 'package:video_clip_edit/modules/home/providers/video_deduplication_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class VideoEditContentView extends StatefulWidget {
  const VideoEditContentView({super.key});

  @override
  State<VideoEditContentView> createState() => _VideoEditContentViewState();
}

class _VideoEditContentViewState extends State<VideoEditContentView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            /// 选择模式
            ..._buildModesSection(context),

            /// 选择特效
            ..._buildSpecialEffectsSection(context),

            /// 背景音乐
            ..._buildBgmSection(context),
            _buildSectionTitle(
              title: "去除视频原声",
              rightWidget: Selector<VideoDeduplicationProvider,
                      Tuple2<VideoDeduplicationProvider, bool>>(
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
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: ByScreenUtils.screenWidth,
            color: ByColorUtil.WhiteColor,
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              top: 8.h,
              bottom: 8.h + ByScreenUtils.bottomSafeHeight,
            ),
            child: ByWidgetsUtil.commonBtn(
              title: "确定",
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              borderRadius: 12.w,
              onClick: () {
                ByNavRouterUtils.push(
                  context,
                  ChangeNotifierProvider.value(
                    value: context.read<VideoDeduplicationProvider>(),
                    child: const VideoHandlePage(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 背景音乐组
  List<Widget> _buildBgmSection(BuildContext context) {
    final provider = context.read<VideoDeduplicationProvider>();
    return [
      _buildSectionTitle(title: "背景音乐"),
      _buildSectionGride(
        itemCount: provider.bgms.length,
        crossAxisCount: 2,
        childAspectRatio: 85 / 22,
        itemBuilder: (ctx, index) {
          var selected = index == 0;
          return Container(
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
          );
        },
      ),
    ];
  }

  /// 模式组
  _buildModesSection(BuildContext context) {
    final provider = context.watch<VideoDeduplicationProvider>();
    return [
      _buildSectionTitle(title: "选择模式", subTitle: "单选"),
      _buildSectionGride(
        itemCount: provider.modes.length,
        crossAxisCount: 4,
        childAspectRatio: 20 / 9,
        itemBuilder: (ctx, index) {
          final modes = provider.modes;
          var selected = provider.selectedMode == modes[index];
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
    final provider = context.watch<VideoDeduplicationProvider>();
    return [
      _buildSectionTitle(title: "选择特效", subTitle: "多选"),
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

  /// 组标题
  _buildSectionTitle({
    required String title,
    String? subTitle,
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
              fontSize: 14.sp,
            ),
            if (subTitle != null && subTitle.isNotEmpty)
              ByWidgetsUtil.commonText(
                text: "($subTitle)",
                fontWeight: FontWeight.normal,
                fontSize: 12.sp,
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
}
