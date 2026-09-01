import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/controllers/base_controller.dart';
import 'package:video_clip_edit/core/util/logger.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/bottom_sheet/ai_create_bgm_setting_view.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_cat_bean.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';

import '../../../widgets/toast_util.dart';
import 'create_folk_story_controller.dart';

class AiCreateBgmSettingController extends BaseController with GetTickerProviderStateMixin {

  late TabController tabController;

  final ByAudioPlayer audioPlayer = ByAudioPlayer.sharedInstance;

  ///选中的tab下标
  final tabIndex = 0.obs;

  ///平台推荐-标签类型
  var categoryType = Rx<AiCartoonBgmCatBean?>(null);

  ///平台推荐类型
  RxList<AiCartoonBgmCatBean> categoryList = RxList<AiCartoonBgmCatBean>();

  var multiStatus = MultiStatusType.statusLoading.obs;

  /// 背景音乐列表
  var bgmList = <AiCartoonBgmBean>[];

  final selectBgmBean = Rx<AiCartoonBgmBean?>(null);

  var playingId = -1;

  ///播放状态
  final playingStatus = Rx<ByAudioPlayerStatus>(ByAudioPlayerStatus.stop);

  ///是否加载中
  bool get isLoading => playingStatus.value == ByAudioPlayerStatus.loading;
  ///是否播放中
  bool get isPlaying => playingStatus.value == ByAudioPlayerStatus.playing || playingStatus.value == ByAudioPlayerStatus.resume;

  late StreamSubscription<ByAudioPlayerStatus> _subscription;

  //当前民间故事分类数据
  final CreateFolkStoryController folkBean  = Get.find<CreateFolkStoryController>();

  ///预留下拉刷新更多功能
  void onRefresh() {
    _getDataFromServer(true);
  }

  ///预留上拉加载更多功能
  void onLoadMore() {
    _getDataFromServer(false);
  }

  void _getDataFromServer(bool isRefresh) {
    getBgmListWithCategory(isRefresh);
  }

  @override
  void handRegister() {
    _initTabController();

    _subscription = audioPlayer.statusFutuer().asBroadcastStream().listen((audioPlayStatus) {
      playingStatus.value = audioPlayStatus;
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      BYDebugPrint('onError ... $error');
    });

  }

  @override
  void fetchData() {
    // getPlatformRecommendCategoryList();
    _getDataFromServer(true);
  }

  ///获取平台推荐类型列表
  void getPlatformRecommendCategoryList() async {
    HttpUtils.get(
      APIs.bgmCategoryList,
      {},
      success: (data) {
        final List bgmCateData = data["data"]["items"] ?? [];
        final List<AiCartoonBgmCatBean> beans = bgmCateData.map((e) => AiCartoonBgmCatBean.fromJson(e)).toList();
        categoryList.assignAll(beans);

        if (beans.isNotEmpty) {
          /// 默认选中第一个分类
          queryChanged(beans.first);
        }
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///根据平台推荐类型查询背景音乐
  void getBgmListWithCategory(bool isRefresh) async {
    if (isRefresh) {
      multiStatus.value = MultiStatusType.statusLoading;
      pageHelper.resetPage();
    }
    HttpUtils.get(
      APIs.bgmListNew,
      // {
      //   "page": pageHelper.page,
      //   "pageSize": 200,
      //   "cate": categoryType.value?.id,
      //   "useScenes": 4,
      // },
      {
        "page": pageHelper.page,
        "pageSize": 200,
        "type": folkBean.themeBean?.bgmID,
      },
      success: (data) {
        List listData = data["data"]["items"] ?? [];
        List<AiCartoonBgmBean> dataList = listData.map((e) => AiCartoonBgmBean.fromJson(e)).toList();

        multiStatus.value = MultiStatusType.statusContent;
        if (isRefresh) {
          bgmList.clear();
        }
        bgmList.addAll(dataList);
        if (bgmList.isEmpty) {
          multiStatus.value = MultiStatusType.statusEmpty;
        }
        pageHelper.addPage();

        final hasMore = dataList.length < pageHelper.row ? false : true;
        refreshSuccess(isRefresh, hasMore);

        update();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
        refreshFailed(isRefresh);
      },
    );
  }

  ///切换查询条件
  void queryChanged(AiCartoonBgmCatBean categoryBean) {
    audioPlayer.stop();
    categoryType.value = categoryBean;
    _getDataFromServer(true);
  }

  ///初始化tabController
  void _initTabController() {
    tabController = TabController(length: AICreateBgmType.values.length, vsync: this);
    tabController.animation?.addListener(_handleAnimationUpdate);
  }

  ///释放tabController
  void _disposeTabController() {
    tabController.animation?.removeListener(_handleAnimationUpdate);
    tabController.dispose();
  }

  ///监听tabController滑动动画
  void _handleAnimationUpdate() {
    final animationValue = tabController.animation?.value ?? 0;
    // 根据动画值实时计算当前页（四舍五入）
    final newIndex = animationValue.round();
    if (newIndex != tabIndex.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (audioPlayer.isPlaying) {
          audioPlayer.stop();
        }
        tabIndex.value = newIndex;
      });
    }
  }

  @override
  void onClose() {
    _disposeTabController();
    audioPlayer.stop();
    _subscription.cancel();
    super.onClose();
  }
}
