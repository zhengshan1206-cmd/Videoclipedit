import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/beans/ai_squre_tab_bean.dart';

class AiCasesView extends StatelessWidget {
  const AiCasesView({
    super.key,
    required this.onChanged,
  });
  final void Function(int) onChanged;
  @override
  Widget build(BuildContext context) {
    final aiTypes = context
        .select<AiSquareProvider, List<AiSqureTabBean>>((p) => p.tabBeans);
    final selectedIndex =
        context.select<AiSquareProvider, int>((p) => p.selectedAiCaseTypeIndex);
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(bottom: 12.h, left: 12.w, right: 12.w),
        child: Row(
          children: aiTypes.map(
            (e) {
              final idx = aiTypes.indexOf(e);
              final selected = idx == selectedIndex;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  context
                      .read<AiSquareProvider>()
                      .changeSelectedAiCaseTypeIndex(idx);
                  onChanged.call(idx);
                },
                child: SizedBox(
                  height: 28.h,
                  child: ByWidgetsUtil.commonContainer(
                    borerRadius: 20,
                    alignment: Alignment.center,
                    bgColor: selected
                        ? const Color(0xFFEAEEFF)
                        : const Color(0xFFF3F5F9),
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    child: ByWidgetsUtil.commonText(
                      text: e.title,
                      textColor: selected
                          ? ByColorUtil.TabTextColorSelected
                          : ByColorUtil.CommonTextColor,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}

class AiCasesViewNormal extends StatelessWidget {
  const AiCasesViewNormal({
    super.key,
    required this.onChanged,
  });
  final void Function(int) onChanged;
  @override
  Widget build(BuildContext context) {
    final aiTypes = context
        .select<AiSquareProvider, List<AiSqureTabBean>>((p) => p.tabBeans);
    final selectedIndex =
        context.select<AiSquareProvider, int>((p) => p.selectedAiCaseTypeIndex);
    return Container(
      color: ByColorUtil.WhiteColor,
      padding:
          EdgeInsets.only(top: 12.h, bottom: 12.h, left: 12.w, right: 12.w),
      child: SizedBox(
        height: 28.h,
        width: double.infinity,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: aiTypes.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            final e = aiTypes[index];
            final selected = index == selectedIndex;
            final isLast = index == aiTypes.length - 1;
            final marginRight = isLast ? 0.0 : 8.w;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    context
                        .read<AiSquareProvider>()
                        .changeSelectedAiCaseTypeIndex(index);
                    onChanged.call(index);
                  },
                  child: SizedBox(
                    height: 28.h,
                    child: ByWidgetsUtil.commonContainer(
                      borerRadius: 20,
                      alignment: Alignment.center,
                      bgColor: selected
                          ? const Color(0xFFEAEEFF)
                          : const Color(0xFFF3F5F9),
                      margin: EdgeInsets.only(right: marginRight),
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/home/icon_story_hot.png",
                            width: 16,
                            height: 16,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 3.w),
                          ByWidgetsUtil.commonText(
                            text: e.title,
                            textColor: selected
                                ? ByColorUtil.TabTextColorSelected
                                : ByColorUtil.CommonTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: marginRight,
                  top: -8.h,
                  child: Image.asset(
                    "assets/home/home_page_icon_new.png",
                    width: 23.w,
                    height: 15.h,
                    fit: BoxFit.contain,
                  ),
                )
              ],
            );
          },
        ),
      ),
      // child: Row(
      //   children: aiTypes.map(
      //     (e) {
      //       final idx = aiTypes.indexOf(e);
      //       final selected = idx == selectedIndex;
      //       return GestureDetector(
      //         behavior: HitTestBehavior.opaque,
      //         onTap: () {
      //           context
      //               .read<AiSquareProvider>()
      //               .changeSelectedAiCaseTypeIndex(idx);
      //           onChanged.call(idx);
      //         },
      //         child: SizedBox(
      //           height: 28.h,
      //           child: ByWidgetsUtil.commonContainer(
      //             borerRadius: 20,
      //             alignment: Alignment.center,
      //             bgColor: selected
      //                 ? const Color(0xFFEAEEFF)
      //                 : const Color(0xFFF3F5F9),
      //             margin: EdgeInsets.only(right: 8.w),
      //             padding: EdgeInsets.symmetric(horizontal: 14.w),
      //             child: ByWidgetsUtil.commonText(
      //               text: e.title,
      //               textColor: selected
      //                   ? ByColorUtil.TabTextColorSelected
      //                   : ByColorUtil.CommonTextColor,
      //               fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      //               fontSize: 12.sp,
      //             ),
      //           ),
      //         ),
      //       );
      //     },
      //   ).toList(),
      // ),
    );
  }
}

class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;
  final void Function(bool)? onPinned;

  StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
    this.onPinned,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // final bool isPinned = shrinkOffset > 0;
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   onPinned?.call(isPinned);
    // });
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant StickyHeaderDelegate oldDelegate) {
    // return true;
    return oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.child != child;
  }
}
