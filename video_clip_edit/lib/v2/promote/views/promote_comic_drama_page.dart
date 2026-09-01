import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/hotCreate/widgets/short_play_list_cell.dart';
import 'package:video_clip_edit/v2/promote/controllers/promote_comic_drama_controller.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';
import 'package:video_clip_edit/widgets/common_button.dart';
import 'package:video_clip_edit/widgets/image/by_image_view.dart';
import 'package:video_clip_edit/widgets/refresh/by_refresh.dart';

import '../../../utils/comon/by_nav_router_utils.dart';
import '../../hotCreate/hot_short_play_create_page.dart';
import '../../hotCreate/providers/short_play_create_provider.dart';

///推广-漫剧
class PromoteComicDramaPage extends StatefulWidget {
  const PromoteComicDramaPage({
    super.key,
    required this.categoryBean,
    required this.canLoadMore,
  });

  final bool canLoadMore;

  final SubFunction categoryBean;

  @override
  State<PromoteComicDramaPage> createState() => _PromoteComicDramaPageState();
}

class _PromoteComicDramaPageState extends State<PromoteComicDramaPage>
    with AutomaticKeepAliveClientMixin {
  final controller = Get.find<PromoteComicDramaController>();
  bool _hasReportedBannerView = false; // 标记是否已上报banner view事件

  @override
  void initState() {
    super.initState();
    // 页面进入时，如果有banner数据，上报view事件
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasBanner() && !_hasReportedBannerView) {
        _hasReportedBannerView = true;
        ByNavigatorUtil.reportDataPoint(
          pageTag: "banner",
          operateType: "view",
          funcDetailTag: widget.categoryBean.id.toString(),
          funcDetailImg: widget.categoryBean.banner ?? "",
          extra: {"position": "promote_comic_drama"},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<PromoteComicDramaController>(builder: (controller) {
      return BYRefresh.instance(
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
              padding: EdgeInsets.only(top: 5.w),
              itemCount: _getItemCount(),
              itemBuilder: (context, index) {
                if (!widget.canLoadMore && index == _getItemCount() - 1) {
                  return Center(
                    child: CommonButton(
                      minSize: 32.h,
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(16.h),
                      onPressed: () {
                        // RouteUtils.gotoPage(context, "/short_play_create");
                        ByNavRouterUtils.push(
                          context,
                          ChangeNotifierProvider(
                            create: (context) => ShortPlayCreateProvider(),
                            child: const HotShortPlayCreatePage(
                              type: "3",
                              title: "热门漫剧",
                            ),
                          ),
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
                            extra: {"position": "promote_comic_drama"},
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
                final comicDramaBean = controller.comicDramaList[validIndex];
                return ShortPlayListCell(
                  shortPlayBean: comicDramaBean,
                  index: validIndex,
                  fromPrompt: true,
                  prePagePath: "/promote_comic_drama_page",
                );
              },
            )),
      );
    });
  }

  _getItemCount() {
    final bannerLenght = _hasBanner() ? 1 : 0;
    final loadMoreLength = widget.canLoadMore ? 0 : 1;

    return controller.comicDramaList.length + bannerLenght + loadMoreLength;
  }

  _hasBanner() {
    return (widget.categoryBean.banner ?? "").isNotEmpty;
  }

  @override
  bool get wantKeepAlive => true;
}
