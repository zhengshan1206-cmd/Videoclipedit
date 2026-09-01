import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/ai_draw_management_page.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_cases_list_view.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_work_management_provider.dart';

class AiDrawSquarePage extends StatefulWidget {
  const AiDrawSquarePage({super.key});

  @override
  State<AiDrawSquarePage> createState() => _AiDrawSquarePageState();
}

class _AiDrawSquarePageState extends State<AiDrawSquarePage> {
  final _carouselController = CarouselSliderController();
  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(),
          _buildContents(),
          _buildAppBar(context),
        ],
      ),
    );
  }

  /// ******************************** data ********************************
  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AiSquareProvider>();
      provider.updateFinishedNum(12344);
      provider.loadTabsConfig();
      _loadSquareListData();
      provider.loadHomeBanner();
    });
  }

  void _loadSquareListData({bool reset = false}) {
    final provider = context.read<AiSquareProvider>();
    provider.loadAiSquareData(
      reset: reset,
      onSuccess: (hasMore) {},
      onFailed: () {},
    );
  }

  /// ******************************** data ********************************

  /// ******************************** UI ********************************

  _buildContents() {
    byDebugPrint("_buildContents", tag: "XXXXXXXX:");
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      top: ByScreenUtils.navigationBarHeight,
      child: EasyRefresh(
        triggerAxis: Axis.vertical,
        refreshOnStart: false,
        onRefresh: () {
          _loadSquareListData(reset: true);
        },
        onLoad: _loadSquareListData,
        child: CustomScrollView(
          slivers: [
            // _buildBanner(),
            // _buildCasesType(),
            _buildCasesList(),
          ],
        ),
      ),
    );
  }

  Positioned _buildAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: ByScreenUtils.navigationBarHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage("assets/ai/ai_app_bar_bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent, // AppBar 背景透明
          elevation: 0,
          leading: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              EasyLoading.dismiss();
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
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/ai/ai_draw_app_bar_bg.png",
                height: 17,
                fit: BoxFit.fitHeight,
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ByNavRouterUtils.push(
                    context,
                    ChangeNotifierProvider(
                      create: (context) => AiDrawWorkManagementProvider(),
                      child: const AiDrawManagementPage(),
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/ai/ai_draw_records.png",
                        width: 12,
                        height: 12,
                      ),
                      const SizedBox(width: 5),
                      ByWidgetsUtil.commonText(
                        text: "生成记录",
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        textColor: const Color(0xFF0E1840).withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildCasesList() {
    return const AiCasesListView();
  }

  _buildBanner() {
    final banners = [
      "assets/ai/ai_square_vip.png",
      "assets/ai/ai_square_vip.png",
      "assets/ai/ai_square_vip.png",
    ];
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        height: 140.h,
        child: CarouselSlider(
          carouselController: _carouselController,
          items: banners.map((e) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15.w),
              child: Image.asset(
                e,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 0.85,
            initialPage: 1,
            enableInfiniteScroll: false,
            reverse: false,
            autoPlay: false,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.3,
            onPageChanged: (index, reason) {
              // _currentPage = index;
              // context
              //     .read<AiDrawProvider>()
              //     .updateSelectedCaseId(_styleCases[index].id);
              // setState(() {});
            },
            scrollDirection: Axis.horizontal,
          ),
        ),
      ),
    );
  }

  /// ******************************** UI ********************************
}
