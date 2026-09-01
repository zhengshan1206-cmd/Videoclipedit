import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/modules/home/beans/home_broadcast_bean.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class ShortPlayCreateProvider extends BaseProvider {
  /// 当前页面竖直方向的滚动偏移量
  double currentOffset = 0;

  /// 广播列表
  List<HomeBroadcastBean> broadcastBeans = [];

  ///平台
  int platform = 0;

  ///搜索内容
  String searchContent = "";

  ///更新广播列表
  updateBroadcastBeans(List<HomeBroadcastBean> beans) {
    broadcastBeans = beans;
    notifyListeners();
  }

  updateOffset(double offset) {
    currentOffset = offset;
    notifyListeners();
  }

  ///更新平台和搜索内容
  updatePlatformAndSearchContent(int platform, String searchContent) {
    this.platform = platform;
    this.searchContent = searchContent;
    notifyListeners();
  }

  /// 加载广播
  loadBroadcast() {
    HttpUtils.get(
      APIs.homeBroadcast,
      {},
      success: (data) {
        final List bannerData = data["data"] is Map ? [] : data["data"] ?? [];
        List<HomeBroadcastBean> beans = bannerData
            .map((e) => HomeBroadcastBean.fromJson(e))
            .toList();
        updateBroadcastBeans(beans);
        notifyListeners();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 短剧列表
  List<CloudVideoListBean> shortPlayBeans = [];
  updateShortPlayBeansBeans(List<CloudVideoListBean> beans) {
    shortPlayBeans = beans;
    notifyListeners();
  }

  int page = 1;
  int size = 10;

  /// 加载云端视频
  /// [type] 1普通素材 2短剧 3漫剧
  /// [platform] 平台
  /// [searchContent] 搜索内容
  loadCloudVideos({
    String type = "2",
    bool isRefresh = false,
    bool showLoading = true,
    void Function(bool hasMore)? onSuccess,
    void Function()? onFail,
  }) {
    if (isRefresh) {
      page = 1;
    }
    HttpUtils.get(
      APIs.cloudVideosList,
      {
        "type": type,
        "page": page.toString(),
        "pageSize": size.toString(),
        "platform": platform,
        "title": searchContent,
      },
      showLoading: showLoading,
      success: (data) {
        byDebugPrint(data["data"], tag: "云端素材：");
        List listData = data["data"]["data"] ?? [];
        List<CloudVideoListBean> beans = listData
            .map((e) => CloudVideoListBean.fromJson(e))
            .toList();

        // 关键：isRefresh 且返回空，直接清空并return
        if (isRefresh && beans.isEmpty) {
          updateShortPlayBeansBeans([]);
          onSuccess?.call(false);
          return;
        }

        if (isRefresh) {
          shortPlayBeans.clear();
        }
        final List<CloudVideoListBean> results = List.from(shortPlayBeans);

        page = results.addElementsByRemovingLast(
          beans,
          currentPage: page,
          pageSize: size,
        );

        updateShortPlayBeansBeans(results);
        onSuccess?.call(beans.isNotEmpty && beans.length == size);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        onFail?.call();
      },
    );
  }
}
