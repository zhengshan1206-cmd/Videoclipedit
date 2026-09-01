import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/modules/profile/widgets/mine_words_managment_page_view.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_words_management_provider.dart';
import 'package:video_clip_edit/modules/profile/widgets/mine_words_sliver_type_list_view.dart';

class MineWordsManagementPage extends StatefulWidget {
  const MineWordsManagementPage({
    super.key,
  });
  @override
  State<MineWordsManagementPage> createState() =>
      _MineWordsManagementPageState();
}

class _MineWordsManagementPageState extends State<MineWordsManagementPage> {
  final tips = "文案在云端存储7天，过期无法恢复，请及时保存。";
  final PageController _pageController = PageController();
  final ScrollController _categoryScrollController = ScrollController();
  final Map<int, double> _itemWidths = {};
  @override
  void initState() {
    context.read<MineWordsManagementProvider>().selectedCategory = 0;

    super.initState();
    // 上报页面进入埋点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ByNavigatorUtil.reportDataPoint(
        pageTag: "myworks_list_txt_extraction_works",
        operateType: "view",
        funcDetailTag: "",
        funcDetailImg: "",
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, BuildContext context) {
    double offset = 0;
    for (var i = 0; i < index; i++) {
      offset += _itemWidths[i] ?? 0;
    }

    offset = offset -
        (ByScreenUtils.screenWidth - 24.w) / 2 +
        (_itemWidths[index] != null ? (_itemWidths[index]! - 8) : 0) / 2;

    _categoryScrollController.animateTo(
      offset.clamp(
        0.0,
        _categoryScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Stack(
        children: [
          NestedScrollView(
            physics: const ClampingScrollPhysics(),
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 8.h,
                      left: 12.w,
                      right: 12.w,
                    ),
                    child: ByWidgetsUtil.commonTipsBar(tips),
                  ),
                ),
                MineWordsSliverTypeListView(
                  categoryScrollController: _categoryScrollController,
                  pageController: _pageController,
                  onSize: (Size size, int index) {
                    _itemWidths[index] = size.width;
                  },
                ),
              ];
            },
            body: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollEndNotification) {
                  final metrics = notification.metrics;
                  if (metrics is PageMetrics) {
                    int currentPage = metrics.page!.round();
                    context
                        .read<MineWordsManagementProvider>()
                        .updateSelectedCategory(currentPage);
                  }
                }
                return false;
              },
              child: MineWordsManagmentPageView(
                pageController: _pageController,
                onPageChanged: (int index) {
                  _onPageChanged(index, context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return ByWidgetsUtil.appBar(
      context: context,
      title: "我的文案",
      actions: [],
      backgroundColor: Colors.white,
    );
  }
}
