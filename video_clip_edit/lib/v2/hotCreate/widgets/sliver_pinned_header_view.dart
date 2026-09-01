import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/widgets/marquee_view.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_cases_view.dart';
import 'package:video_clip_edit/modules/home/beans/home_broadcast_bean.dart';
import 'package:video_clip_edit/v2/hotCreate/beans/hot_create_category_bean.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_provider.dart';
import 'package:video_clip_edit/v2/promote/widgets/search_view.dart';

class SliverPinnedHeaderView extends StatelessWidget {
  const SliverPinnedHeaderView({
    super.key,
    required this.categoryScrollController,
    required this.pageController,
    required this.onSize,
  });
  final ScrollController categoryScrollController;
  final PageController pageController;
  final void Function(Size size, int index) onSize;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.select<NovelCreateProvider, int>(
      (val) => val.selectedCategoryIdx,
    );
    final List<HotCreateCategoryBean> categoryBeans =
        context.select<NovelCreateProvider, List<HotCreateCategoryBean>>(
      (val) => val.categoryBeans,
    );

    final List<HomeBroadcastBean> broadcastBeans =
        context.select<NovelCreateProvider, List<HomeBroadcastBean>>(
      (val) => val.broadcastBeans,
    );

    final categoryH = categoryBeans.isEmpty ? 0.0 : 56.h;

    ///搜索栏高度
    final searchH = 60.h;
    final broadcastPaddingTop = 0.h;
    final broadcastH = (broadcastBeans.isEmpty || categoryBeans.isEmpty)
        ? 0
        : 32.h + broadcastPaddingTop;
    final topPaddingH = ByScreenUtils.navigationBarHeight;

    final minH = topPaddingH + categoryH + searchH;
    final maxH = categoryH + broadcastH + topPaddingH + searchH;
    double offset = context.select<NovelCreateProvider, double>(
      (value) => value.currentOffset,
    );
    double opacity = broadcastH > 0 ? offset / broadcastH : 1;
    if (opacity >= 0.9) opacity = 1;
    if (opacity <= 0.2) opacity = 0.0;
    byDebugPrint(
        "opacity: $opacity ----- offset: $offset ----- broadcastH: $broadcastH");
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyHeaderDelegate(
        minHeight: minH,
        maxHeight: maxH,
        child: Stack(
          children: [
            SizedBox(
              height: maxH,
              width: double.infinity,
            ),
            Positioned.fill(
              // child: Container(
              //     color: const Color(0xFFFFFFFF).withOpacity(opacity)),
              child: Container(
                color: const Color(0xFFF4F7F8),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  _buildNotice(context,
                      broadcastBeans: broadcastBeans,
                      paddingTop: broadcastPaddingTop),
                  SizedBox(
                    height: searchH,
                    width: double.infinity,
                    child: SearchView(
                      novelCreateProvider: context.read<NovelCreateProvider>(),
                      showPlatform: false,
                    ),
                  ),
                  Container(
                    height: categoryH,
                    padding: EdgeInsets.only(
                      bottom: 12.h,
                    ),
                    child: ListView.builder(
                      controller: categoryScrollController,
                      padding: EdgeInsets.only(
                        left: 12.w,
                        right: 12.w,
                      ),
                      itemCount: categoryBeans.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final selected = selectedIndex == index;
                        final category = categoryBeans[index];
                        final hasIcon = selected && category.iconUrl.isNotEmpty;
                        return LayoutBuilder(builder: (context, constraits) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final renderBox =
                                context.findRenderObject() as RenderBox?;
                            if (renderBox != null) {
                              onSize(renderBox.size, index);
                            }
                          });
                          return Container(
                            padding: EdgeInsets.only(
                              right:
                                  index == categoryBeans.length - 1 ? 0 : 10.w,
                            ),
                            child: ByWidgetsUtil.btnWithIcon(
                              title: category.title,
                              iconPath: category.iconUrl,
                              iconW: hasIcon ? 16.w : 0,
                              iconH: 16.h,
                              contentGap: hasIcon ? 3 : 0,
                              fontSize: 14.sp,
                              fontWeight: selected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              textColor: selected
                                  ? Colors.white
                                  : ByColorUtil.CommonTextColor.withOpacity(
                                      0.6),
                              padding: EdgeInsets.symmetric(horizontal: 17.w),
                              bgColor: selected
                                  ? ByColorUtil.TabTextColorSelected
                                  : const Color(0xFFFFFFFF),
                              boxDecoration: BoxDecoration(
                                border: Border.all(
                                  color: selected
                                      ? ByColorUtil.TabTextColorSelected
                                      : const Color(0xFFFFFFFF),
                                  width: 0.5,
                                ),
                                color: selected
                                    ? ByColorUtil.TabTextColorSelected
                                    : const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(8.w),
                              ),
                              onClick: () {
                                if (selectedIndex == index) return;
                                context
                                    .read<NovelCreateProvider>()
                                    .updateSelectedCategoryIdx(index);
                                pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.decelerate,
                                );
                              },
                            ),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNotice(
    BuildContext context, {
    required List<HomeBroadcastBean> broadcastBeans,
    required double paddingTop,
  }) {
    return Container(
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: paddingTop,
      ),
      child: MarqueeView(broadcastBeans: broadcastBeans),
    );
  }
}
