import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/beans/home_broadcast_bean.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/home/recreate/short_show_list_page.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/home/widgets/home_hot_list_cell.dart';
import 'package:video_clip_edit/modules/home/widgets/home_hot_list_header.dart';
import 'package:video_clip_edit/modules/home/widgets/hot_auth_view.dart';
import 'package:video_clip_edit/modules/home/widgets/main_funcs_view.dart';
import 'package:video_clip_edit/modules/home/widgets/marquee_view.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/providers/home_provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final colors = [
    [const Color(0xFFFF3838), const Color(0xFFFF3EAB)],
    [const Color(0xFFFF7538), const Color(0xFFFFA313)],
    [const Color(0xFF5C4CF7), const Color(0xFF7E71FE)],
  ];

  @override
  void initState() {
    super.initState();

    /// 加载页面数据
    _loadData();
  }

  void _loadData() {
    final provider = context.read<HomePageProvider>();

    /// 自功能列表
    provider.loadSubFunctions();

    /// 推小果列表
    provider.loadHotlist();

    /// 加载广播
    provider.loadBroadcast();

    /// 加载banner
    provider.loadBanner();

    provider.loadTuixiaoguoUrl();

    provider.loadCreators();
  }

  @override
  Widget build(BuildContext context) {
    final List<HotAuthBean> hotAuthList =
        context.select<HomePageProvider, List<HotAuthBean>?>(
                (provider) => provider.hotAuthBeans) ??
            [];
    final beans =
        hotAuthList.length > 10 ? hotAuthList.sublist(0, 10) : hotAuthList;
    return Scaffold(
      body: Consumer<HomePageProvider>(
        builder:
            (BuildContext context, HomePageProvider provider, Widget? child) {
          return Stack(
            children: [
              EasyRefresh(
                onRefresh: () {
                  final HomePageProvider homePageProvider =
                      context.read<HomePageProvider>();
                  homePageProvider.resetPages();
                  homePageProvider.loadHotlist();
                },
                triggerAxis: Axis.vertical,
                child: CustomScrollView(
                  scrollDirection: Axis.vertical,
                  slivers: [
                    /// Banner + 主要功能
                    _buildMainFunctions(context),

                    /// 次要功能
                    _buildSubFunctions(context),

                    /// 跑马灯公告
                    _buildNotice(context),

                    /// 推小果列表
                    if (hotAuthList.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.only(
                            top: 15.h, left: 12.w, right: 12.w, bottom: 11.h),
                        sliver: const SliverToBoxAdapter(
                          child: HomeHotListHeader(),
                        ),
                      ),

                    /// 热门授权
                    hotAuthList.isEmpty
                        ? SliverToBoxAdapter(child: Container())
                        : SliverList.builder(
                            itemCount: beans.length,
                            itemBuilder: (context, index) {
                              if (index > beans.length) return Container();
                              final auth = beans[index];
                              return HomeHotListCell(
                                auth: auth,
                                colors: colors,
                                index: index,
                              );
                            },
                          )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildNotice(BuildContext context) {
    final List<HomeBroadcastBean>? broadcastBeans =
        context.select<HomePageProvider, List<HomeBroadcastBean>?>(
            (provider) => provider.broadcastBeans);
    return SliverToBoxAdapter(
      child: broadcastBeans == null || broadcastBeans.isEmpty
          ? Container()
          : Padding(
              padding: EdgeInsets.only(top: 25.h, left: 12.w, right: 12.w),
              child: MarqueeView(broadcastBeans: broadcastBeans),
            ),
    );
  }

  SliverToBoxAdapter _buildSubFunctions(BuildContext context) {
    final subFunctionBeans =
        context.select<HomePageProvider, List<SubFunction>?>((provider) {
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
            // child: Container(),
            child: BannerView(
              urls: const ["assets/home/banner.png"],
              onTap: (index) {
                ByNavRouterUtils.push(
                    context,
                    ChangeNotifierProvider(
                      create: (context) => ShowRecreateProvider(),
                      child: const ShortShowListPage<ShowRecreateProvider>(
                        type: ShortShowListPageType.shortShow,
                      ),
                    ));
              },
            ),
          ),
          Positioned(
            right: 12.w,
            top: 45.h,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.read<LaunchProvider>().gotoPay(context, closePay: true);
              },
              child: Image.asset(
                "assets/home/home_vip.png",
                width: 30.w,
                height: 30.w,
              ),
            ),
          ),

          /// main functions
          MainFuncsView(
            functions: [
              MainFunctionBean(url: "assets/home/main_func_1.png"),
              MainFunctionBean(url: "assets/home/main_func_2.png"),
              MainFunctionBean(url: "assets/home/main_func_3.png"),
            ],
          ),
        ],
      ),
    );
  }
}
