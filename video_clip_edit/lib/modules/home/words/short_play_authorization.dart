import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_clip_edit/modules/home/beans/home_broadcast_bean.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/home/widgets/hot_auth_view.dart';
import 'package:video_clip_edit/modules/home/widgets/hot_rank_view.dart';
import 'package:video_clip_edit/modules/home/widgets/marquee_view.dart';
import 'package:video_clip_edit/providers/home_provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_datetime_ext.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

class ShortPlayAuthorizationPage extends StatefulWidget {
  const ShortPlayAuthorizationPage({super.key});

  @override
  State<ShortPlayAuthorizationPage> createState() =>
      _ShortPlayAuthorizationPageState();
}

class _ShortPlayAuthorizationPageState
    extends State<ShortPlayAuthorizationPage> {
  final colors = [
    [const Color(0xFFFF3838), const Color(0xFFFF3EAB)],
    [const Color(0xFFFF7538), const Color(0xFFFFA313)],
    [const Color(0xFF5C4CF7), const Color(0xFF7E71FE)],
  ];

  List<HomeBroadcastBean> broadcastBeans = [];
  List<HotAuthBean> hotAuthList = [];

  @override
  void initState() {
    super.initState();

    final provider = context.read<HomePageProvider>();

    provider.loadBanner();

    /// 自功能列表
    provider.loadHotlist();

    provider.loadTuixiaoguoUrl();
  }

  @override
  Widget build(BuildContext context) {
    hotAuthList = context.select<HomePageProvider, List<HotAuthBean>?>(
            (provider) => provider.hotAuthBeans) ??
        [];

    broadcastBeans = context.select<HomePageProvider, List<HomeBroadcastBean>?>(
            (provider) => provider.broadcastBeans) ??
        [];
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      body: Consumer<HomePageProvider>(
        builder: (BuildContext c, HomePageProvider p, Widget? child) {
          return Stack(
            children: [
              EasyRefresh(
                footer: const MaterialFooter(clamping: true, color: Colors.red),
                onRefresh: () {
                  final HomePageProvider homePageProvider =
                      context.read<HomePageProvider>();
                  homePageProvider.resetPages();
                  homePageProvider.loadHotlist();
                },
                onLoad: () {
                  final HomePageProvider homePageProvider =
                      context.read<HomePageProvider>();
                  homePageProvider.loadHotlist();
                },
                child: CustomScrollView(
                  slivers: [
                    /// Banner + 跑马灯
                    _buildMainFunctions(context),

                    SliverPadding(
                      padding: EdgeInsets.only(
                          top: 15.h, left: 12.w, right: 12.w, bottom: 11.h),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              "assets/home/home_hot.png",
                              width: 20.w,
                              height: 20.w,
                            ),
                            SizedBox(width: 6.w),
                            Stack(
                              children: [
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: Container(
                                    width: 70.w,
                                    height: 8.h,
                                    decoration: BoxDecoration(
                                      color: ByColorUtil.HomeHotAuthTitleBg,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(2.h),
                                        bottomLeft: Radius.circular(2.h),
                                        bottomRight: Radius.circular(2.h),
                                        topRight: Radius.circular(6.h),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  "热门授权",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: ByColorUtil.MainTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    /// 热门授权
                    SliverList.builder(
                      itemCount: hotAuthList.length,
                      itemBuilder: (context, index) {
                        final auth = hotAuthList[index];
                        return Container(
                          padding: EdgeInsets.all(12.w),
                          margin: EdgeInsets.only(
                            bottom: 8.h,
                            left: 12.w,
                            right: 12.w,
                          ),
                          decoration: BoxDecoration(
                            color: ByColorUtil.WhiteColor,
                            borderRadius: BorderRadius.circular(16.w),
                            border: Border.all(
                              color:
                                  ByColorUtil.MainTextColor.withOpacity(0.05),
                            ),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16.w),
                                    child: SizedBox(
                                      width: 100.w,
                                      height: 126.h,
                                      child: CachedNetworkImage(
                                        imageUrl: auth.coverUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: index > 2
                                        ? Container()
                                        : HotRankView(
                                            rank: 'Top${index + 1}',
                                            gradientColorStart: colors[index]
                                                [0],
                                            gradientColorEnd: colors[index][1],
                                          ),
                                  )
                                ],
                              ),
                              SizedBox(width: 15.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      auth.dramaName,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: ByColorUtil.MainTextColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Text(
                                          "${auth.joinPeopleNum}",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: ByColorUtil
                                                .HomeHotAuthNumberColor,
                                          ),
                                        ),
                                        Text(
                                          "人已推广   |   粉丝要求",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: ByColorUtil.MainTextColor,
                                          ),
                                        ),
                                        Text(
                                          "≥${auth.fansNum}",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: ByColorUtil
                                                .HomeHotAuthNumberColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Text(
                                          "历史最高收益：",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: ByColorUtil.MainTextColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Image.asset(
                                          "assets/home/home_auth_income.png",
                                          width: 18.w,
                                          height: 18.w,
                                        ),
                                        SizedBox(width: 6.5.w),
                                        Text(
                                          auth.maxIncome.amountConversion(),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: ByColorUtil
                                                .HomeHotAuthIncomeColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: () {
                                        if (auth.url.isNotEmpty) {
                                          openUrl(auth.url);
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 32.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              ByColorUtil.HomeHotAuthBtnBgColor,
                                          borderRadius:
                                              BorderRadius.circular(10.w),
                                        ),
                                        child: Text(
                                          "推广授权",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: ByColorUtil.MainTextColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(child: _buildAppBar(context)),
            ],
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildMainFunctions(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          /// banner
          Positioned(
            top: 0,
            left: 0,
            width: MediaQuery.of(context).size.width,
            height: 200.h,
            child: BannerView(
              urls: const ["assets/home/banner_short_play.png"],
              onTap: (index) {
                final provider = context.read<HomePageProvider>();
                if (provider.tuixiaoguoUrl.isEmpty) {
                  BotToast.showText(text: "暂无数据");
                } else {
                  openUrl(provider.tuixiaoguoUrl);
                }
              },
            ),
          ),

          _buildNotice(context),
        ],
      ),
    );
  }

  _buildNotice(BuildContext context) {
    byDebugPrint("broadcastBeans: $broadcastBeans", tag: "短剧授权:");
    return Padding(
      padding: EdgeInsets.only(top: 189.h, left: 12.w, right: 12.w),
      child: broadcastBeans.isEmpty
          ? Container()
          : MarqueeView(
              broadcastBeans: broadcastBeans,
            ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      height: statusBarHeight + 45.h,
      padding:
          EdgeInsets.only(left: 12.w, right: 12.w, top: statusBarHeight + 5.h),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ByNavRouterUtils.goBack(context);
            },
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/home/icon_back.png",
                width: 16,
                height: 16,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                context.read<LaunchProvider>().gotoPay(context, closePay: true),
            // onTap: () =>
            //     ByNavRouterUtils.push(context, const PurchasePageDark()),
            child: Image.asset(
              "assets/home/home_vip.png",
              width: 30.w,
              height: 30.w,
            ),
          )
        ],
      ),
    );
  }

  void openUrl(String url) {
    final Uri uri = Uri.parse(url);
    launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}
