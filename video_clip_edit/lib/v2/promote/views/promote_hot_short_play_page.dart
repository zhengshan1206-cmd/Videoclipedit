import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/promote/widgets/short_play_grid_cell.dart';
import 'package:video_clip_edit/v2/promote/controllers/promote_hot_short_play_controller.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';
import 'package:video_clip_edit/widgets/common_button.dart';
import 'package:video_clip_edit/widgets/image/by_image_view.dart';
import 'package:video_clip_edit/widgets/refresh/by_refresh.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../utils/comon/by_nav_router_utils.dart';
import '../../hotCreate/hot_short_play_create_page.dart';
import '../../hotCreate/providers/short_play_create_provider.dart';

///推广-热播短剧
class PromoteHotShortPlayPage extends StatefulWidget {
  const PromoteHotShortPlayPage({
    super.key,
    required this.categoryBean,
    required this.canLoadMore,
  });

  final bool canLoadMore;

  final SubFunction categoryBean;

  @override
  State<PromoteHotShortPlayPage> createState() =>
      _PromoteHotShortPlayPageState();
}

class _PromoteHotShortPlayPageState extends State<PromoteHotShortPlayPage>
    with AutomaticKeepAliveClientMixin {
  PromoteHotShortPlayController? _controller;
  double _lastVisibleFraction = 0.0; // 记录上次的可见度，用于判断是否从不可见变为可见

  /// 使用 controlFinishRefresh: false，由 onRefresh 返回的 Future 完成时自动结束刷新
  late final EasyRefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController(
      controlFinishRefresh: false,
      controlFinishLoad: true,
    );
    // 延迟获取controller，确保已经注册
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Get.isRegistered<PromoteHotShortPlayController>()) {
        setState(() {
          _controller = Get.find<PromoteHotShortPlayController>();
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  PromoteHotShortPlayController get controller {
    if (_controller != null) {
      return _controller!;
    }
    // 如果还没有初始化，尝试获取（可能已经注册了）
    if (Get.isRegistered<PromoteHotShortPlayController>()) {
      _controller = Get.find<PromoteHotShortPlayController>();
      return _controller!;
    }
    // 如果还没有注册，抛出异常（这种情况不应该发生）
    throw Exception('PromoteHotShortPlayController not registered');
  }

  /// 检查并上报banner view事件
  void _checkAndReportBanner() {
    if (!mounted || _controller == null) return;
    if (_hasBanner() && _controller!.isShowBanner) {
      ByNavigatorUtil.reportDataPoint(
        pageTag: "banner",
        operateType: "view",
        funcDetailTag: widget.categoryBean.id.toString(),
        funcDetailImg: widget.categoryBean.banner ?? "",
        extra: {"position": "promote_hot_short_play"},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 如果controller还没有注册，显示加载中
    if (!Get.isRegistered<PromoteHotShortPlayController>()) {
      return const Center(child: CircularProgressIndicator());
    }
    // 确保_controller已初始化
    if (_controller == null) {
      _controller = Get.find<PromoteHotShortPlayController>();
    }
    return GetBuilder<PromoteHotShortPlayController>(
      builder: (controller) {
        return VisibilityDetector(
          key: Key('promote_hot_short_play_page_${widget.categoryBean.id}'),
          onVisibilityChanged: (info) {
            // 当页面从不可见变为可见时（从其他页面切换回来），检查并上报banner view
            // 只有当可见度从0变为大于0时才上报，避免在可见期间重复上报
            if (_lastVisibleFraction == 0.0 && info.visibleFraction > 0.0) {
              // 延迟检查banner数据并上报
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  _checkAndReportBanner();
                }
              });
            }
            _lastVisibleFraction = info.visibleFraction;
          },
          child: BYRefresh.instance(
            controller: _refreshController,
            scrollController: controller.scrollController,
            hasBefore: true,
            onRefresh: () async {
              await controller.onRefresh();
            },
            hasMore: false,
            child: MultiStatusView(
              backgroundColor: Colors.transparent,
              currentStatus: controller.multiStatus.value,
              emptyActionType: EmptyActionType.text,
              hasAppBar: false,
              child: CustomScrollView(
                controller: controller.scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 12.w,
                        right: 12.w,
                        bottom: 4.h,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/v2/promote/promote-1.png",
                            width: 10.w,
                            fit: BoxFit.fitWidth,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: ByWidgetsUtil.commonText(
                              text: "过往收益不代表未来表现，实际收益以推广效果为准",
                              fontSize: 10.sp,
                              fontWeight: FontWeight.normal,
                              textColor: const Color(
                                0xFF0B1843,
                              ).withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Banner区域
                  if (_hasBanner() && controller.isShowBanner)
                    SliverToBoxAdapter(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CommonButton(
                            minSize: 0,
                            padding: EdgeInsets.only(
                              left: 12.w,
                              right: 12.w,
                              bottom: 10.h,
                              top: 5.w,
                            ),
                            borderRadius: BorderRadius.zero,
                            onPressed: () {
                              ByNavigatorUtil.reportDataPoint(
                                pageTag: "banner_click",
                                operateType: "click",
                                funcDetailTag: widget.categoryBean.id
                                    .toString(),
                                funcDetailImg: widget.categoryBean.banner ?? "",
                                extra: {"position": "promote_hot_short_play"},
                              );
                              ByCommonUtils.subFunctionCase(
                                context,
                                widget.categoryBean,
                              );
                            },
                            child: BYImageView.normal(
                              imageUrl: widget.categoryBean.banner ?? "",
                              width: double.infinity,
                              height: 80.h,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Positioned(
                            right: 0.w,
                            top: -7.w,
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
                      ),
                    ),
                  // 双列网格
                  SliverPadding(
                    padding: EdgeInsets.only(
                      left: 6.w,
                      right: 6.w,
                      top: _hasBanner() && controller.isShowBanner ? 0 : 5.w,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 0.w,
                        mainAxisSpacing: 0.h,
                        childAspectRatio: 172 / 342,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final shortPlayBean =
                            controller.hotShortPlayList[index];
                        return ShortPlayGridCell(
                          shortPlayBean: shortPlayBean,
                          index: index,
                          fromPrompt: true,
                          prePagePath: "/promote_hot_short_play_page",
                        );
                      }, childCount: controller.hotShortPlayList.length),
                    ),
                  ),
                  // 查看更多按钮
                  if (!widget.canLoadMore)
                    SliverToBoxAdapter(
                      child: Center(
                        child: CommonButton(
                          minSize: 32.h,
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(16.h),
                          onPressed: () {
                            ByNavRouterUtils.push(
                              context,
                              ChangeNotifierProvider(
                                create: (context) => ShortPlayCreateProvider(),
                                child: const HotShortPlayCreatePage(),
                              ),
                            );
                          },
                          child: Container(
                            width: 120.w,
                            height: 32.h,
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(bottom: 10.h, top: 10.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.h),
                              color: ByColorUtil.WhiteColor,
                              border: Border.all(
                                color: ByColorUtil.LoginBtnBgColor,
                                width: 1,
                              ),
                            ),
                            child: BYText.instance(
                              '点击查看更多',
                              14.sp,
                              color: ByColorUtil.LoginBtnBgColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _hasBanner() {
    return (widget.categoryBean.banner ?? "").isNotEmpty;
  }

  @override
  bool get wantKeepAlive => true;
}
