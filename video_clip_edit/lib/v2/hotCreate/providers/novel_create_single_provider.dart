/*
 * @Author: cold-x
 * @Date: 2025-04-14 17:58:13
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-04-28 17:26:29
 * @FilePath: /video_clip_edit/lib/v2/hotCreate/providers/novel_create_single_provider.dart
 * @Description: 
 */
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/hotCreate/beans/hot_create_novel_bean.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_provider.dart';

class NovelCreateSingleProvider extends BaseProvider {
  int page = 1;
  int size = 10;
  List<HotCreateNovelBean> novelBeans = [];

  ///搜索内容
  String searchContent = "";

  /// NovelCreateProvider引用
  NovelCreateProvider? _novelCreateProvider;

  /// 设置NovelCreateProvider引用
  void setNovelCreateProvider(NovelCreateProvider provider) {
    _novelCreateProvider = provider;
    // 监听搜索内容变化
    provider.addListener(_onSearchContentChanged);
  }

  /// 监听搜索内容变化
  void _onSearchContentChanged() {
    if (_novelCreateProvider != null) {
      final newSearchContent = _novelCreateProvider!.searchContent;
      final newSelectedCategoryIdx = _novelCreateProvider!.selectedCategoryIdx;

      // 检查搜索内容或分类是否发生变化
      bool shouldRefresh = newSearchContent != searchContent;

      if (shouldRefresh) {
        byDebugPrint("搜索内容变化: $searchContent -> $newSearchContent");
        searchContent = newSearchContent;
        // 重新加载数据，需要获取当前分类ID
        final categoryId = _getCurrentCategoryId();
        getNovelList(
          refresh: true,
          themeId: _novelCreateProvider!.themeId,
          categoryId: categoryId,
          showLoading: false,
        );
      }
    }
  }

  /// 获取当前分类ID
  String? _getCurrentCategoryId() {
    if (_novelCreateProvider != null &&
        _novelCreateProvider!.categoryBeans.isNotEmpty &&
        _novelCreateProvider!.selectedCategoryIdx >= 0 &&
        _novelCreateProvider!.selectedCategoryIdx <
            _novelCreateProvider!.categoryBeans.length) {
      return _novelCreateProvider!
          .categoryBeans[_novelCreateProvider!.selectedCategoryIdx].id
          .toString();
    }
    return null;
  }

  updateNovelBeans(List<HotCreateNovelBean> beans) {
    novelBeans = beans;
    notifyListeners();
  }

  ///更新搜索内容
  updateSearchContent(String searchContent) {
    this.searchContent = searchContent;
    notifyListeners();
  }

  /// [categoryId] 分类id
  /// [needDetail] 是否需要同时返回明细(如果需要，则会固定返回10条)  1需要 2不需要
  /// [themeId] 民间故事主题
  /// [title] 搜索内容
  getNovelList({
    bool refresh = false,
    String? categoryId,
    bool needDetail = false,
    required String themeId,
    required bool showLoading,
    void Function(bool hasMore)? onSuccess,
    void Function()? onFailed,
  }) {
    if (refresh) {
      page = 1;
    }

    // 使用NovelCreateProvider中的搜索内容
    final currentSearchContent =
        _novelCreateProvider?.searchContent ?? searchContent;

    HttpUtils.get(
      APIs.getNovelList,
      {
        "page": page,
        "size": size,
        "type": themeId,
        "need_detail": needDetail,
        "category_id": categoryId,
        "title": currentSearchContent,
      },
      showLoading: showLoading,
      success: (data) {
        byDebugPrint(data);
        final items = data["data"]["items"];
        List<HotCreateNovelBean> beans = List<HotCreateNovelBean>.from(
            items.map((e) => HotCreateNovelBean.fromJson(e)));

        // 关键：isRefresh 且返回空，直接清空并return
        if (refresh && beans.isEmpty) {
          updateNovelBeans([]);
          onSuccess?.call(false);
          return;
        }

        if (refresh) {
          novelBeans.clear();
        }
        final List<HotCreateNovelBean> results = List.from(novelBeans);

        page = results.addElementsByRemovingLast(beans,
            currentPage: page, pageSize: size);
        updateNovelBeans(results);
        onSuccess?.call(beans.isNotEmpty && beans.length % 10 == 0);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        onFailed?.call();
      },
    );
  }

  @override
  void dispose() {
    // 移除监听器
    _novelCreateProvider?.removeListener(_onSearchContentChanged);
    super.dispose();
  }
}
