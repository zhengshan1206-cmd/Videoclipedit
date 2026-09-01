import 'package:bot_toast/bot_toast.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/modules/home/beans/home_broadcast_bean.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/hotCreate/beans/hot_create_category_bean.dart';

import '../../folkStory/beans/folk_story_bean.dart';

class FolkStoryApi extends APIs {
  static const String FolkStoryTheme = 'comConfig/getFolkStoryDetails';
  static const String FolkStoryModelStyle = 'comConfig/getModelConfig';
  static const String FolkStoryModelSpeaker = 'comConfig/getModuleSpeakerList';
}

class NovelCreateProvider extends BaseProvider {
  bool isFolkTales = false;
  String themeId = '';

  //数据加载错误或失败
  bool dataLoadingError = false;
  updatePageStatus(bool status) {
    dataLoadingError = status;
    notifyListeners();
  }

  updateIsfFolkTales(bool val) {
    isFolkTales = val;
    notifyListeners();
  }

  /// 是否来自推广
  bool isPromote = false;
  updateIsPromote(bool val) {
    isPromote = val;
    notifyListeners();
  }

  /// 当前页面竖直方向的滚动偏移量
  double currentOffset = 0;
  updateOffset(double offset) {
    currentOffset = offset;
    notifyListeners();
  }

  /// 分类列表
  List<HotCreateCategoryBean> categoryBeans = [];
  updateCategoryBeans(List<HotCreateCategoryBean> beans) {
    categoryBeans = beans;
    notifyListeners();
  }

  int selectedCategoryIdx = -1;
  updateSelectedCategoryIdx(int idx) {
    selectedCategoryIdx = idx;
    notifyListeners();
  }

  /// 搜索内容
  String searchContent = "";
  updateSearchContent(String content) {
    searchContent = content;
    notifyListeners();
  }

  /// 获取分类列表
  /// [folkTalesNovel] 是否是民间故事 1是 0否
  getCategoryConfig({
    bool folkTalesNovel = false,
  }) {
    HttpUtils.get(
      APIs.categoryConfig,
      {'type': themeId},
      success: (data) {
        byDebugPrint(data);
        final categories = data["data"]["category"];
        final List<HotCreateCategoryBean> beans =
            List<HotCreateCategoryBean>.from(
                categories.map((e) => HotCreateCategoryBean.fromJson(e)));
        updateCategoryBeans(beans);
        print('~~~~,民间故事分类数据,$data');
        if (beans.isNotEmpty) {
          updateSelectedCategoryIdx(0);
        }
      },
      fail: (code, msg) {
        updatePageStatus(true);
        BotToast.showText(text: msg);
      },
    );
  }

  /// 广播列表
  List<HomeBroadcastBean> broadcastBeans = [];
  updateBroadcastBeans(List<HomeBroadcastBean> beans) {
    broadcastBeans = beans;
    notifyListeners();
  }

  /// 加载广播
  loadBroadcast() {
    HttpUtils.get(
      APIs.homeBroadcast,
      {},
      success: (data) {
        dynamic dataFromServer = data["data"];
        if (dataFromServer != null) {
          Get.log("=========加载广播data=== ${dataFromServer} ");
          if (dataFromServer is List) {
            Get.log("=========加载广播dataList=== ${dataFromServer} ");
            List<HomeBroadcastBean> beans = dataFromServer
                .map((e) => HomeBroadcastBean.fromJson(e))
                .toList();
            updateBroadcastBeans(beans);
            notifyListeners();
          }
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  //更新民间故事主题
  FolkStoryThemeBean? themeBean;
  void updateFolkStoryTheme(FolkStoryThemeBean bean) {
    themeBean = bean;
    notifyListeners();
  }

  loadFolkStoryTheme({
    void Function()? onSuccess,
  }) {
    HttpUtils.get(
      FolkStoryApi.FolkStoryTheme,
      {'id': themeId},
      showLoading: false,
      success: (data) {
        final success = data["status"] == 200;
        if (!success) {
          updatePageStatus(true);
          return;
        }
        getCategoryConfig();
        print('~~~~,,,,___$data');
        final Map<String, dynamic> theme = data["data"] ?? {};
        FolkStoryThemeBean bean = FolkStoryThemeBean.fromJson(theme);
        updateFolkStoryTheme(bean);
        onSuccess?.call();
      },
      fail: (code, msg) {
        updatePageStatus(true);
      },
    );
  }
}
