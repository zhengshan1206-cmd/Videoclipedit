import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:video_clip_edit/v2/minorMode/controllers/minor_mode_controller.dart';
import 'package:video_clip_edit/v2/toolBox/widgets/tool_box_page_view.dart';
import 'package:video_clip_edit/v2/toolBox/widgets/tool_box_gride_view.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/toolBox/beans/new_tool_box_category_bean.dart';
import 'package:video_clip_edit/v2/toolBox/providers/home_gride_view_provider.dart';

/// 工具底部的PageView整体
class HomePageView extends StatelessWidget {
  const HomePageView({
    super.key,
    required this.pageController,
    required this.onPageChanged,
  });
  final PageController pageController;
  final void Function(int index) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final List<NewToolBoxCategoryBean> categoryBeans =
        context.select<AiSquareProvider, List<NewToolBoxCategoryBean>>(
      (val) => val.categoryBeans,
    );

    return Obx(() {
      final isMinorMode = MinorModeController.to.isMinorModeEnabled;
      final itemCount = isMinorMode ? 1 : categoryBeans.length;

      return PageView.builder(
        controller: pageController,
        onPageChanged: isMinorMode ? null : onPageChanged,
        itemCount: itemCount,
        scrollDirection: Axis.horizontal,
        physics: isMinorMode
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        itemBuilder: (context, index) {
          final bean = categoryBeans[index];
          return ChangeNotifierProvider(
            create: (BuildContext context) => HomeGrideViewProvider(),
            child: HomePageSingleGrideView(
              bean: bean,
              index: index,
              type: ToolBoxPageViewType.fromRawValue(bean.style),
            ),
          );
        },
      );
    });
  }
}

class HomePageSingleGrideView extends StatefulWidget {
  const HomePageSingleGrideView({
    super.key,
    required this.type,
    required this.index,
    required this.bean,
  });

  final int index;
  final ToolBoxPageViewType type;
  final NewToolBoxCategoryBean bean;

  @override
  State<HomePageSingleGrideView> createState() =>
      _HomePageSingleGrideViewSingleGrideViewState();
}

class _HomePageSingleGrideViewSingleGrideViewState
    extends State<HomePageSingleGrideView> with AutomaticKeepAliveClientMixin {
  final EasyRefreshController _easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        context
            .read<HomeGrideViewProvider>()
            .loadList(categoryId: widget.bean.id);
      });
    }
    super.initState();
  }

  // 上拉加载更多
  Future<void> _loadMore({
    required BuildContext context,
  }) async {
    final provider = context.read<HomeGrideViewProvider>();
    final toolBoxProvider = context.read<AiSquareProvider>();
    final categoryId = toolBoxProvider.categoryBeans[widget.index].id;
    provider.loadList(
      categoryId: categoryId,
      isRefresh: false,
      onSuccess: (hasMore) {
        _easyRefreshController.finishLoad(
          hasMore ? IndicatorResult.success : IndicatorResult.noMore,
          true,
        );
      },
      onFailed: () {
        _easyRefreshController.finishLoad(
          IndicatorResult.fail,
          false,
        );
      },
    );
  }

  // 下拉刷新
  Future<void> _refresh({
    required BuildContext context,
  }) async {
    final provider = context.read<HomeGrideViewProvider>();
    final toolBoxProvider = context.read<AiSquareProvider>();
    final categoryId = toolBoxProvider.categoryBeans[widget.index].id;
    provider.loadList(
      categoryId: categoryId,
      isRefresh: true,
      onSuccess: (hasMore) {
        _easyRefreshController.finishRefresh(IndicatorResult.success, false);
        if (hasMore) {
          _easyRefreshController.resetFooter();
        }
      },
      onFailed: () {
        _easyRefreshController.finishRefresh(
          IndicatorResult.fail,
          false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isLarge = widget.type == ToolBoxPageViewType.large;
    return EasyRefresh(
      // refreshOnStart: true,
      triggerAxis: Axis.vertical,
      controller: _easyRefreshController,
      onLoad: () => _loadMore(context: context),
      onRefresh: () => _refresh(context: context),
      child: ToolBoxGrideView(
        isLarge: isLarge,
        index: widget.index,
      ),
    );
  }
}
