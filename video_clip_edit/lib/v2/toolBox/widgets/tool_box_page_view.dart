import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:video_clip_edit/v2/toolBox/widgets/tool_box_gride_view.dart';
import 'package:video_clip_edit/v2/toolBox/providers/new_tool_box_provider.dart';
import 'package:video_clip_edit/v2/toolBox/beans/new_tool_box_category_bean.dart';
import 'package:video_clip_edit/v2/toolBox/providers/home_gride_view_provider.dart';

enum ToolBoxPageViewType {
  /// 故事创作
  story(0),

  /// 大图(1列)
  large(1),

  /// 普通(2列)
  normal(2);

  final int rawValue;

  const ToolBoxPageViewType(this.rawValue);

  static ToolBoxPageViewType fromRawValue(int rawValue) {
    for (final value in ToolBoxPageViewType.values) {
      if (value.rawValue == rawValue) {
        return value;
      }
    }
    return ToolBoxPageViewType.normal;
  }

  @override
  String toString() => 'ToolBoxPageViewType($rawValue)';
}

/// 工具底部的PageView整体
class ToolBoxPageView extends StatelessWidget {
  const ToolBoxPageView({
    super.key,
    required this.pageController,
    required this.onPageChanged,
  });
  final PageController pageController;
  final void Function(int index) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final List<NewToolBoxCategoryBean> categoryBeans =
        context.select<NewToolBoxProvider, List<NewToolBoxCategoryBean>>(
      (val) => val.categoryBeans,
    );

    return PageView.builder(
      physics: const PageScrollPhysics(), // 指定滚动物理行为
      controller: pageController,
      onPageChanged: onPageChanged,
      itemCount: categoryBeans.length,
      itemBuilder: (context, index) {
        final bean = categoryBeans[index];
        return ChangeNotifierProvider(
          create: (BuildContext context) => HomeGrideViewProvider(),
          child: ToolBoxSingleGrideView(
            bean: bean,
            index: index,
            type: ToolBoxPageViewType.fromRawValue(bean.style),
          ),
        );
      },
    );
  }
}

/// 单个九宫格列表
class ToolBoxSingleGrideView extends StatefulWidget {
  const ToolBoxSingleGrideView({
    super.key,
    required this.type,
    required this.index,
    required this.bean,
  });

  final int index;
  final ToolBoxPageViewType type;
  final NewToolBoxCategoryBean bean;

  @override
  State<ToolBoxSingleGrideView> createState() => _ToolBoxSingleGrideViewState();
}

class _ToolBoxSingleGrideViewState extends State<ToolBoxSingleGrideView>
    with AutomaticKeepAliveClientMixin {
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
    final toolBoxProvider = context.read<NewToolBoxProvider>();
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
    final toolBoxProvider = context.read<NewToolBoxProvider>();
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
        includeBottomSafeInset: false,
      ),
    );
  }
}
