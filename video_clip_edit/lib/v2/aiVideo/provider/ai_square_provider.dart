import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/purchase/widgets/module_pay_dailog.dart';
import 'package:video_clip_edit/modules/tool_box/beans/super_config_bean.dart';
import 'package:video_clip_edit/providers/ios_purchase_provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/v2/aiSquare/beans/ai_home_scroll_list_config_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/beans/ai_tweets_square_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_cases_list_view.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_cases_tweets_list_view.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_song_list_view.dart';
import 'package:video_clip_edit/v2/aiVideo/models/notice_model.dart';
import 'package:video_clip_edit/v2/business/ios_purchase_half_dialog.dart';
import 'package:video_clip_edit/v2/business/purchase_half_dialog.dart';
import 'package:video_clip_edit/v2/toolBox/beans/new_tool_box_category_bean.dart';
import '../../../utils/consts/const.dart';
import '../../../widgets/toast_util.dart';
import '../../aiSquare/song/beans/ai_song_task_detail_bean.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/beans/ai_squre_tab_bean.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_style_case_bean.dart';

import '../models/ai_music_banner_model.dart';
import '../models/ai_presets_model.dart';
import '../models/ai_tips_model.dart';
import '../models/ai_video_banner_model.dart';
import '../models/ai_video_square_model.dart';
import '../widgets/ai_cases_videos_list_view.dart';

class AiSquareProvider extends BaseProvider {
  List<SubFunction>? subFunctionBeans;

  double pinnedHeaderHeight = 0;
  changepPinnedHeaderHeight(double height) {
    pinnedHeaderHeight = height;
    notifyListeners();
  }

  Map<int, Widget> casesViews = {
    1: const AiCasesListView(),
    3: const AiCasesTweetsListView(),
    4: const AiCasesVideosListView(),
    5: const AiSongListView(),
  };
  bool showCashTutor = true;
  updateShowCashTutor(bool show) {
    showCashTutor = show;
    notifyListeners();
  }

  SuperConfigBean? configBean;
  updateConfigBean(SuperConfigBean bean) {
    configBean = bean;
    notifyListeners();
  }

  loadCashTutor() {
    HttpUtils.get(
      APIs.aiCashTutor,
      {},
      showLoading: false,
      success: (data) {
        final bean = SuperConfigBean.fromJson(data["data"]);
        updateConfigBean(bean);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  getHomeScrollListConfig() {
    HttpUtils.get(
      APIs.getHomeScrollListConfig,
      {},
      success: (data) {
        // log("首页banner接口数据===> $data");
        log("首页banner接口数据===> $data");
        List<AiHomeScrollListConfigBean> beans =
            List<AiHomeScrollListConfigBean>.from(data["data"]
                .map((e) => AiHomeScrollListConfigBean.fromJson(e)));
        log("首页banner接口数据===> ${beans.first.toJson()}");
        updateHomeScrollListConfigBeans(beans);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///首页banner基本配置信息
  List<AiHomeScrollListConfigBean> homeScrollListConfigBeans = [];
  updateHomeScrollListConfigBeans(List<AiHomeScrollListConfigBean> beans) {
    homeScrollListConfigBeans = beans;
    notifyListeners();
  }

  /// 获取金刚卫功能列表
  loadSubFunctions() {
    final String cateData =
        ByStorageUtils.getString(Consts.HOME_SHOW_CASE_LIST) ?? '';
    if (cateData.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final data = jsonDecode(cateData);
        _handleShowCaseData(data); // 此时构建已完成，可安全更新状态
      });
    }
    HttpUtils.get(
      APIs.showcaseList,
      {},
      success: (data) {
        log("金刚卫数据===> $data");
        ByStorageUtils.saveString(Consts.HOME_SHOW_CASE_LIST, jsonEncode(data));
        _handleShowCaseData(data);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  void _handleShowCaseData(dynamic data) {
    final List funsData = data["data"]["item"] ?? [];
    List<SubFunction> functionBeans =
        funsData.map((e) => SubFunction.fromJson(e)).toList();
    subFunctionBeans = functionBeans;
    notifyListeners();
  }

  /// 获取推小果URL
  NoticeModel noticeModel = NoticeModel();

  ///是否显示notice
  bool showNotice = true;

  ///运营配置的banner数据
  List<SubFunction> menuItemBeans = [];

  ///是否展示关闭banner按钮
  bool isShowBanner = true;

  @override
  loadTuixiaoguoUrl({
    void Function(String)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.tuixiaoguoUrl,
      {
        "need_detail": 1,
        "page": 1,
        "pageSize": 10,
      },
      showLoading: true,
      success: (json) {
        var data = json["data"];
        if (data != null && data["jump_url"] != null) {
          final tuixiaoguoUrl = data["jump_url"];
          onSuccess?.call(tuixiaoguoUrl);
        }
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  String finishedPeopleNum = "";

  updateFinishedNum(num number) {
    if (number < 10000) {
      finishedPeopleNum = "已有超$number人通过我们AI完成变现";
    } else {
      finishedPeopleNum = finishedPeopleNum =
          "已有超${(number / 10000).toStringAsFixed(1)}万人通过我们AI完成变现";
    }
    notifyListeners();
  }

  List<AiSqureTabBean> tabBeans = [];
  AiSqureTabBean? aiSqureTabBean;

  updateTabBeans(List<AiSqureTabBean> beans) {
    tabBeans = beans;
    changeSelectedAiCaseTypeIndex(selectedAiCaseTypeIndex);
    notifyListeners();
  }

  /// 当前选择的ai案例类型
  int selectedAiCaseTypeIndex = 0;

  List<Widget> tabPages = [
    const AiCasesListView(),
  ];
  updateTabPages(List<Widget> pages) {
    tabPages = pages;
    notifyListeners();
  }

  changeSelectedAiCaseTypeIndex(int index) {
    selectedAiCaseTypeIndex = index;
    aiSqureTabBean = tabBeans[selectedAiCaseTypeIndex];
    notifyListeners();
  }

  loadTabsConfig({
    void Function()? onSuccess,
  }) {
    HttpUtils.get(
      APIs.getTabsConfig,
      {},
      success: (data) {
        byDebugPrint(data);
        final List items = data["data"] ?? [];
        List<AiSqureTabBean> beans = List<AiSqureTabBean>.from(
            items.map((e) => AiSqureTabBean.fromJson(e)));
        updateTabBeans(beans);

        List<Widget> pages = beans.map((bean) {
          final id = bean.id;
          switch (id) {
            case 1:
              return const AiCasesListView();
            case 3:
              return const AiCasesTweetsListView();
            case 4:
              return const AiCasesVideosListView();
            case 5:
              return const AiSongListView();
            // case 6:
            //   return const AiCasesTweetsListView();
            default:
          }
          return Container();
        }).toList();

        updateTabPages(pages);
        onSuccess?.call();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  List<AiDrawStyleCaseBean> aiSquareBeans = [];

  updateAiSquareBeans(List<AiDrawStyleCaseBean> beans) {
    aiSquareBeans = beans;
    notifyListeners();
  }

  List<AiSongTaskDetailBean> squareList = [];

  int page = 1;
  int size = 10;

  ///智能绘图数据集合
  List<AiTipsModel> aiTipsModelList = [];

  ///智能回答数据集合
  List<AiPresetsModel> aiPresetsModelList = [];

  ///ai video 数据集合
  List<AiVideoBannerModel> aiVideoBannerModelList = [];

  ///ai music 数据集合
  List<AiMusicBannerModel> aiMusicBannerModelList = [];

  loadAiSquareData({
    bool reset = false,
    required void Function(bool hasMore) onSuccess,
    required void Function() onFailed,
  }) {
    if (reset) {
      page = 1;
      aiSquareBeans.clear();
    }
    HttpUtils.get(
      APIs.aiSquare,
      {
        "page": page,
        "size": size,
      },
      success: (data) {
        final success = data["status"] == 200;
        if (!success) {
          onFailed.call();
          return;
        }
        final List items = data["data"]["items"] ?? [];
        final caseBeans = List<AiDrawStyleCaseBean>.from(items.map(
          (ele) => AiDrawStyleCaseBean.fromJson(ele),
        ));
        final allBeans = List<AiDrawStyleCaseBean>.from(aiSquareBeans);
        page = allBeans.addElementsByRemovingLast(
          caseBeans,
          currentPage: page,
          pageSize: size,
        );
        onSuccess.call(caseBeans.length % size == 0);
        updateAiSquareBeans(allBeans);
      },
      fail: (code, msg) {
        onFailed.call();
        BotToast.showText(text: msg);
      },
    );
  }

  updateSquareList(List<AiSongTaskDetailBean> beans) {
    squareList = beans;
    notifyListeners();
  }

  int squareListPage = 1;
  int squareListSize = 10;
  getSquareList({
    bool reset = false,
    required void Function(bool hasMore) onSuccess,
    required void Function() onFailed,
  }) {
    if (reset) {
      squareListPage = 1;
      squareList.clear();
    }
    HttpUtils.get(
      APIs.getSquareList,
      {
        "page": squareListPage,
        "size": squareListSize,
      },
      success: (data) {
        final success = data["status"] == 200;
        if (!success) {
          onFailed.call();
          return;
        }
        final List items = data["data"]["data"] ?? [];
        final caseBeans = List<AiSongTaskDetailBean>.from(items.map(
          (ele) => AiSongTaskDetailBean.fromJson(ele),
        ));
        final allBeans = List<AiSongTaskDetailBean>.from(squareList);

        squareListPage = allBeans.addElementsByRemovingLast(
          caseBeans,
          currentPage: squareListPage,
          pageSize: squareListSize,
        );
        onSuccess.call(caseBeans.length % size == 0);
        updateSquareList(allBeans);
      },
      fail: (code, msg) {
        onFailed.call();
        BotToast.showText(text: msg);
      },
    );
  }

  List<AiTweetsSquareBean> tweetsBeans = [];
  updateTweetsBeans(List<AiTweetsSquareBean> beans) {
    tweetsBeans = beans;
    notifyListeners();
  }

  int tweetsPage = 1;
  int tweetsPageSize = 10;

  /// [jumptype] 6:推文 7:智能混剪
  loadTweetsSquareData({
    bool reset = false,
    required void Function(bool hasMore) onSuccess,
    required void Function() onFailed,
    required String jumptype,
  }) {
    if (reset) {
      tweetsPage = 1;
      tweetsBeans.clear();
    }
    HttpUtils.get(
      APIs.videoSquareList,
      {
        "page": tweetsPage,
        "size": tweetsPageSize,
        "jumptype": jumptype,
      },
      success: (data) {
        final success = data["status"] == 200;
        if (!success) {
          onFailed.call();
          return;
        }
        final List items = data["data"]["items"] ?? [];
        final caseBeans = List<AiTweetsSquareBean>.from(items.map(
          (ele) => AiTweetsSquareBean.fromJson(ele),
        ));
        final allBeans = List<AiTweetsSquareBean>.from(tweetsBeans);

        tweetsPage = allBeans.addElementsByRemovingLast(
          caseBeans,
          currentPage: tweetsPage,
          pageSize: tweetsPageSize,
        );
        onSuccess.call(caseBeans.length % size == 0);
        updateTweetsBeans(allBeans);
      },
      fail: (code, msg) {
        onFailed.call();
        BotToast.showText(text: msg);
      },
    );
  }

  List<AiVideoSquareModel> videosBeans = [];
  updateVideosBeans(List<AiVideoSquareModel> beans) {
    videosBeans = beans;
    notifyListeners();
  }

  int videosPage = 1;
  int videosPageSize = 10;
  loadVideosSquareData({
    bool reset = false,
    AiVideoGenerationType? type,
    required void Function(bool hasMore) onSuccess,
    required void Function() onFailed,
  }) {
    if (reset) {
      videosPage = 1;
      videosBeans.clear();
    }
    loadVideos(
      type: type,
      page: videosPage,
      pageSize: videosPageSize,
      onSuccess: (data) {
        final allBeans = List<AiVideoSquareModel>.from(videosBeans);
        videosPage = allBeans.addElementsByRemovingLast(
          data,
          currentPage: videosPage,
          pageSize: videosPageSize,
        );
        onSuccess.call(data.length % size == 0);
        updateVideosBeans(allBeans);
      },
      onFailed: onFailed,
    );
  }

  void loadVideos({
    AiVideoGenerationType? type,
    int page = 1,
    int pageSize = 10,
    required void Function(List<AiVideoSquareModel> data) onSuccess,
    required void Function() onFailed,
  }) {
    HttpUtils.get(
      APIs.aiVideoCategoryDetail,
      {
        "page": page,
        "pageSize": pageSize,
        if (type != null) "category_id": type.code,
      },
      success: (data) {
        final success = data["status"] == 200;
        if (!success) {
          onFailed.call();
          return;
        }
        final List items = data["data"]["data"] ?? [];
        final caseBeans = List<AiVideoSquareModel>.from(items.map(
          (ele) => AiVideoSquareModel.fromJson(ele),
        ));
        onSuccess.call(caseBeans);
      },
      fail: (code, msg) {
        onFailed.call();
        BotToast.showText(text: msg);
      },
    );
  }

  /// 当前选中的标签索引
  int selectedIndex = -1;
  updateSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  List<NewToolBoxCategoryBean> categoryBeans = [];
  updateCategoryBeans(List<NewToolBoxCategoryBean> beans) {
    categoryBeans = beans;
    notifyListeners();
  }

  String caseHeaderTitle = "";
  updateCaseHeaderTitle(String title) {
    caseHeaderTitle = title;
    notifyListeners();
  }

  /// [postion] 数据所在的页面位置
  /// 1=>'首页'
  /// 2=>'首页AI助理'
  /// 3=>'工具箱',
  loadCategory() {
    final String cateData =
        ByStorageUtils.getString(Consts.CRUMBS_CATEGORY_LIST) ?? '';
    if (cateData.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final data = jsonDecode(cateData);
        _handleCategoryData(data); // 此时构建已完成，可安全更新状态
      });
    }
    HttpUtils.get(
      APIs.crumbsCategoryList,
      {"postion": 1},
      success: (data) {
        byDebugPrint(data);
        ByStorageUtils.saveString(
            Consts.CRUMBS_CATEGORY_LIST, jsonEncode(data));
        _handleCategoryData(data);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  void _handleCategoryData(dynamic data) {
    final list = data['data']["list"] ?? [];
    final title = data["data"]["title"] ?? "";
    updateCaseHeaderTitle(title);
    final beans = List<NewToolBoxCategoryBean>.from(
        list.map((e) => NewToolBoxCategoryBean.fromJson(e)));
    updateCategoryBeans(beans);

    if (beans.isNotEmpty) {
      updateSelectedIndex(0);
    }
  }

  List<SubFunction> bannerBeans = [];
  updateBannerBeans(List<SubFunction> beans) {
    bannerBeans = beans;
    notifyListeners();
  }

  loadBannerData() {
    final String cateData =
        ByStorageUtils.getString(Consts.HOME_TOP_BANNER) ?? '';
    if (cateData.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final data = jsonDecode(cateData);
        _handleBannerData(data); // 此时构建已完成，可安全更新状态
      });
    }
    HttpUtils.get(
      APIs.homeBanner,
      {"postion": 15},
      success: (data) {
        ByStorageUtils.saveString(Consts.HOME_TOP_BANNER, jsonEncode(data));
        _handleBannerData(data);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  void _handleBannerData(dynamic data) {
    final List bannerData = data["data"]["item"] ?? [];
    List<SubFunction> beans =
        bannerData.map((e) => SubFunction.fromJson(e)).toList();
    updateBannerBeans(beans);
  }

  /// 当前页面竖直方向的滚动偏移量
  double currentOffset = 0;
  updateOffset(double offset) {
    currentOffset = offset;
    notifyListeners();
  }

  ///获取首页智能绘图接口数据
  getAiTipsData() {
    HttpUtils.get(
      APIs.aiTips,
      {},
      success: (data) {
        final List aiTipData = data["data"]["tips"] ?? [];
        List<AiTipsModel> beans =
            aiTipData.map((e) => AiTipsModel.fromJson(json: e)).toList();
        updateAiTipsData(beans);
        log("获取首页智能绘图接口数据======> ${data["data"]["tips"]}");
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///更新首页智能绘图接口数据
  updateAiTipsData(List<AiTipsModel> beans) {
    aiTipsModelList = beans;
    notifyListeners();
  }

  ///获取智能回答接口数据
  getAiPresetsData() {
    HttpUtils.get(
      APIs.aiPresets,
      {},
      success: (data) {
        final List aiPresetsData = data["data"]["chats"] ?? [];
        List<AiPresetsModel> beans =
            aiPresetsData.map((e) => AiPresetsModel.fromJson(json: e)).toList();
        updateAiPresetsData(beans);
        log("获取首页智能回答接口数据======> $data");
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///更新首页智能绘图接口数据
  updateAiPresetsData(List<AiPresetsModel> beans) {
    aiPresetsModelList = beans;
    notifyListeners();
  }

  ///获取ai动态视频接口数据
  getAiVideoData() {
    HttpUtils.get(
      APIs.aiVideoBanner,
      {},
      success: (data) {
        final List aiPresetsData = data["data"] ?? [];
        List<AiVideoBannerModel> beans = aiPresetsData
            .map((e) => AiVideoBannerModel.fromJson(json: e))
            .toList();
        updateAiVideoData(beans);
        log("获取首页ai动态视频接口数据======> $data");
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///更新首页智能绘图接口数据
  updateAiVideoData(List<AiVideoBannerModel> beans) {
    aiVideoBannerModelList = beans;
    notifyListeners();
  }

  ///获取ai音乐接口数据
  getAiMusicData() {
    showNotice = SpUtil.getBool(
          "close_notice",
        ) ??
        true;
    HttpUtils.get(
      APIs.aiMusic,
      {},
      success: (data) {
        final List aiPresetsData = data["data"] ?? [];
        List<AiMusicBannerModel> beans = aiPresetsData
            .map((e) => AiMusicBannerModel.fromJson(json: e))
            .toList();
        updateAiMusicData(beans);
        log("获取首页ai音乐接口数据======> $data");
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///更新首页ai music 接口数据
  updateAiMusicData(List<AiMusicBannerModel> beans) {
    aiMusicBannerModelList = beans;
    notifyListeners();
  }

  ///公告接口
  loadNoticeData() {
    HttpUtils.get(
      APIs.noticeData,
      {'position': 2},
      success: (data) {
        final List dataList = data["data"] ?? [];
        if (dataList.isNotEmpty) {
          noticeModel = NoticeModel.fromJson(json: dataList.first);
        }
        log("获取首页公告接口数据======> $noticeModel");
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///分类列表
  List<SubFunction> modulesPayList = [];

  ///获取所有分类模块弹窗列表
  loadHomeBanner() {
    HttpUtils.get(
      APIs.homeBanner,
      {"postion": 19},
      success: (data) {
        final List bannerData = data["data"]["item"] ?? [];
        byDebugPrint(bannerData, tag: "获取所有分类模块弹窗列表:");
        List<SubFunction> beans =
            bannerData.map((e) => SubFunction.fromJson(e)).toList();
        modulesPayList = beans;
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  //匹配支付弹窗
  showModelPayDialog(
    context,
    String mark, {
    String eventFunction = "",
    String pagePath = "",
    String prePagePath = "",
  }) {
    final userInfo = Get.find<UserController>().user.value;
    if (userInfo?.isNewAttributionUser == 1) {
      ///跳转落地页
      final launchProvider = Get.context!.read<LaunchProvider>();
      launchProvider.gotoPay(Get.context!);
      return;
    }
    SubFunction? findItemOrReturnNull(
        List<SubFunction> items, String searchString) {
      try {
        return items.firstWhere((item) => item.jumpUrl == searchString);
      } catch (e) {
        return null; // 表示未找到
      }
    }

    SubFunction? result = findItemOrReturnNull(modulesPayList, mark);
    if (mark == "short_play_create_djcz") {
      mark = "short_play_create_detail";
    }
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return ModulePayDailog(
    //       mark: mark,
    //       markUrl: result != null
    //           ? result.imgUrl
    //           : "assets/purchase/dailog_bonus_bg_new_1.png",
    //     );
    //   },
    // );
    if (Get.context != null) {
      Get.context!.read<LaunchProvider>().showPayHalfDialog(context, mark,
          eventFunction: eventFunction,
          pagePath: pagePath,
          prePagePath: prePagePath);
    }
  }

  ///获取运营配置的banner数据
  loadMenuData() {
    HttpUtils.get(
      APIs.homeBanner,
      {"postion": 1},
      success: (data) {
        final List bannerData = data["data"]["item"] ?? [];
        byDebugPrint(bannerData, tag: "首页页面Banner:---");
        List<SubFunction> beans =
            bannerData.map((e) => SubFunction.fromJson(e)).toList();
        menuItemBeans = beans;
        notifyListeners();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///关闭banner
  closeBannerEvent() {
    isShowBanner = false;
    notifyListeners();
  }
}
