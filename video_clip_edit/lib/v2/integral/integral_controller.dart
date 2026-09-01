import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'dart:math' as math;
import 'package:video_clip_edit/modules/purchase/beans/integral_record_bean.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class IntegralController extends GetxController {
  /// 安全获取或注册 IntegralController，避免在部分功能入口未注册时报错
  static IntegralController getOrPut() {
    if (!Get.isRegistered<IntegralController>()) {
      Get.put(IntegralController(), permanent: true);
    }
    return Get.find<IntegralController>();
  }

  UserController get userController => Get.find<UserController>();

  UserInfoBean? get userInfo => userController.user.value;

  //tabs
  List<String> tabs = ['全部', '获取', '消耗'];

  // 当前选中的tab  0所有 1获取 2消耗
  RxInt selectedTabIndex = 0.obs;

  // 积分记录列表
  RxList<IntegralRecordBean> integralRecords = <IntegralRecordBean>[].obs;

  //积分页码
  RxInt page = 1.obs;

  //分页条数
  RxInt pageSize = 10.obs;

  // 是否正在刷新
  RxBool isRefreshing = false.obs;

  // 当前积分
  RxInt currentIntegral = 0.obs;

  // 积分说明
  RxString integralIllustrate = "".obs;

  // 下拉刷新控制器
  final EasyRefreshController refreshController = EasyRefreshController();

  @override
  void onInit() {
    super.onInit();
    _listenUserInfoChanges();
  }

  @override
  void onReady() {
    super.onReady();
    // 先重置所有状态
    resetState();
    // 然后刷新数据
    // Future.microtask(() => onRefresh());
  }

  @override
  void onClose() {
    // 清理数据
    resetState();
    refreshController.dispose();
    super.onClose();
  }

  // 重置所有状态
  void resetState() {
    selectedTabIndex.value = 0;
    page.value = 1;
    integralRecords.clear();
    currentIntegral.value = userInfo?.integral ?? 0;
  }

  // tab点击事件
  void tabBarTap(int index) {
    selectedTabIndex.value = index;
    page.value = 1;
    integralRecords.clear();
    getIntegralRecords();
  }

  // 获取积分记录
  Future<void> getIntegralRecords() async {
    try {
      currentIntegral.value = userInfo!.integral;
      HttpUtils.get(
        APIs.scoreRecords,
        {
          "page": page.value,
          "size": pageSize.value,
          "type": selectedTabIndex.value,
        },
        success: (data) {
          if (data == null || data["data"] == null) {
            BotToast.showText(text: "获取积分记录失败");
            return;
          }

          final List items = data["data"]["items"] ?? [];
          final List<IntegralRecordBean> records = items
              .map((ele) => IntegralRecordBean.fromJson(ele))
              .toList();

          // 安全地处理积分说明
          final String illustrate =
              data["data"]["integral_illustrate"]?.toString() ?? "";
          integralIllustrate.value = illustrate;

          if (page.value == 1) {
            integralRecords.value = records;
          } else {
            if (records.isEmpty) {
              page.value--; // 如果没有更多数据,回退页码
              // BotToast.showText(text: "没有更多数据了");
            } else {
              integralRecords.addAll(records);
            }
          }
          update();
        },
        fail: (code, msg) {
          page.value = math.max(1, page.value - 1); // 请求失败时回退页码
          BotToast.showText(text: msg);
        },
      );
    } catch (e) {
      page.value = math.max(1, page.value - 1); // 发生错误时回退页码
      BotToast.showText(text: "获取积分记录失败");
    }
  }

  // 刷新
  Future<void> onRefresh() async {
    try {
      isRefreshing.value = true;
      page.value = 1;
      await getIntegralRecords();
    } catch (e) {
      BotToast.showText(text: "刷新失败");
    } finally {
      isRefreshing.value = false;
    }
  }

  // 加载更多
  Future<void> onLoadMore() async {
    try {
      page.value++;
      await getIntegralRecords();
    } catch (e) {
      page.value = math.max(1, page.value - 1); // 发生错误时回退页码
      BotToast.showText(text: "加载更多失败");
    }
  }

  // 监听用户信息变化
  void _listenUserInfoChanges() {
    ever(userController.user, (UserInfoBean? user) {
      if (user != null) {
        currentIntegral.value = user.integral;
      }
    });
  }
}
