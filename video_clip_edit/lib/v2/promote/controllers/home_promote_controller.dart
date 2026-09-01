import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/business/get_red_envelope_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';

///首页推广controller
class HomePromoteController extends GetxController
    with GetTickerProviderStateMixin {
  UserController get userController => Get.find<UserController>();

  bool isLoading = true;

  late TabController tabController;

  var currentIndex = 0.obs;

  ///banner数据
  var bannerList = <SubFunction>[];

  ///tabbar分类数据
  var categoryList = <SubFunction>[];

  ///分类的banner
  var bannerList2 = <SubFunction>[];

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    getBanners();
    getCategoryList();
    // 检查是否需要显示推广页引导弹窗
    checkShowPromotePageGuide();
  }

  ///检查并显示推广页引导弹窗（
  void checkShowPromotePageGuide() {
    if (userController.isShowPromotePageGuide) {
      ByNavigatorUtil.reportDataPoint(
        pageTag: "promotion_page_unlock_effect",
        operateType: "view",
        funcDetailTag: "0",
        funcDetailImg: "",
      );
      // 延迟显示弹窗，确保页面已加载完成
      Future.delayed(Duration.zero, () {
        final context = Get.context;
        if (context != null) {
          showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.85),
            builder: (context) => PromotePageEffectDialog(
              onClose: () {
                ByNavigatorUtil.reportDataPoint(
                  pageTag: "promotion_page_unlock_effect_close_btn",
                  operateType: "click",
                  funcDetailTag: "0",
                  funcDetailImg: "",
                );
                // 弹窗关闭时触发扫光效果事件
                eventBus.fire(const TriggerShimmerEvent());
              },
              closeCallback: () {
                // 弹窗关闭时触发扫光效果事件
                eventBus.fire(const TriggerShimmerEvent());
              },
            ),
          ).then((_) {
            // 弹窗关闭后重置标志
            userController.isShowPromotePageGuide = false;
          });
        }
      });
    }
  }

  ///获取推广banner图
  void getBanners() async {
    HttpUtils.get(
      APIs.homeBanner,
      {
        "postion": 16,
      },
      showMsgWhenFailed: false,
      success: (data) {
        final List dataList = data["data"]["item"] ?? [];
        List<SubFunction> beans =
            dataList.map((e) => SubFunction.fromJson(e)).toList();
        bannerList.assignAll(beans);
        update();
      },
      fail: (code, msg) {},
    );
  }

  ///获取tabBar分类数据
  void getCategoryList() async {
    HttpUtils.get(
      APIs.getPromotionMenu,
      {},
      showMsgWhenFailed: false,
      success: (data) {
        byDebugPrint('获取的数据===> $data');
        Get.log("获取的数据===> $data");

        final List dataList = data["data"] ?? [];
        List<SubFunction> beans =
            dataList.map((e) => SubFunction.fromPromotionJson(e)).toList();
        categoryList.assignAll(beans);
        _initTabController();
        isLoading = false;
        update();
      },
      fail: (code, msg) {},
    );
  }

  ///初始化tabController
  void _initTabController() {
    // 先释放旧的TabController
    _disposeTabController();

    tabController = TabController(length: categoryList.length, vsync: this);
    // tabController.addListener(_tabListener);
    tabController.animation?.addListener(_handleAnimationUpdate);
  }

  ///释放tabController
  void _disposeTabController() {
    try {
      // tabController.removeListener(_tabListener);
      tabController.animation?.removeListener(_handleAnimationUpdate);
      tabController.dispose();
    } catch (e) {
      // 如果tabController还没有初始化，忽略错误
      Get.log("TabController dispose error: $e");
    }
  }

  ///监听tabController滑动动画
  void _handleAnimationUpdate() {
    final animationValue = tabController.animation?.value ?? 0;
    // 根据动画值实时计算当前页（四舍五入）
    final newIndex = animationValue.round();
    if (newIndex != currentIndex.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        currentIndex.value = newIndex;

        ByNavigatorUtil.reportDataPoint(
          pageTag: "promotion_page_tab",
          operateType: "click",
          funcDetailTag: categoryList[newIndex].id.toString(),
          funcDetailImg: "",
        );
      });
    }
  }

  void _tabListener() {
    currentIndex.value = tabController!.index;
    // if (!tabController.indexIsChanging) {
    //   final index = _tabController.index;
    //   if (!_hasLoaded[index]) {
    //     _loadDataForTab(index);
    //     _hasLoaded[index] = true;
    //   }
    // }
  }

  @override
  void onClose() {
    super.onClose();
    _disposeTabController();
  }
}
