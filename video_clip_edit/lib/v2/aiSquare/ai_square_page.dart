// ignore_for_file: unused_element
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:shanyan/shanyan.dart';
import 'package:video_clip_edit/routes/route_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:video_clip_edit/v2/toolBox/widgets/home_page_view.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/modules/guid/add_material_guid_page.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_style_cases_view.dart';
import 'package:video_clip_edit/modules/tool_box/beans/super_config_bean.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/v2/aiSquare/ai_monetization_creation_page.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/home/recreate/short_show_recreate_page.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/home_page_sliver_type_list_view.dart';
import 'package:video_clip_edit/v2/minorMode/controllers/minor_mode_controller.dart';
import 'package:video_clip_edit/v2/minorMode/widgets/minor_mode_home_header.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';

import '../../utils/pay/ios_buy_engine.dart';

///首页页面
class AiSquarePage extends StatefulWidget {
  const AiSquarePage({super.key});

  @override
  State<AiSquarePage> createState() => _AiSquarePageState();
}

class _AiSquarePageState extends State<AiSquarePage> {
  final PageController _pageController = PageController();
  final ScrollController _categoryScrollController = ScrollController();
  final Map<int, double> _itemWidths = {};
  final _customerController = ScrollController();
  // late   OneKeyLoginManager  oneKeyLoginManager ;

  late StreamSubscription _buySuccessStreamSubscription;
  double _lastVisibleFraction = 0.0; // 记录上次的可见度，用于判断是否从不可见变为可见
  bool _hasRequestedPermission = false; // 标记是否已经请求过权限，避免重复请求

  @override
  void initState() {
    super.initState();
    _customerController.addListener(_onScrolled);
    _loadData();

    // 页面进入时，延迟检查banner数据并上报（给接口请求一些时间）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkAndReportBanner();
      });
    });

    // 页面初始化时，延迟检查是否可以请求通知权限
    // 优化延迟时间：1.5秒，确保主要弹窗逻辑已执行完毕
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _checkAndRequestNotificationPermission();
        }
      });
    });
  }

  /// 检查并上报banner view事件
  void _checkAndReportBanner() {
    final provider = context.read<AiSquareProvider>();
    final menuItemBeans = provider.menuItemBeans;
    if (menuItemBeans.isNotEmpty && provider.isShowBanner) {
      ByNavigatorUtil.reportDataPoint(
        pageTag: "banner",
        operateType: "view",
        funcDetailTag: menuItemBeans.first.id.toString(),
        funcDetailImg: menuItemBeans.first.imgUrl,
        extra: {"position": "ai_square"},
      );
    }
  }

  /// 检查并请求通知权限（在首页且无弹窗时）
  /// 优化：减少延迟时间，使用统一的安全请求方法
  void _checkAndRequestNotificationPermission() {
    // 优化延迟时间：1秒，给弹窗足够时间显示
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      // 检查 MainController 是否已注册
      if (!Get.isRegistered<MainController>()) {
        return;
      }

      final mainController = Get.find<MainController>();

      // 检查是否可以安全请求权限（MainController内部已有防重复机制）
      if (mainController.canRequestNotificationPermissionOnHomePage()) {
        _hasRequestedPermission = true;
        // 使用统一的安全请求方法，带防重复机制
        mainController.requestNotificationPermissionSafely(delayMs: 300);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _customerController.removeListener(_onScrolled);
    _customerController.dispose();
    _categoryScrollController.dispose();
    _buySuccessStreamSubscription.cancel();
    super.dispose();
  }

  /// ******************************** data ********************************
  void _loadData() {
    final provider = context.read<AiSquareProvider>();
    provider.loadCashTutor();
    provider.loadCategory();
    provider.loadBannerData();
    provider.loadSubFunctions();
    // provider.getHomeScrollListConfig();
    // provider.getAiTipsData();
    // provider.getAiPresetsData();
    // provider.getAiVideoData();
    // provider.getAiMusicData();
    // provider.loadNoticeData();
    provider.loadHomeBanner();
    provider.loadMenuData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LaunchProvider>().loadPayTopList();
    });
    _buySuccessStreamSubscription = eventBus.on<BuySuccessEvent>().listen((e) {
      provider.isShowBanner = true;
      provider.loadMenuData();
    });
  }

  /// ******************************** data ********************************

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('ai_square_page'),
      onVisibilityChanged: (info) {
        // 当页面从不可见变为可见时（从其他页面切换回来），检查并上报banner view
        // 只有当可见度从0变为大于0时才上报，避免在可见期间重复上报
        if (_lastVisibleFraction == 0.0 && info.visibleFraction > 0.0) {
          // 上报home view事件
          ByNavigatorUtil.reportDataPoint(
            pageTag: "home",
            operateType: "view",
            funcDetailTag: "0",
            funcDetailImg: "",
          );
          // 延迟检查banner数据并上报
          Future.delayed(const Duration(milliseconds: 300), () {
            _checkAndReportBanner();
          });
        }
        _lastVisibleFraction = info.visibleFraction;

        // 当页面可见时，检查是否可以请求通知权限
        // 优化：只在从不可见变为可见时检查，避免重复请求
        if (info.visibleFraction > 0.0 &&
            _lastVisibleFraction == 0.0 &&
            !_hasRequestedPermission) {
          _checkAndRequestNotificationPermission();
        }
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Container(),
            _buildContents(context),
            // _buildTweetsLib(context),
            // _buildCahsTutor(context),
          ],
        ),
      ),
    );
  }

  /// ******************************** UI ********************************

  _buildContents(BuildContext context) {
    return Obx(() {
      final isMinorMode = MinorModeController.to.isMinorModeEnabled;

      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        top: 0,
        child: NestedScrollView(
          controller: _customerController,

          /// 限制 NestedScrollView 的滚动行为
          physics: const ClampingScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
              [
            if (isMinorMode)
              const MinorModeHomeSliverHeader()
            else
              HomePageSliverTypeListView(
                categoryScrollController: _categoryScrollController,
                pageController: _pageController,
                onSize: (Size size, int index) => _itemWidths[index] = size.width,
              ),
          ],
          body: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (isMinorMode) return false;
              if (notification is ScrollEndNotification) {
                final metrics = notification.metrics;
                if (metrics is PageMetrics) {
                  int currentPage = metrics.page!.round();
                  context
                      .read<AiSquareProvider>()
                      .updateSelectedIndex(currentPage);
                }
              }
              return false;
            },
            child: HomePageView(
              pageController: _pageController,
              onPageChanged: (int index) => _onPageChanged(index, context),
            ),
          ),
        ),
      );
    });
  }

  void _onPageChanged(int index, BuildContext context) {
    double offset = 0;
    for (var i = 0; i < index; i++) {
      offset += _itemWidths[i] ?? 0;
    }

    offset = offset -
        (ByScreenUtils.screenWidth - 24.w) / 2 +
        (_itemWidths[index] != null ? (_itemWidths[index]! - 8) : 0) / 2;
    final maxScrollExtent = _categoryScrollController.position.maxScrollExtent;
    _categoryScrollController.animateTo(
      offset.clamp(0.0, maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  SliverPadding _buildFunctions1(BuildContext context) {
    final isVipVal = context.watch<LaunchProvider>().launchInfo?.isVip ?? 0;
    final isVip = isVipVal == 1;
    return SliverPadding(
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 4.h,
      ),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 128.h,
          child: Row(
            children: [
              // _buildFunctionItem(
              //   imgPath: isVip
              //       ? "assets/ai/ai_square_recreate.png"
              //       : "assets/ai/ai_square_vip.png",
              //   ontap: () {
              //     if (isVip) {
              //       LaunchProvider provider = context.read<LaunchProvider>();
              //       final bool showCreateGuid = provider.shouldShowCreateGuid();
              //       ByNavRouterUtils.push(
              //         context,
              //         showCreateGuid == false
              //             ? ChangeNotifierProvider<ShowRecreateProvider>(
              //                 create: (context) => ShowRecreateProvider(),
              //                 child: const ShortShowRecreatePage<
              //                     ShowRecreateProvider>(),
              //               )
              //             : const AddMaterialGuidPage(),
              //       );

              //       if (showCreateGuid) {
              //         provider.checkCreateGuid();
              //       }
              //     } else {
              //       context.read<LaunchProvider>().gotoPay(
              //             context,
              //             closePay: true,
              //           );
              //     }
              //   },
              //   fit: BoxFit.fill,
              // ),
              SizedBox(
                width: 240.w,
                height: 180.h,
                child: BannerView(
                  autoplayDelay: 3000,
                  urls: [
                    "assets/ai/ai_squre_banner_oral.png",
                    isVip
                        ? "assets/ai/ai_square_recreate.png"
                        : "assets/ai/ai_square_vip.png",
                  ],
                  onTap: (index) {
                    if (index == 0) {
                      RouteUtils.gotoPage(context, "/ai_oral_videos");
                    } else {
                      if (isVip) {
                        LaunchProvider provider =
                            context.read<LaunchProvider>();
                        final bool showCreateGuid =
                            provider.shouldShowCreateGuid();
                        ByNavRouterUtils.push(
                          context,
                          showCreateGuid == false
                              ? ChangeNotifierProvider<ShowRecreateProvider>(
                                  create: (context) => ShowRecreateProvider(),
                                  child: const ShortShowRecreatePage<
                                      ShowRecreateProvider>(),
                                )
                              : const AddMaterialGuidPage(),
                        );

                        if (showCreateGuid) {
                          provider.checkCreateGuid();
                        }
                      } else {
                        context.read<LaunchProvider>().gotoPay(
                              context,
                              closePay: true,
                            );
                      }
                    }
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(children: [
                  Expanded(
                    child: _buildFunctionItem(
                      imgPath: "assets/ai/ai_square_tweets_auth.png",
                      ontap: () {
                        final provider = context.read<AiSquareProvider>();
                        provider.loadTuixiaoguoUrl(onSuccess: (url) {
                          ByNavRouterUtils.jumpWebViewPage(
                              context, "小说授权", url);
                        });
                      },
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: _buildFunctionItem(
                      imgPath: "assets/ai/ai_square_cash.png",
                      ontap: () {
                        ByNavRouterUtils.push(
                          context,
                          const AiMonetizationCreationPage(),
                        );
                      },
                      fit: BoxFit.fill,
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildFunctions2(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 8.h),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(
                child: _buildFunctionItem(
              imgPath: "assets/ai/ai_square_tweets.png",
              ontap: () {
                RouteUtils.gotoPage(context, "/ai_tweets");
              },
              fit: BoxFit.fitWidth,
            )),
            SizedBox(width: 7.w),
            Expanded(
                child: _buildFunctionItem(
              imgPath: "assets/ai/ai_square_clip.png",
              ontap: () {
                RouteUtils.gotoPage(context, "/ai_clip");
              },
              fit: BoxFit.fitWidth,
            )),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSubFunctions(BuildContext context) {
    final subFunctionBeans =
        context.select<AiSquareProvider, List<SubFunction>?>((provider) {
      return provider.subFunctionBeans;
    });
    if (subFunctionBeans == null || subFunctionBeans.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: SubFuncsView(
          functions: subFunctionBeans,
        ),
      ),
    );
  }

  Widget _buildFunctionItem({
    required String imgPath,
    required void Function() ontap,
    BoxFit? fit,
  }) {
    return InkWell(
      onTap: ontap,
      child: Image.asset(
        imgPath,
        fit: fit ?? BoxFit.cover,
      ),
    );
  }

  _buildCasesHeader(BuildContext context) {
    final caseHeaderTitle = context.select<AiSquareProvider, String>(
      (value) => value.caseHeaderTitle,
    );
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 15.h),
        child: Offstage(
          offstage: caseHeaderTitle.isEmpty,
          child: Row(
            children: [
              SizedBox(width: 11.w),
              Image.asset(
                "assets/ai/ai_cases_header.png",
                width: 18.w,
                height: 18.w,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 6.w),
              ByWidgetsUtil.commonText(
                text: "变现案例",
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                textColor: ByColorUtil.CommonTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildCasesList(BuildContext context) {
    return const AiStyleCasesView();
  }

  _buildTweetsLib(BuildContext context) {
    final vipcoursepublicize =
        context.read<LaunchProvider>().launchInfo!.vipcoursepublicize;

    Get.log("===vipcoursepublicize=== $vipcoursepublicize");

    return Positioned(
      left: 0,
      bottom: 120,
      child: Offstage(
        offstage: (context.read<LaunchProvider>().launchInfo!.isVip != 1) ||
            vipcoursepublicize.isEmpty,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ByNavRouterUtils.jumpWebViewPage(context, "", vipcoursepublicize);
            // final Uri uri = Uri.parse(vipcoursepublicize);
            // launchUrl(
            //   uri,
            //   mode: LaunchMode.externalApplication,
            // );
          },
          child: Image.asset(
            "assets/ai/home_tweets_lib.png",
            width: 32,
            height: 125,
          ),
        ),
      ),
    );
  }

  _buildCahsTutor(BuildContext context) {
    bool showTutor = false;
    SuperConfigBean? configBean =
        context.select<AiSquareProvider, SuperConfigBean?>(
            (value) => value.configBean);

    bool showCashTutor =
        context.select<AiSquareProvider, bool>((value) => value.showCashTutor);
    if (configBean != null) {
      if (configBean.list.homeRightFloatIcon != null) {
        if (configBean.list.homeRightFloatIcon!.icon.isNotEmpty) {
          showTutor = true;
        }
      }
    }

    if (showCashTutor == false) {
      showTutor = false;
    }

    log("configBean===> ${configBean?.toJson()}");
    return Positioned(
      right: 0,
      bottom: 125,
      child: Offstage(
        offstage: !showTutor,
        child: ScaleTransitionWidget(
          min: 0.95,
          max: 1.0,
          period: 1000,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (showTutor) {
                const wechatUrl = 'weixin://';
                if (await canLaunchUrl(Uri.parse(wechatUrl))) {
                  final url = context
                      .read<AiSquareProvider>()
                      .configBean!
                      .list
                      .homeRightFloatIcon!
                      .url
                      .valText;
                  ByNavRouterUtils.jumpWebViewPage(context, "", url);
                } else {
                  EasyLoading.showToast("由于您未安装微信，无法直接跳转客服。");
                }
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: showTutor
                      ? CachedNetworkImage(
                          imageUrl: configBean!.list.homeRightFloatIcon!.icon,
                          width: 90,
                          height: 90,
                        )
                      : Container(),
                ),
                showTutor
                    ? Positioned(
                        top: -15.h,
                        right: 1,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            log("点击了====");

                            context
                                .read<AiSquareProvider>()
                                .updateShowCashTutor(false);
                          },
                          child: Container(
                            // color: Colors.red,
                            width: 40.h,
                            height: 40.h,
                            alignment: Alignment.center,
                            child: Image.asset(
                              "assets/ai/ai_cartoon_config_close1.png",
                              width: 13.h,
                              height: 13.h,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ******************************** UI ********************************

  void _onScrolled() {
    context.read<AiSquareProvider>().updateOffset(_customerController.offset);
  }
}
