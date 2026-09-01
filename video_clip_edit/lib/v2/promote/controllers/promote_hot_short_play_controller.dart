import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/controllers/base_controller.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';

import '../../../utils/pay/ios_buy_engine.dart';
import '../../aiSquare/widgets/ai_video_player.dart';

///热播短剧controller
class PromoteHotShortPlayController extends BaseController {
  var multiStatus = MultiStatusType.statusLoading.obs;

  /// 热门短剧列表
  var hotShortPlayList = <CloudVideoListBean>[];

  /// 与 EasyRefresh、CustomScrollView 共用
  final ScrollController scrollController = ScrollController();

  Completer<void>? _refreshCompleter;

  /// 返回 Future，由 EasyRefresh 在 Future 完成时自动结束刷新（不依赖 finishRefresh）
  Future<void> onRefresh() async {
    _refreshCompleter = Completer<void>();
    getHotShortPlayList(true);
    return _refreshCompleter!.future;
  }

  void onLoadMore() {
    _getDataFromServer(false);
  }

  void _getDataFromServer(bool isRefresh) {
    getHotShortPlayList(isRefresh);
  }

  ///是否展示banner
  bool isShowBanner = true;

  late StreamSubscription _buySuccessStreamSubscription;

  @override
  void onInit() {
    _buySuccessStreamSubscription = eventBus.on<BuySuccessEvent>().listen((e) {
      isShowBanner = true;
      update();
    });
    super.onInit();
  }

  @override
  void fetchData() {
    _getDataFromServer(true);
  }

  ///查询热门短剧列表
  void getHotShortPlayList(bool isRefresh) async {
    if (isRefresh) {
      multiStatus.value = MultiStatusType.statusLoading;
      pageHelper.resetPage();
    }
    HttpUtils.get(
      APIs.cloudVideosList,
      {"type": "2", "page": pageHelper.page, "pageSize": pageHelper.row},
      success: (data) {
        byDebugPrint(data["data"], tag: "热门短剧：");
        List listData = data["data"]["data"] ?? [];
        List<CloudVideoListBean> shortPlayBeans = listData
            .map((e) => CloudVideoListBean.fromJson(e))
            .toList();

        multiStatus.value = MultiStatusType.statusContent;
        if (isRefresh) {
          hotShortPlayList.clear();
        }
        hotShortPlayList.addAll(shortPlayBeans);
        if (hotShortPlayList.isEmpty) {
          multiStatus.value = MultiStatusType.statusEmpty;
        }
        pageHelper.addPage();

        update();
        _refreshCompleter?.complete();
        _refreshCompleter = null;
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        update();
        _refreshCompleter?.complete();
        _refreshCompleter = null;
      },
    );
  }

  @override
  void onClose() {
    _buySuccessStreamSubscription.cancel();
    scrollController.dispose();
    super.onClose();
  }

  ///关闭banner
  closeBannerEvent() {
    isShowBanner = false;
    update();
  }
}
