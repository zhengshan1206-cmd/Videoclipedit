import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/base_view.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/promote/beans/promotion_category_bean.dart';
import 'package:video_clip_edit/v2/promote/controllers/home_promote_controller.dart';
import 'package:video_clip_edit/v2/promote/views/promote_folk_story_page.dart';
import 'package:video_clip_edit/v2/promote/views/promote_hot_novels_page.dart';
import 'package:video_clip_edit/v2/promote/views/promote_hot_short_play_page.dart';
import 'package:video_clip_edit/v2/promote/views/promote_comic_drama_page.dart';
import 'package:video_clip_edit/v2/promote/widgets/promotion_middle_view.dart';
import 'package:video_clip_edit/v2/promote/widgets/promotion_pinned_top_view.dart';
import 'package:video_clip_edit/widgets/common/common_sliver_persistent_header.dart';
import 'package:video_clip_edit/widgets/common/common_tab_bar.dart';

///首页推广
class HomePromotePage extends GetView<HomePromoteController> {
  const HomePromotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomePromoteController>(
      builder: (controller) {
        return BaseView(
          hasAppBar: false,
          backgroundColor: ByColorUtil.colorF4F7F8,
          child: NestedScrollView(
            physics: const ClampingScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                ///顶部吸顶
                const PromotionPinnedTopView(),

                ///中间非吸顶部分
                PromotionMiddleView(bannerList: controller.bannerList),

                ///tabbar吸顶
                CommonSliverPersistentHeader(
                  pinned: true,
                  minHeight: controller.isLoading ? 0 : 56.h,
                  maxHeight: controller.isLoading ? 0 : 56.h,
                  child: controller.isLoading
                      ? Container()
                      : Container(
                          color: ByColorUtil.colorF4F7F8,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: CommonTabBar(
                            tabController: controller.tabController,
                            currentIndex: controller.currentIndex,
                            tabHeight: 36.h,
                            tabs: controller.categoryList,
                            isScrollable: true,
                          ),
                        ),
                ),
              ];
            },
            body: controller.isLoading
                ? Container()
                : TabBarView(
                    controller: controller.tabController,
                    children: controller.categoryList.map((categoryBean) {
                      final type = PromotionCategoryType.fromId(
                        categoryBean.id,
                      );
                      switch (type) {
                        ///热门短剧
                        case PromotionCategoryType.hotPlays:
                          return PromoteHotShortPlayPage(
                            categoryBean: categoryBean,
                            canLoadMore: false,
                          );

                        ///热门小说
                        case PromotionCategoryType.hotNovel:
                          return PromoteHotNovelsPage(
                            categoryBean: categoryBean,
                            canLoadMore: false,
                          );

                        ///民间故事
                        case PromotionCategoryType.folkStory:
                          return PromoteFolkStoryPage(
                            categoryBean: categoryBean,
                            canLoadMore: false,
                          );

                        ///漫剧
                        case PromotionCategoryType.comicDrama:
                          return PromoteComicDramaPage(
                            categoryBean: categoryBean,
                            canLoadMore: false,
                          );
                        default:
                          throw UnimplementedError();
                      }
                      return Container();
                    }).toList(),
                  ),
          ),
        );
      },
    );
  }
}
