import 'dart:convert';
import 'dart:math';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/ai/ai_video/ai_dynamic_video_controller.dart';
import 'package:video_clip_edit/modules/ai/ai_video/new_ai_video_controller.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/commn_alert_dailog.dart';
import 'package:video_clip_edit/modules/main/controllers/new_user_benefits_controller.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/consts/const.dart';
import 'package:video_clip_edit/modules/main/main_page.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/push/umeng_push.dart';
import 'package:video_clip_edit/v2/aiSquare/ai_square_page.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_ascribe_util.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/ai_dynamic_video_page.dart';
import 'package:video_clip_edit/v2/slicing/controller/one_click_slicing_controller.dart';
import 'package:video_clip_edit/v2/slicing/one_click_slicing_page.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/profile/views/home_mine_page.dart';
import 'package:video_clip_edit/v2/promote/views/home_promote_page.dart';
import 'package:video_clip_edit/modules/purchase/widgets/dailog_bonus_new.dart';
import 'package:video_clip_edit/v2/promote/controllers/home_promote_controller.dart';

import '../../../v2/integral/integral_vip_controller.dart';

class MainController extends GetxController {
  var _currentIndex = 0;

  get currentIndex => _currentIndex;

  List<Widget> tabBarPages = [];

  String getBase64RandomString(int length) {
    var random = Random.secure();
    var values = List.generate(length, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  String? uniqueKey;

  NewUserBenefitsController? _newUserBenefitsController;

  // 全局标记：是否正在请求权限，防止重复请求
  bool _isRequestingPermission = false;
  // 全局标记：是否已经请求过权限（本次会话）
  bool _hasRequestedPermissionInSession = false;

  @override
  void onInit() {
    super.onInit();
    uniqueKey = getBase64RandomString(20);
    Get.put(OneClickSlicingController());
    // 全局注册新的 Ai 视频控制器，确保所有页面都能正常使用
    if (!Get.isRegistered<NewAiVideoController>()) {
      Get.put(NewAiVideoController(), permanent: true);
    }
    Get.put(IntegralVipController(), permanent: true);

    tabBarPages.add(const AiSquarePage());
    tabBarPages.add(const OneClickSlicingPage());
    // tabBarPages.add(const PromoteHomePage());
    tabBarPages.add(const HomePromotePage());
    // tabBarPages.add(const NewToolBoxPage());
    // tabBarPages.add(const NewAiVideoPage());
    tabBarPages.add(AIDynamicVideoPage(fromHome: true, uniqueKey: uniqueKey));
    tabBarPages.add(const HomeMinePage());

    /// 检查是否显示VIP优惠弹窗
    // _checkShowVipDailog();
    _checkShowUpgrade();

    _appInit();

    // _pushCallback();

    update();
    _newUserBenefitsController = Get.put<NewUserBenefitsController>(
      NewUserBenefitsController(),
    );
  }

  //推送回调以及通知权限
  void pushCallback() {
    // //通知权限
    // NotificationPermission.getStatus();
    // 使用安全初始化方法，自动检查隐私政策
    NotificationPermission.safeInitialize();
  }

  /// 统一入口：安全地请求通知权限（带防重复机制）
  /// [delayMs] 延迟时间（毫秒），默认500ms，确保弹窗完全关闭
  /// [force] 是否强制请求（忽略已请求标记），默认false
  void requestNotificationPermissionSafely({
    int delayMs = 500,
    bool force = false,
  }) {
    // 如果已经请求过且不是强制请求，直接返回
    if (_hasRequestedPermissionInSession && !force) {
      Get.log('通知权限已在本次会话中请求过，跳过重复请求');
      return;
    }

    // 如果正在请求中，直接返回
    if (_isRequestingPermission) {
      Get.log('通知权限正在请求中，跳过重复请求');
      return;
    }

    // 延迟请求，确保弹窗完全关闭
    Future.delayed(Duration(milliseconds: delayMs), () {
      // 再次检查是否可以安全请求
      if (!canRequestNotificationPermissionOnHomePage()) {
        Get.log('当前环境不安全，无法请求通知权限');
        return;
      }

      // 标记正在请求
      _isRequestingPermission = true;

      // 请求权限
      pushCallback();

      // 标记已请求（延迟标记，等待权限请求完成）
      Future.delayed(const Duration(milliseconds: 1000), () {
        _hasRequestedPermissionInSession = true;
        _isRequestingPermission = false;
      });
    });
  }

  /// 检查是否可以在首页安全地请求通知权限
  /// 返回 true 表示可以请求，false 表示不能请求
  bool canRequestNotificationPermissionOnHomePage() {
    // 如果正在请求中，不允许重复请求
    if (_isRequestingPermission) {
      return false;
    }

    // 检查是否在首页（currentIndex == 0）
    if (_currentIndex != 0) {
      return false;
    }

    // 检查是否有 GetX 弹窗显示
    if (Get.isDialogOpen == true ||
        Get.isSnackbarOpen == true ||
        Get.isBottomSheetOpen == true) {
      return false;
    }

    // 检查新用户福利弹窗是否显示
    if (_newUserBenefitsController != null &&
        _newUserBenefitsController!.showType.value != 0) {
      return false;
    }

    // 检查当前路由是否是主页面
    if (Get.currentRoute != Routes.main) {
      return false;
    }

    // 检查 Flutter 原生弹窗是否显示（通过 Navigator 检查）
    if (Get.context != null) {
      try {
        // 检查当前路由是否是 DialogRoute（弹窗路由）
        // DialogRoute 是 Flutter 中 showDialog 创建的路由类型
        final route = ModalRoute.of(Get.context!);
        if (route != null && route is DialogRoute) {
          // 如果是 DialogRoute，说明有弹窗显示
          return false;
        }

        // 检查 Navigator 是否可以 pop（说明有路由覆盖）
        // 但需要排除主页面本身在路由栈中的情况
        final navigator = Navigator.of(Get.context!, rootNavigator: false);
        if (navigator.canPop()) {
          // 可以 pop，说明可能有弹窗或页面覆盖
          // 为了安全起见，不请求权限
          return false;
        }
      } catch (e) {
        // 如果检查出错，为了安全起见，不请求权限
        return false;
      }
    }

    return true;
  }

  /// 在首页安全地请求通知权限（如果条件满足）
  /// 已废弃：请使用 requestNotificationPermissionSafely() 替代
  @Deprecated('请使用 requestNotificationPermissionSafely() 替代')
  void requestNotificationPermissionIfSafe() {
    requestNotificationPermissionSafely();
  }

  void tabChanged(int index) {
    if (_currentIndex != index) {
      ///我的模块点击 做前置登录校验
      if (index == 4) {
        bool isUserController = Get.isRegistered<UserController>();
        if (isUserController) {
          if (Get.find<UserController>().user.value?.isFormal == 1) {
            Get.find<UserController>().checkNeedPhoneBind();
            Get.find<UserController>().reloadUserInfo();
          }
        } else {
          Get.put(UserController());
          Get.find<UserController>().checkNeedPhoneBind();
          Get.find<UserController>().reloadUserInfo();
        }
        ByNavigatorUtil.reportDataPoint(
          pageTag: "my_page",
          operateType: "view",
          funcDetailTag: "0",
          funcDetailImg: "",
        );

        ///我的模块点击 是会员则直接跳转
        // if (Get.find<UserController>().user.value?.isVip == 1) {
        //   _currentIndex = index;
        //   update();
        //   bool isIntegralVipController =
        //       Get.isRegistered<IntegralVipController>();
        //   if (!isIntegralVipController) {
        //     Get.put(IntegralVipController(), permanent: true);
        //   }
        //   return;
        // }

        ByNavigatorUtil.checkLogin(
          withOutGotoBind: true,
          context: Get.context!,
          needDirectLogin: true,
          nextStepEvent: () {
            ///check error fix some bug
            _currentIndex = index;
            update();
            bool isIntegralVipController =
                Get.isRegistered<IntegralVipController>();
            if (!isIntegralVipController) {
              Get.put(IntegralVipController(), permanent: true);
            }
          },
        );
      } else {
        ///check error fix some bug
        _currentIndex = index;
        update();
        if (index == 1) {
          ///check OneClickSlicingController state
          bool isOneClickSlicingController =
              Get.isRegistered<OneClickSlicingController>();
          if (!isOneClickSlicingController) {
            Get.put(OneClickSlicingController());
          }
          final integralVipController = IntegralVipController.getOrPut();
          integralVipController.init(requiredPoints: 0, type: "txt_knows");
        }
        if (index == 2) {
          ///check HomePromoteController state
          bool isHomePromoteController =
              Get.isRegistered<HomePromoteController>();
          if (!isHomePromoteController) {
            Get.log("================isHomePromoteController=============");
            Get.put(HomePromoteController());
          }
          Get.find<HomePromoteController>().getBanners();
          Get.find<HomePromoteController>().getCategoryList();
          // 检查是否需要显示推广页引导弹窗
          Get.find<HomePromoteController>().checkShowPromotePageGuide();
          ByNavigatorUtil.reportDataPoint(
            pageTag: "promotion_page",
            operateType: "view",
            funcDetailTag: "0",
            funcDetailImg: "",
          );
        }
        if (index == 3) {
          Get.find<AiDynamicVideoController>(tag: uniqueKey).loadAllHotVideos();
          Get.find<AiDynamicVideoController>(
            tag: uniqueKey,
          ).initIntegralVipController();
        }
      }
    }
  }

  void backToMain() {
    //回到主页面
    // if (Get.currentRoute != Routes.MAIN) {
    //   Get.until((route) => Get.currentRoute == Routes.MAIN);
    // }
    ByNavRouterUtils.pushAndRemoveUntil(Get.context!, const MainPage());
  }

  void _checkShowUpgrade() {
    final provider = Get.context!.read<LaunchProvider>();
    final upgradeNotice = provider.launchInfo?.upgradeNotice ?? "";
    final hasShow = ByStorageUtils.getBool(Consts.kUpgradeDialogShown) ?? false;
    final showUpgrade = upgradeNotice.isNotEmpty && !hasShow;
    if (!showUpgrade) return;
    ByStorageUtils.saveBool(Consts.kUpgradeDialogShown, true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: Get.context!,
        builder: (ctx) {
          return CommonAlertDialog(
            title: '温馨提示',
            contents: upgradeNotice,
            confirmBtnTitle: "确定",
            showCancel: false,
            confirmCallback: (p0) {},
          );
        },
      );
    });
  }

  /// 检查是否显示VIP优惠弹窗
  void _checkShowVipDailog() {
    final provider = Get.context!.read<PurchaseProvider>();
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final hasShow = ByStorageUtils.getBool(date) ?? false;
    provider.checkShowVipDialogConfig(
      onSuccess: (configBean) {
        if (configBean.kaiGuan.valText == "1" &&
            configBean.tuPian.valText != "") {
          final isVip =
              Get.context!.read<LaunchProvider>().launchInfo?.isVip ?? 0;
          if (hasShow || isVip == 1) return;

          ///todo 更换图片地址
          /// 显示弹窗并写入plist
          showDialog(
            context: Get.context!,
            builder: (context) {
              return DailogBonusNew(
                imageNetworkUrl: configBean.tuPian.valText!,
              );
            },
          );

          ByStorageUtils.saveBool(date, true);
        }
      },
    );

    ///获取前置配置
    provider.preLoginConfig(onSuccess: () {});
  }

  void _appInit() {
    ByAscribeUtil.iniBDConvert();
    bool isUserController = Get.isRegistered<UserController>();
    if (isUserController) {
      Get.find<UserController>().checkNeedPhoneBind();
      Get.find<UserController>().checkMiaoBiConfig();
    } else {
      Get.put(UserController());
      Get.find<UserController>().checkNeedPhoneBind();
      Get.find<UserController>().checkMiaoBiConfig();
    }
  }

  @override
  void onReady() {
    super.onReady();
    // 延迟检查，确保所有弹窗逻辑都已执行完毕
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Future.delayed(const Duration(milliseconds: 500), () {
    //     // 检查是否有弹窗显示，如果没有弹窗，则请求通知权限
    //     if (_newUserBenefitsController != null &&
    //         _newUserBenefitsController!.showType.value == 0) {
    //       pushCallback();
    //     }
    //   });
    // });
  }

  @override
  void onClose() {
    super.onClose();
  }
}
