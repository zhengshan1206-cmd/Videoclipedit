import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/routes/route_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/hotCreate/widgets/novel_list_cell.dart';
import 'package:video_clip_edit/v2/promote/beans/promotion_category_bean.dart';
import 'package:video_clip_edit/v2/promote/controllers/promote_folk_story_controller.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';
import 'package:video_clip_edit/widgets/common_button.dart';
import 'package:video_clip_edit/widgets/image/by_image_view.dart';
import 'package:video_clip_edit/widgets/refresh/by_refresh.dart';
import 'package:visibility_detector/visibility_detector.dart';

///推广-民间故事
class PromoteFolkStoryPage extends StatefulWidget {
  const PromoteFolkStoryPage({
    super.key,
    required this.categoryBean,
    required this.canLoadMore,
  });

  final bool canLoadMore;

  final SubFunction categoryBean;

  @override
  State<PromoteFolkStoryPage> createState() => _PromoteFolkStoryPageState();
}

class _PromoteFolkStoryPageState extends State<PromoteFolkStoryPage>
    with AutomaticKeepAliveClientMixin {
  final controller = Get.find<PromoteFolkStoryController>();
  double _lastVisibleFraction = 0.0; // 记录上次的可见度，用于判断是否从不可见变为可见

  /// 检查并上报banner view事件
  void _checkAndReportBanner() {
    if (_hasBanner() && controller.isShowBanner) {
      ByNavigatorUtil.reportDataPoint(
        pageTag: "banner",
        operateType: "view",
        funcDetailTag: widget.categoryBean.id.toString(),
        funcDetailImg: widget.categoryBean.banner ?? "",
        extra: {"position": "promote_folk_story"},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<PromoteFolkStoryController>(builder: (controller) {
      return VisibilityDetector(
        key: Key('promote_folk_story_page_${widget.categoryBean.id}'),
        onVisibilityChanged: (info) {
          // 当页面从不可见变为可见时（从其他页面切换回来），检查并上报banner view
          // 只有当可见度从0变为大于0时才上报，避免在可见期间重复上报
          if (_lastVisibleFraction == 0.0 && info.visibleFraction > 0.0) {
            // 延迟检查banner数据并上报
            Future.delayed(const Duration(milliseconds: 300), () {
              _checkAndReportBanner();
            });
          }
          _lastVisibleFraction = info.visibleFraction;
        },
        child: BYRefresh.instance(
          controller: controller.refreshController,
          hasBefore: true,
          onRefresh: () => controller.onRefresh(),
          hasMore: false,
          child: MultiStatusView(
              backgroundColor: Colors.transparent,
              currentStatus: controller.multiStatus.value,
              emptyActionType: EmptyActionType.text,
              hasAppBar: false,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _getItemCount(),
                itemBuilder: (context, index) {
                  if (!widget.canLoadMore && index == _getItemCount() - 1) {
                    return Center(
                      child: CommonButton(
                        minSize: 32.h,
                        padding: EdgeInsets.zero,
                        borderRadius: BorderRadius.circular(16.h),
                        onPressed: () {
                          RouteUtils.gotoPage(
                            context,
                            "/novel_create",
                            params: "mjgs",
                          );
                        },
                        child: Container(
                          width: 120.w,
                          height: 32.h,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(bottom: 10.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.h),
                            color: ByColorUtil.WhiteColor,
                            border: Border.all(
                              color: ByColorUtil.LoginBtnBgColor,
                              width: 1,
                            ),
                          ),
                          child: BYText.instance('点击查看更多', 14.sp,
                              color: ByColorUtil.LoginBtnBgColor),
                        ),
                      ),
                    );
                  }

                  if (_hasBanner() && index == 0) {
                    final banner = widget.categoryBean.banner ?? "";
                    if (!controller.isShowBanner) {
                      return const SizedBox.shrink();
                    }
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CommonButton(
                          minSize: 0,
                          padding: EdgeInsets.only(
                              left: 12.w, right: 12.w, bottom: 10.h),
                          borderRadius: BorderRadius.zero,
                          onPressed: () {
                            ByNavigatorUtil.reportDataPoint(
                              pageTag: "banner_click",
                              operateType: "click",
                              funcDetailTag: widget.categoryBean.id.toString(),
                              funcDetailImg: widget.categoryBean.banner ?? "",
                              extra: {"position": "promote_folk_story"},
                            );
                            ByCommonUtils.subFunctionCase(
                                context, widget.categoryBean);
                          },
                          child: BYImageView.normal(
                            imageUrl: banner,
                            width: double.infinity,
                            height: 80.h,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Positioned(
                          right: 0.w,
                          top: -12.w,
                          child: GestureDetector(
                            onTap: () {
                              controller.closeBannerEvent();
                            },
                            child: Container(
                              width: 50.w,
                              height: 50.w,
                              color: Colors.transparent,
                              alignment: Alignment.center,
                              child: Image.asset(
                                "assets/ai/aiVideo/new_ai_video_close_icon.png",
                                width: 15.w,
                                height: 15.w,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  final validIndex = _hasBanner() ? index - 1 : index;
                  final storyBean = controller.folkStoryList[validIndex];
                  return NovelListCell(
                    novelBean: storyBean,
                    index: validIndex,
                    promoteType: PromotionCategoryType.folkStory,
                  );
                },
              )),
        ),
      );
    });
  }

  _getItemCount() {
    final bannerLenght = _hasBanner() ? 1 : 0;
    final loadMoreLength = widget.canLoadMore ? 0 : 1;

    return controller.folkStoryList.length + bannerLenght + loadMoreLength;
  }

  _hasBanner() {
    return (widget.categoryBean.banner ?? "").isNotEmpty;
  }

  @override
  bool get wantKeepAlive => true;
}
