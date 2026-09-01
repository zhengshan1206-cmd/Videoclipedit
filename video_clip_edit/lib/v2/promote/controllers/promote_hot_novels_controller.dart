import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/controllers/base_controller.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/hotCreate/beans/hot_create_novel_bean.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';

import '../../../utils/pay/ios_buy_engine.dart';
import '../../aiSquare/widgets/ai_video_player.dart';

///热门小说controller
class PromoteHotNovelsController extends BaseController {
  var multiStatus = MultiStatusType.statusLoading.obs;

  /// 热门小说列表
  var hotNovelsList = <HotCreateNovelBean>[];

  void onRefresh() {
    _getDataFromServer(true);
  }

  void onLoadMore() {
    _getDataFromServer(false);
  }

  void _getDataFromServer(bool isRefresh) {
    getHotNovelsList(isRefresh);
  }

  ///是否展示banner
  bool isShowBanner = true;

  late StreamSubscription _buySuccessStreamSubscription;

  @override
  void onInit() {
    _buySuccessStreamSubscription = eventBus.on<BuySuccessEvent>().listen((e){
      isShowBanner = true;
      update();
    });
    super.onInit();
  }

  @override
  void fetchData() {
    _getDataFromServer(true);
  }

  ///查询热门小说列表
  void getHotNovelsList(bool isRefresh) async {
    if (isRefresh) {
      multiStatus.value = MultiStatusType.statusLoading;
      pageHelper.resetPage();
    }
    HttpUtils.get(
      APIs.getNovelList,
      {
        "type": "hot_copy_novel",
        "page": pageHelper.page,
        "size": pageHelper.row,
        "need_detail": false,
        "category_id": null,
      },
      success: (data) {
        List listData = data["data"]["items"] ?? [];
        List<HotCreateNovelBean> novelsBeans = listData.map((e) => HotCreateNovelBean.fromJson(e)).toList();

        multiStatus.value = MultiStatusType.statusContent;
        if (isRefresh) {
          hotNovelsList.clear();
        }
        hotNovelsList.addAll(novelsBeans);
        if (hotNovelsList.isEmpty) {
          multiStatus.value = MultiStatusType.statusEmpty;
        }
        pageHelper.addPage();

        final hasMore = novelsBeans.length < pageHelper.row ? false : true;
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
  closeBannerEvent(){
    isShowBanner = false;
    update();
  }
}
