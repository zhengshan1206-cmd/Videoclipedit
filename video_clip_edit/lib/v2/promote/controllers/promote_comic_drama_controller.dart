import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/controllers/base_controller.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';

import '../../../utils/pay/ios_buy_engine.dart';
import '../../aiSquare/widgets/ai_video_player.dart';

///漫剧controller
class PromoteComicDramaController extends BaseController {
  var multiStatus = MultiStatusType.statusLoading.obs;

  /// 漫剧列表
  var comicDramaList = <CloudVideoListBean>[];

  void onRefresh() {
    _getDataFromServer(true);
  }

  void onLoadMore() {
    _getDataFromServer(false);
  }

  void _getDataFromServer(bool isRefresh) {
    getComicDramaList(isRefresh);
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

  ///查询漫剧列表
  void getComicDramaList(bool isRefresh) async {
    if (isRefresh) {
      multiStatus.value = MultiStatusType.statusLoading;
      pageHelper.resetPage();
    }
    HttpUtils.get(
      APIs.cloudVideosList,
      {
        "type": "3", // 漫剧type为3
        "page": pageHelper.page,
        "pageSize": pageHelper.row,
      },
      success: (data) {
        List listData = data["data"]["data"] ?? [];
        List<CloudVideoListBean> comicDramaBeans =
            listData.map((e) => CloudVideoListBean.fromJson(e)).toList();

        multiStatus.value = MultiStatusType.statusContent;
        if (isRefresh) {
          comicDramaList.clear();
        }
        comicDramaList.addAll(comicDramaBeans);
        if (comicDramaList.isEmpty) {
          multiStatus.value = MultiStatusType.statusEmpty;
        }
        pageHelper.addPage();

        final hasMore = comicDramaBeans.length < pageHelper.row ? false : true;
        refreshSuccess(isRefresh, hasMore);

        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        refreshFailed(isRefresh);
      },
    );
  }

  @override
  void onClose() {
    _buySuccessStreamSubscription.cancel();
    super.onClose();
  }

  ///关闭banner
  closeBannerEvent() {
    isShowBanner = false;
    update();
  }
}
