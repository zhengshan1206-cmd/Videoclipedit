import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/guide_page.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import 'package:video_clip_edit/v2/hotCreate/beans/hot_create_category_bean.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_provider.dart';
import 'package:video_clip_edit/v2/hotCreate/widgets/hot_create_page_view.dart';
import 'package:video_clip_edit/v2/hotCreate/widgets/sliver_pinned_header_view.dart';
import 'package:video_clip_edit/v2/promote/beans/promotion_category_bean.dart';
import 'package:video_clip_edit/widgets/common/right_navigation_bar.dart';

import '../../modules/guid/providers/guide_pop_providers.dart';

class HotNovelCreatePage extends StatefulWidget {
  const HotNovelCreatePage({super.key});

  @override
  State<HotNovelCreatePage> createState() => _HotNovelCreatePageState();
}

class _HotNovelCreatePageState extends State<HotNovelCreatePage> {
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

    /// 加载广播
    provider.loadBroadcast();

    /// 获取分类列表
    provider.getCategoryConfig(folkTalesNovel: provider.isFolkTales);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      body: Stack(
        children: [
          _buildBody(context),
          _buildAppBar(context),
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
            SliverPinnedHeaderView(
              categoryScrollController: _categoryScrollController,
              pageController: _pageController,
              onSize: (Size size, int index) {
                _itemWidths[index] = size.width;
              },
            ),
          ];
        },
        body: categoryBeans.isEmpty
            ? ByWidgetsUtil.commonNoData()
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
                child: HotCreatePageView(
                  pageController: _pageController,
                  promoteType: provider.isFolkTales
                      ? PromotionCategoryType.folkStory
                      : PromotionCategoryType.others,
                  onPageChanged: (int index) {
                    _onPageChanged(index, context);
                  },
                ),
              ),
      ),
    );
  }

  Positioned _buildAppBar(BuildContext context) {
    final provider = context.read<NovelCreateProvider>();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: ByScreenUtils.navigationBarHeight,
        decoration: const BoxDecoration(
          color: Color(0xFFF4F7F8),
          image: DecorationImage(
            image: AssetImage("assets/ai/ai_app_bar_bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          bottom: ByWidgetsUtil.appBarBottom(),
          bottomOpacity: 0,
          elevation: 0,
          leading: GestureDetector(
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
          title: ByWidgetsUtil.commonText(
            text: provider.isFolkTales ? "民间故事" : "爆文创作",
            textColor: ByColorUtil.CommonTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          centerTitle: true,
          actions: const [
            Center(
              //民间故事  爆文创作 novel_create	flutter
              // child: RightNavigationBar(entranceType: 3),
              child: RightNavigationBar(
                  entranceType: GuideEntranceType.novelCreate),
            )
          ],
        ),
      ),
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
