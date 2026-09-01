import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:video_clip_edit/v2/hotCreate/widgets/novel_list_cell.dart';
import 'package:video_clip_edit/v2/hotCreate/beans/hot_create_novel_bean.dart';
import 'package:video_clip_edit/v2/hotCreate/beans/hot_create_category_bean.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_provider.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_single_provider.dart';
import 'package:video_clip_edit/v2/promote/beans/promotion_category_bean.dart';

class NovelListPage extends StatefulWidget {
  const NovelListPage({
    super.key,
    required this.index,
    required this.categoryBean,
    required this.promoteType,
  });

  final int index;
  final HotCreateCategoryBean categoryBean;

  final PromotionCategoryType promoteType;

  @override
  State<NovelListPage> createState() => _NovelListPageState();
}

class _NovelListPageState extends State<NovelListPage>
    with AutomaticKeepAliveClientMixin {
  final EasyRefreshController _easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  bool _hasMore = true;

  @override
  bool get wantKeepAlive => true;

  @override
  initState() {
    super.initState();
    _refresh(context: context, showLoading: true);
  }

  // 上拉加载更多
  Future<void> _loadMore({
    required BuildContext context,
  }) async {
    final provider = context.read<NovelCreateSingleProvider>();
    final outerProvider = context.read<NovelCreateProvider>();
    final categoryId = outerProvider.categoryBeans[widget.index].id;
    provider.getNovelList(
      refresh: false,
      showLoading: false,
      themeId:
          outerProvider.isFolkTales ? "folk_tales_novel" : "hot_copy_novel",
      categoryId: categoryId.toString(),
      onSuccess: (hasMore) {
        _hasMore = hasMore;
        setState(() {});
        _easyRefreshController.finishLoad(
            hasMore ? IndicatorResult.success : IndicatorResult.noMore, true);
      },
      onFailed: () {
        _easyRefreshController.finishLoad(IndicatorResult.fail, false);
        setState(() {});
      },
    );
  }

  // 下拉刷新
  Future<void> _refresh({
    bool showLoading = false,
    required BuildContext context,
  }) async {
    final provider = context.read<NovelCreateSingleProvider>();
    final outerProvider = context.read<NovelCreateProvider>();
    final categoryId = outerProvider.categoryBeans[widget.index].id;
    provider.getNovelList(
      refresh: true,
      showLoading: showLoading,
      categoryId: categoryId.toString(),
      themeId:
          outerProvider.isFolkTales ? "folk_tales_novel" : "hot_copy_novel",
      onSuccess: (hasMore) {
        log("加载更多===");
        _hasMore = hasMore;
        _easyRefreshController.finishRefresh(IndicatorResult.success, false);
        if (hasMore) {
          _easyRefreshController.resetFooter();
        }
        setState(() {});
      },
      onFailed: () {
        _easyRefreshController.finishRefresh(IndicatorResult.fail, false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final novelBeans =
        context.select<NovelCreateSingleProvider, List<HotCreateNovelBean>>(
      (value) => value.novelBeans,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: EasyRefresh(
        triggerAxis: Axis.vertical,
        controller: _easyRefreshController,
        onLoad: () => _loadMore(context: context),
        onRefresh: () => _refresh(context: context),
        child: novelBeans.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/home/nothing_bg.png',
                      width: 180,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '搜索无结果',
                      style: TextStyle(color: Color(0xFF999999), fontSize: 16),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: novelBeans.length,
                itemBuilder: (context, index) {
                  if (index < 0 || index >= novelBeans.length)
                    return const SizedBox();
                  return NovelListCell(
                    novelBean: novelBeans[index],
                    index: index,
                    noMore: !_hasMore,
                    isLast: index == novelBeans.length - 1,
                    promoteType: widget.promoteType,
                  );
                },
              ),
      ),
    );
  }
}
