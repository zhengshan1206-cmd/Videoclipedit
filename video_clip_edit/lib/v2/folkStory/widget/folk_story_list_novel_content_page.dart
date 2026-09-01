/*
  folk_story_list_novel_content_page.dart
  民间故事列表页
  Created by duncy on 25/4/23.
*/

import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:video_clip_edit/v2/hotCreate/beans/hot_create_novel_bean.dart';
import 'package:video_clip_edit/v2/hotCreate/beans/hot_create_category_bean.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_provider.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_single_provider.dart';
import 'package:video_clip_edit/v2/promote/beans/promotion_category_bean.dart';

import 'folk_story_list_novel_cell.dart';

class FolkStoryListNovelPage extends StatefulWidget {
  const FolkStoryListNovelPage({
    super.key,
    required this.index,
    required this.categoryBean,
    required this.promoteType,
  });

  final int index;
  final HotCreateCategoryBean categoryBean;

  final PromotionCategoryType promoteType;

  @override
  State<FolkStoryListNovelPage> createState() => _FolkStoryListNovelPageState();
}

class _FolkStoryListNovelPageState extends State<FolkStoryListNovelPage>
    with AutomaticKeepAliveClientMixin {
  final EasyRefreshController _easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  bool _hasMore = true;
  bool _isFirstLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  initState() {
    super.initState();
    _refresh(context: context);
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
      themeId: outerProvider.themeId,
      categoryId: categoryId.toString(),
      onSuccess: (hasMore) {
        _hasMore = hasMore;
        setState(() {
        });
        _easyRefreshController.finishLoad(
            hasMore ? IndicatorResult.success : IndicatorResult.noMore, true);
      },
      onFailed: () {
        _easyRefreshController.finishLoad(IndicatorResult.fail, false);
        setState(() {
        });
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
      themeId: outerProvider.themeId,
      onSuccess: (hasMore) {
        _isFirstLoading = false;
        _hasMore = hasMore;
        _easyRefreshController.finishRefresh(IndicatorResult.success, false);
        if (hasMore) {
          _easyRefreshController.resetFooter();
        }
        setState(() {

        });
      },
      onFailed: () {
        _isFirstLoading = false;
        _easyRefreshController.finishRefresh(IndicatorResult.fail, false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);


    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isFirstLoading ? _firstLoadingView() : _contentView(),
    );
  }

  Widget _contentView() {
    final novelBeans =
        context.select<NovelCreateSingleProvider, List<HotCreateNovelBean>>(
      (value) => value.novelBeans,
    );
    return  EasyRefresh(
        // refreshOnStart: false,
        // footer: null,
        triggerAxis: Axis.vertical,
        controller: _easyRefreshController,
        onLoad: () => _loadMore(context: context),
        onRefresh: () => _refresh(context: context),
        // 当没有更多数据时，设置footer为一个”查看更多“的按钮
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: novelBeans.length,
          itemBuilder: (context, index) {
            return FolkStoryListNovelCell(
              novelBean: novelBeans[index],
              index: index,
              noMore: !_hasMore,
              isLast: index == novelBeans.length - 1,
              promoteType: widget.promoteType,
            );
          },
        ),
      );
  }

  //第一次进入的加载页面
  Widget _firstLoadingView() {
    return  const Center(
          child: CupertinoActivityIndicator(),
        );
  }
}
