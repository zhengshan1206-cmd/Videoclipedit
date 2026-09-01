import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/modules/home/beans/home_banner_bean.dart';
import 'package:video_clip_edit/modules/home/beans/home_broadcast_bean.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/creator_bean.dart';
import 'package:video_clip_edit/modules/home/widgets/hot_auth_view.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class HomePageProvider extends BaseProvider {
  List<SubFunction>? subFunctionBeans;
  List<HotAuthBean> hotAuthBeans = [];
  List<HomeBroadcastBean>? broadcastBeans;
  List<HomeBannerBean>? bannerBeans;
  String tuixiaoguoUrl = "";

  /// 获取自功能列表
  loadSubFunctions() {
    HttpUtils.get(
      APIs.showcaseList,
      {},
      success: (data) {
        final List funsData = data["data"]["item"] ?? [];
        List<SubFunction> functionBeans =
            funsData.map((e) => SubFunction.fromJson(e)).toList();
        subFunctionBeans = functionBeans;
        notifyListeners();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 加载云端视频
  loadCloudVideos(
      {required void Function(List<CloudVideoListBean>)? onSuccess}) {
    HttpUtils.get(
      APIs.cloudVideosList,
      {
        "pageSize": 100,
        "page": 1,
        "type": 2,
      },
      showLoading: true,
      success: (data) {
        List listData = data["data"]["data"] ?? [];
        List<CloudVideoListBean> beans =
            listData.map((e) => CloudVideoListBean.fromJson(e)).toList();
        onSuccess?.call(beans);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  int page = 1;
  int needDetail = 1;
  int pageSize = 10;

  resetPages() {
    page = 1;
    hotAuthBeans.clear();
  }

  /// 加载推小果列表
  loadHotlist() {
    HttpUtils.get(
      APIs.homeHotlist,
      {
        "need_detail": needDetail,
        "page": page,
        "pageSize": pageSize,
      },
      success: (data) {
        final List funsData = data["data"]["data"] ?? [];
        List<HotAuthBean> beans =
            funsData.map((e) => HotAuthBean.fromJson(e)).toList();
        page = hotAuthBeans.addElementsByRemovingLast(
          beans,
          pageSize: pageSize,
          currentPage: page,
        );
        notifyListeners();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 加载广播
  loadBroadcast() {
    HttpUtils.get(
      APIs.homeBroadcast,
      {},
      success: (data) {
        final List bannerData = data["data"] ?? [];
        List<HomeBroadcastBean> beans =
            bannerData.map((e) => HomeBroadcastBean.fromJson(e)).toList();
        broadcastBeans = beans;
        notifyListeners();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 加载广播
  loadBanner() {
    var json = {
      "id": 26,
      "title": "视频混剪",
      "img_url":
          "http://gamecdn.beiyinapp.com/inchat/sys/SuperConfigs/2024-08-07/31f25f3a493d51024db515c41e4ab685.png",
      "jump_url": "videoMix",
      "jump_param": "",
      "type": 2,
      "des": "视频混剪"
    };
    bannerBeans = [HomeBannerBean.fromJson(json)];
    notifyListeners;

    // HttpUtils.get(
    //   APIs.homeBanner,
    //   {},
    //   success: (data) {
    //     final List bannerData = data["data"]["item"] ?? [];
    //     List<HomeBannerBean> beans =
    //         bannerData.map((e) => HomeBannerBean.fromJson(e)).toList();
    //     bannerBeans = beans;
    //     notifyListeners();
    //   },
    //   fail: (code, msg) {
    //     BotToast.showText(text: msg);
    //   },
    // );
  }

  /// 获取推小果URL
  @override
  loadTuixiaoguoUrl({void Function(String)? onSuccess}) {
    if (tuixiaoguoUrl.isNotEmpty) return;

    HttpUtils.get(
      APIs.tuixiaoguoUrl,
      {
        "need_detail": needDetail,
        "page": page,
        "pageSize": pageSize,
      },
      success: (json) {
        var data = json["data"];
        if (data != null && data["jump_url"] != null) {
          tuixiaoguoUrl = data["jump_url"];
          notifyListeners();
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 助手列表
  List<CreatorBean> assistantItemBeans = [];
  updateAssistantItemBeans(List<CreatorBean> beans) {
    assistantItemBeans = beans;
    notifyListeners();
  }

  loadCreators({Function? call}) {
    HttpUtils.get(
      APIs.creators,
      {},
      success: (data) {
        final List creators = data["data"] ?? [];
        List<CreatorBean> beans =
            creators.map((e) => CreatorBean.fromJson(e)).toList();
        updateAssistantItemBeans(beans);
        if (call != null) call();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
