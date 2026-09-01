import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_cases_view.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/home_page_new_headers.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/toolBox/beans/new_tool_box_category_bean.dart';

import '../../../utils/comon/by_common_utils.dart';
import '../../../widgets/common_button.dart';
import '../../../widgets/image/by_image_view.dart';

/// 首页大卡下方「工具箱」四宫格占位：须与 [SubFuncsView] 内 [SizedBox(height: 80.w)] 一致。
/// 阔折内屏等宽屏下 [80.w] 常大于 [82.h]，若仍用 [82.h] 估算会导致吸顶 [Stack] 层叠错位，
/// 大卡区与四宫格贴死（[HomePageNewBannerView] 底部已有 [SizedBox(height: 12.h)] 的留白会被盖住）。
double _homePageSubFuncsBlockHeight(int itemCount) {
  if (itemCount <= 0) return 0;
  return 80.w;
}

/// 与 [HomePageNewBannerView] / [HomeTopBannerLayout] 同一套比例算实际高度，再与按宽度估算槽高取 [math.max]，
/// 避免窄屏联算后吸顶区高度仍按旧 150.h 偏小叠到「工具箱」。
double _homePageBannerSlotHeight(
    BuildContext context, double width, List<SubFunction> bannerBeans) {
  final fromAspect = width * 180 / 351 + 10.h;
  if (bannerBeans.isEmpty) {
    return fromAspect;
  }
  final n = bannerBeans.length;
  final smallCount = n > 2 ? n - 2 : 0;
  final nLarge = n > 2 ? 2 : n;
  final gap = 8.w;
  final innerRowW = (width - 12.w).clamp(120.0, 2000.0);
  final layout = HomeTopBannerLayout.compute(
    innerRowW: innerRowW,
    nLarge: nLarge,
    nSmall: smallCount,
    gap: gap,
  );
  double smallColH = 0;
  if (smallCount > 0) {
    smallColH =
        smallCount * layout.smallH + (smallCount - 1) * gap;
  }
  // 阔折外屏等窄宽下联算与像素取整可能差 1～2dp，多留余量避免大卡/小说推文区溢出叠到「工具箱」；
  // +12.h 与 [HomePageNewBannerView] 底部 [SizedBox] 一致，保证槽高容纳留白。
  final intrinsic =
      math.max(layout.largeH, smallColH) + 12.h + 12.h;
  return math.max(fromAspect, intrinsic);
}

class HomePageSliverTypeListView extends StatelessWidget {
  const HomePageSliverTypeListView({
    super.key,
    required this.categoryScrollController,
    required this.pageController,
    required this.onSize,
  });
  final ScrollController categoryScrollController;
  final PageController pageController;
  final void Function(Size size, int index) onSize;

  UserController get userController => Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    final subFunctionBeans =
        context.select<AiSquareProvider, List<SubFunction>?>(
              (provider) => provider.subFunctionBeans,
            ) ??
            [];
    final bannerBeans = context.select<AiSquareProvider, List<SubFunction>>(
      (value) => value.bannerBeans,
    );
    final width = ByScreenUtils.screenWidth - 24.w;
    final bannerH = _homePageBannerSlotHeight(context, width, bannerBeans);
    final subFuncsViewH = _homePageSubFuncsBlockHeight(subFunctionBeans.length);
    List<SubFunction> menuItemBeans =
        context.select<AiSquareProvider, List<SubFunction>>(
      (value) => value.menuItemBeans,
    );
    bool isShowBanner = context.select<AiSquareProvider, bool>(
      (value) => value.isShowBanner,
    );

    // 注意：banner view上报在 ai_square_page.dart 的 VisibilityDetector 中处理
    // 这里不再重复上报，避免重复
    const navBarH = kToolbarHeight;
    final caseHeaderH = 33.h;
    final categoryH = 56.h;
    bool couldAddBanner = false;
    // 不用 SafeArea，由 header 延伸至状态栏并用背景图铺满，避免顶部白色留白
    double maxH = navBarH +
        bannerH +
        subFuncsViewH +
        caseHeaderH +
        categoryH +
        ByScreenUtils.topSafeHeight;
    if (menuItemBeans.isNotEmpty && isShowBanner) {
      maxH += 100.h;
      couldAddBanner = true;
    }
    /// 与下方 [Container] 高度必须一致；原先 `maxHeight: maxH - 20` 与 `height: maxH` 不一致会导致
    /// 吸顶区溢出叠到「工具箱」一行（阔折外屏等明显）。
    final double headerPaintExtent = maxH;
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: StickyHeaderDelegate(
        minHeight: 46.h + ByScreenUtils.topSafeHeight,
        maxHeight: headerPaintExtent,
        onPinned: (pinned) {
          final h = pinned ? ByScreenUtils.topSafeHeight : 0.0;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            final p = context.read<AiSquareProvider>();
            if (p.pinnedHeaderHeight != h) {
              p.changepPinnedHeaderHeight(h);
            }
          });
        },
        child: Stack(
          children: [
            Container(
              height: headerPaintExtent,
              // color: Colors.red,
            ),
            Positioned.fill(
              child: ValueListenableBuilder<double>(
                valueListenable:
                    context.read<AiSquareProvider>().homeListScrollOffset,
                builder: (context, offset, _) {
                  final top = offset > 0 ? -offset : 0.0;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: top,
                        child: Obx(
                          () => Image.asset(
                            userController.isShowSpringStyle.value
                                ? "assets/springFestival/springFestival-4.png"
                                : "assets/v2/home/home_page_bg_top.png",
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: top,
                        height: ByScreenUtils.navigationBarHeight,
                        child: Column(
                          children: [
                            const Spacer(),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () async {
                                      // ///测试专用 -红色付费页
                                      // Get.toNamed("/rechargeMbgf5");
                                      // Get.toNamed(Routes.shortDramaPage);

                                      // Get.find<NewUserBenefitsController>()
                                      //     .showNewUserRedEnvelopeDialog();
                                    },
                                    child: Image.asset(
                                      "assets/v2/home/home_top_icon_new.png",
                                      height: 28.h,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                  const Spacer(),
                                  Obx(() {
                                    return (userController.user.value?.isVip ??
                                                0) ==
                                            0
                                        ? GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              final purchaseProvider = context
                                                  .read<PurchaseProvider>();
                                              if (purchaseProvider.preLoginCheck(
                                                    context,
                                                  ) ==
                                                  false) return;
                                              context
                                                  .read<LaunchProvider>()
                                                  .gotoPay(
                                                    context,
                                                    closePay: true,
                                                  );
                                            },
                                            child: Image.asset(
                                              userController
                                                      .isShowSpringStyle.value
                                                  ? "assets/springFestival/springFestival-2.png"
                                                  : "assets/ai/aiVideo/new_ai_video_app_bar_trailing.png",
                                              // width: 85.h,
                                              height: 36.h,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          )
                                        : Container();
                                  }),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              height: bannerH,
              bottom: categoryH +
                  caseHeaderH +
                  subFuncsViewH +
                  (couldAddBanner ? 70.h : -30.h),
              child: const ClipRect(
                child: NewHeaderView(),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: categoryH + caseHeaderH + (couldAddBanner ? 100.h : 00),
              child: _buildSubFunctions(context, subFunctionBeans),
            ),

            if (couldAddBanner)
              Positioned(
                left: 0,
                right: 0,
                bottom: 100.h,
                child: _buildBannerView(
                  context: context,
                  isShowBanner: isShowBanner,
                  menuItemBeans: menuItemBeans,
                ),
              ),

            Positioned(
              left: 0,
              right: 0,
              bottom: couldAddBanner ? 60.h : 55.h,
              child: _buildCasesHeader(context),
            ),

            ///优质案例
            MoneyExampleTabView(
              categoryScrollController: categoryScrollController,
              pageController: pageController,
              onSize: onSize,
            ),
          ],
        ),

        // child: Container(
        //   color: Colors.white,
        //   child: Column(
        //     children: [
        //       Image.asset(
        //         "assets/v2/home/home_page_bg_top.png",
        //         fit: BoxFit.fitWidth,
        //       ),
        //       // Column(
        //       //   children: [
        //       //     // const Spacer(),
        //       //     Padding(
        //       //       padding: EdgeInsets.symmetric(horizontal: 12.w),
        //       //       child: Row(
        //       //         children: [
        //       //           GestureDetector(
        //       //             behavior: HitTestBehavior.opaque,
        //       //             onTap: () {},
        //       //             child: Image.asset(
        //       //               "assets/v2/home/home_top_icon_new.png",
        //       //               height: 28.h,
        //       //               fit: BoxFit.fitHeight,
        //       //             ),
        //       //           ),
        //       //           const Spacer(),
        //       //           Obx(() {
        //       //             return (userController.user.value?.isVip ?? 0) == 0
        //       //                 ? GestureDetector(
        //       //               behavior: HitTestBehavior.opaque,
        //       //               onTap: () {
        //       //                 context
        //       //                     .read<LaunchProvider>()
        //       //                     .gotoPay(context, closePay: true);
        //       //               },
        //       //               child: Image.asset(
        //       //                 "assets/v2/home/home_app_bar_trailing.png",
        //       //                 // width: 85.h,
        //       //                 height: 28.h,
        //       //                 fit: BoxFit.fitHeight,
        //       //               ),
        //       //             )
        //       //                 : Container();
        //       //           }),
        //       //         ],
        //       //       ),
        //       //     ),
        //       //     const NewHeaderView(),
        //       //     _buildSubFunctions(context, subFunctionBeans),
        //       //     _buildCasesHeader(context),
        //       //     SizedBox(height: 10.h),
        //       //   ],
        //       // ),
        //     ],
        //   ),
        // ),
      ),
    );
  }

  /// 金刚卫效果
  Widget _buildSubFunctions(
    BuildContext context,
    List<SubFunction> subFunctionBeans,
  ) {
    if (subFunctionBeans.isEmpty) {
      return Container();
    }

    return SubFuncsView(functions: subFunctionBeans);
  }

  Widget _buildCasesHeader(BuildContext context) {
    final caseHeaderTitle = context.select<AiSquareProvider, String>(
      (value) => value.caseHeaderTitle,
    );
    return Padding(
      padding: EdgeInsets.only(top: 15.h),
      child: Offstage(
        offstage: caseHeaderTitle.isEmpty,
        child: Row(
          children: [
            SizedBox(width: 11.w),
            Image.asset(
              "assets/home/home_flower.png",
              width: 18.w,
              height: 18.h,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 6.w),
            ByWidgetsUtil.commonText(
              text: "优质案例",
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              textColor: ByColorUtil.CommonTextColor,
            ),
          ],
        ),
      ),
    );
  }

  ///banner数据 由后台配置
  _buildBannerView({
    required BuildContext context,
    required List<SubFunction>? menuItemBeans,
    required bool isShowBanner,
  }) {
    if (menuItemBeans != null) {
      if (menuItemBeans.isNotEmpty && isShowBanner) {
        final bannerBean = menuItemBeans.first;
        Get.log("获取到的数据=====> ${bannerBean.imgUrl}");
        return Stack(
          children: [
            CommonButton(
              color: Colors.transparent,
              minSize: 0,
              padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                bottom: 0.h,
                top: 8.w,
              ),
              borderRadius: BorderRadius.zero,
              onPressed: () {
                ByNavigatorUtil.reportDataPoint(
                  pageTag: "banner_click",
                  operateType: "click",
                  funcDetailTag: bannerBean.id.toString(),
                  funcDetailImg: bannerBean.imgUrl,
                  extra: {"position": "ai_square"},
                );
                ByCommonUtils.subFunctionCase(context, bannerBean);
              },
              child: BYImageView.normal(
                imageUrl: bannerBean.imgUrl,
                width: double.infinity,
                height: 80.h,
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              right: 0.w,
              top: -5.w,
              child: GestureDetector(
                onTap: () {
                  context.read<AiSquareProvider>().closeBannerEvent();
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
    }
    return const SizedBox.shrink();
  }
}

///变现案例的tab_view
class MoneyExampleTabView extends StatelessWidget {
  final ScrollController categoryScrollController;
  final PageController pageController;
  final void Function(Size size, int index) onSize;

  const MoneyExampleTabView({
    super.key,
    required this.categoryScrollController,
    required this.pageController,
    required this.onSize,
  });
  Widget _tabView(BuildContext context) {
    final selectedIndex = context.select<AiSquareProvider, int>(
      (val) => val.selectedIndex,
    );
    final subFunctionBeans =
        context.select<AiSquareProvider, List<SubFunction>?>(
              (provider) => provider.subFunctionBeans,
            ) ??
            [];
    final List<NewToolBoxCategoryBean> categoryBeans =
        context.select<AiSquareProvider, List<NewToolBoxCategoryBean>>(
      (val) => val.categoryBeans,
    );
    final bannerBeans = context.select<AiSquareProvider, List<SubFunction>>(
      (value) => value.bannerBeans,
    );
    final width = ByScreenUtils.screenWidth - 24.w;
    final bannerH = _homePageBannerSlotHeight(context, width, bannerBeans);
    final subFuncsViewH = _homePageSubFuncsBlockHeight(subFunctionBeans.length);
    const navBarH = kToolbarHeight;
    final caseHeaderH = 33.h;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0.h,
      child: ValueListenableBuilder<double>(
        valueListenable: context.read<AiSquareProvider>().homeListScrollOffset,
        builder: (context, offset, _) {
          double opacity = offset >=
                  (navBarH +
                      bannerH +
                      subFuncsViewH -
                      ByScreenUtils.topSafeHeight)
              ? ((offset -
                      navBarH -
                      bannerH -
                      subFuncsViewH +
                      ByScreenUtils.topSafeHeight) /
                  caseHeaderH)
              : 0.0;
          if (opacity >= 1) opacity = 1;

          return Column(
            children: [
              Container(
                color: Colors.white.withOpacity(opacity),
                width: double.infinity,
                height: ByScreenUtils.topSafeHeight,
              ),
              Container(
                clipBehavior: Clip.none,
                color: Colors.white,
                height: 56.h,
                padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
                child: ListView.builder(
                  clipBehavior: Clip.none,
                  controller: categoryScrollController,
                  padding: EdgeInsets.only(left: 12.w, right: 12.w),
                  itemCount: categoryBeans.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final selected = selectedIndex == index;
                    final category = categoryBeans[index];
                    // final hasIcon = selected && category.icon.isNotEmpty;
                    final hasIcon = category.icon.isNotEmpty;
                    return LayoutBuilder(
                      builder: (context, constraits) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final renderBox =
                              context.findRenderObject() as RenderBox?;
                          if (renderBox != null) {
                            onSize(renderBox.size, index);
                          }
                        });
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                right:
                                    index == categoryBeans.length - 1 ? 0 : 8.0,
                              ),
                              child: ByWidgetsUtil.btnWithIcon(
                                title: category.title,
                                iconPath: category.icon,
                                iconW: hasIcon ? 16.w : 0,
                                iconH: 16.h,
                                contentGap: hasIcon ? 3 : 0,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                textColor: selected
                                    ? ByColorUtil.TabTextColorSelected
                                    : ByColorUtil.CommonTextColor
                                        .withOpacity(0.6),
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                bgColor: selected
                                    ? const Color(0xFFEAEEFF)
                                    : const Color(0xFFF3F5F9),
                                boxDecoration: BoxDecoration(
                                  // border: Border.all(
                                  //   color: selected
                                  //       ? ByColorUtil.TabTextColorSelected
                                  //       : const Color(0xFFD9DDEB),
                                  //   width: 0.5,
                                  // ),
                                  color: selected
                                      ? const Color(0xFFEAEEFF)
                                      : const Color(0xFFF3F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onClick: () {
                                  if (selectedIndex == index) return;
                                  ByNavigatorUtil.reportDataPoint(
                                    pageTag: "home_video_square_cate",
                                    operateType: "click",
                                    funcDetailTag: category.id.toString(),
                                    funcDetailImg: category.icon,
                                  );
                                  context
                                      .read<AiSquareProvider>()
                                      .updateSelectedIndex(index);
                                  pageController.jumpToPage(index);
                                  pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.decelerate,
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              right: index == categoryBeans.length - 1 ? 0 : 8.0,
                              top: -8.h,
                              child: Offstage(
                                offstage: category.mark.isEmpty,
                                child: CachedNetworkImage(
                                  imageUrl: category.mark,
                                  width: 23.w,
                                  height: 15.h,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _tabView(context);
  }
}
