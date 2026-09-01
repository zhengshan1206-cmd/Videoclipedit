/*
  folk_story_list_header_page.dart
  民间故事tab选择页
  Created by duncy on 25/4/23.
*/

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

import '../../../utils/comon/by_color_utils.dart';

class FolkStoryListHeaderView extends StatelessWidget {
  const FolkStoryListHeaderView({
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

    //分类只有1个或没有时隐藏分类
    final categoryH = categoryBeans.length <= 1 ? 0.h : 56.h;
    final topPaddingH = ByScreenUtils.navigationBarHeight + 25.h;

    // final minH = topPaddingH + categoryH;
    // final maxH = categoryH  + topPaddingH;
    final minH = 125.h + categoryH;
    final maxH = 125.h + categoryH;
    final novelProvider = context.read<NovelCreateProvider>();
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
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: 250.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: 
                  [
                    ByColorUtils.hexColor(novelProvider.themeBean?.themeColor ?? ''),
                    const Color(0xFFE8EFF2),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  )
                ),
              )
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: novelProvider.themeBean?.bgImage != null ? CachedNetworkImage(
                                imageUrl: novelProvider.themeBean!.bgImage,
                                fit: BoxFit.cover,
                              ):Container(),
            ),
            //分类只有1个或没有时隐藏分类
            categoryBeans.length > 1 ? Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  Container(
                    height: categoryH,
                    padding: EdgeInsets.only(bottom: 12.h, top: 12.h),
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
                              boxDecoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFFFFFFF),
                                  width: 1.0,
                                ),
                                color: selected
                                    ? ByColorUtils.hexColor(novelProvider.themeBean?.buttonColor ?? '' )
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
            ) : Container()
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
