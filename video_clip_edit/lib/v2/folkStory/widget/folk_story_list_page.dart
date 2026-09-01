/*
  folk_story_list_page.dart
  民间故事列表页，支持不同风格展示
  Created by duncy on 25/4/23.
*/

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/by_global_providers.dart';
import 'package:video_clip_edit/modules/guid/providers/guide_pop_providers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/v2/folkStory/widget/folk_story_list_content_page.dart';
import 'package:video_clip_edit/v2/hotCreate/beans/hot_create_category_bean.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_provider.dart';
import 'package:video_clip_edit/v2/promote/beans/promotion_category_bean.dart';

import '../../../core/widget/toolbar/top_tool_bar.dart';
import '../../../utils/comon/by_color_utils.dart';
import '../../../utils/comon/by_colors.dart';
import '../../../utils/comon/by_widgets_util.dart';
import 'folk_story_list_header_page.dart';


class FolkStoryListPage extends StatefulWidget {
  const FolkStoryListPage({super.key});

  @override
  State<FolkStoryListPage> createState() => _FolkStoryListPageState();
}

class _FolkStoryListPageState extends State<FolkStoryListPage> {
  /// 列表项宽度
  final Map<int, double> _itemWidths = {};
  final PageController _pageController = PageController();
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final provider = context.read<NovelCreateProvider>();
    final offset = _controller.offset;
    provider.updateOffset(offset);
  }

  void _loadData() {
    final provider = context.read<NovelCreateProvider>();
    provider.dataLoadingError = false;

    /// 加载广播
    // provider.loadBroadcast();

    // 加载民间故事风格主题
    provider.loadFolkStoryTheme();

    /// 获取分类列表
    // provider.getCategoryConfig(folkTalesNovel: provider.isFolkTales);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EFF2),
      body: _buildView(context)
      );
  }

  Widget _buildView(BuildContext context) {
    final provider = context.read<NovelCreateProvider>();
    
    print("~~~~${provider.dataLoadingError},~~~~_____________________${provider.themeBean}_______,${provider.themeBean?.bgImage}");
    //数据加载异常
    if(provider.dataLoadingError){
      return _buildLoadingErrorWidget();
    }
    final categoryBeans =
        context.select<NovelCreateProvider, List<HotCreateCategoryBean>>(
            (provider) => provider.categoryBeans);
    //加载中
    if(provider.themeBean?.bgImage == null || categoryBeans.isEmpty){
      return _firstLoadingView();
    }

    return Stack(
          children: [
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
                    ByColorUtils.hexColor(provider.themeBean?.themeColor ?? ''),
                    const Color(0xFFE8EFF2),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  )
                ),
              )
            ),
            // ) : Positioned.fill(child: Container()),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: provider.themeBean?.bgImage != null ? CachedNetworkImage(
                                imageUrl: provider.themeBean!.bgImage,
                                fit: BoxFit.cover,
                              ):Container(),
            ),
            _buildBody(context),
            //上方工具栏 返回和攻略教程
              // const TopToolBar(guideType: GuideEntranceType.novelCreate),
            _buildTopBar(),
          ],
        );
  }

  Positioned _buildTopBar() {
    //初始化上方工具按钮
    return Positioned(
      top: 50.w,
      left: 17.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Image.asset(
                "assets/home/icon_back.png",
                color: Colors.white,
                width: 16,
                height: 16,
              ),
            ),
          ),
        ],
      ),
    );      
  }
  
  _buildBody(BuildContext context) {
    final provider = context.read<NovelCreateProvider>();
    final categoryBeans =
        context.select<NovelCreateProvider, List<HotCreateCategoryBean>>(
            (provider) => provider.categoryBeans);
    return Positioned.fill(
      child: NestedScrollView(
        /// 限制 NestedScrollView 的滚动行为
        physics: const ClampingScrollPhysics(),
        controller: _controller,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            FolkStoryListHeaderView(
              categoryScrollController: _categoryScrollController,
              pageController: _pageController,
              onSize: (Size size, int index) {
                _itemWidths[index] = size.width;
              },
            ),
          ];
        },
        body: categoryBeans.isEmpty
            ? contentNoData()
            : NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is ScrollEndNotification) {
                    final metrics = notification.metrics;
                    if (metrics is PageMetrics) {
                      int currentPage = metrics.page!.round();
                      context
                          .read<NovelCreateProvider>()
                          .updateSelectedCategoryIdx(currentPage);
                    }
                  }
                  return false;
                },
                child: FolkStoryListContentPage(
                  pageController: _pageController,
                  promoteType: provider.isFolkTales ? PromotionCategoryType.folkStory : PromotionCategoryType.others,
                  onPageChanged: (int index) {
                    _onPageChanged(index, context);
                  },
                ),
              ),
      ),
    );
  }
  //第一次进入的加载页面
  Widget _firstLoadingView() {
    return Container(
      color: const Color(0xFFE8EFF2),
      child: Stack(
        children: [
          Container(
            color: const Color(0xFFE8EFF2),
            child: const Center(
                // child: ByWidgetsUtil.activityIndicator(),
                child: CupertinoActivityIndicator(),
              ),
          ),
          _buildTopBar(),
        ] 
      ),
    );
  }

  //无数据显示
  Widget contentNoData({
    String? prompts,
    Color? promptsColor,
    Widget? bottomWidget,
  }) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
              text: TextSpan(
                text: prompts ?? "暂无数据",
                style: TextStyle(
                  color: promptsColor ??
                      ByColorUtil.CommonTextColor.withOpacity(0.5),
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }


  //数据加载失败页面
  _buildLoadingErrorWidget() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ByWidgetsUtil.commonText(
                text: '网络异常，请检查您的网络',
              ),
              SizedBox(
                height: 20.h,
              ),
              SizedBox(
                width: 100.w,
                child: ByWidgetsUtil.commonBtn(title: '重新加载', onClick: () => {_loadData()}))
            ],
          ),
        ),
        _buildTopBar(),
      ] 
    );
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
}
