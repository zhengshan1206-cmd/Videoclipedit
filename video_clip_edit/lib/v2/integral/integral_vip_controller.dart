import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/rights_by_type.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/v2/integral/integral_controller.dart';
import 'package:video_clip_edit/v2/integral/integral_pay_dialog.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'dart:math' as math;

/// 积分VIP权益管理Controller
/// 用于管理用户积分消耗、VIP权益等业务逻辑
class IntegralVipController extends GetxController {
  /// 安全获取或注册 IntegralVipController，避免在部分功能入口未注册时报错
  static IntegralVipController getOrPut() {
    if (!Get.isRegistered<IntegralVipController>()) {
      Get.put(IntegralVipController(), permanent: true);
    }
    return Get.find<IntegralVipController>();
  }

  late final IntegralController _integralController;

  /// 积分模块是否开启
  /// 注意：在PurchaseProvider中，isIntegralOpen为true表示积分模块不展示
  bool _isIntegralOpen = true;

  /// 用户权益数据
  final _rights = Rxn<RightsByType>();

  /// 所需积分
  final _requiredPoints = 0.obs;

  /// 功能入口类型
  final _type = RxnString();

  /// 视频时长
  int _videoDuration = 5;

  /// 生成模式
  String _generateMode = "std";

  @override
  void onInit() {
    super.onInit();
    _integralController = IntegralController.getOrPut();

    // 初始化时获取积分模块状态
    _updateIntegralOpenStatus();
  }

  /// 更新积分模块开启状态
  void _updateIntegralOpenStatus() {
    final purchaseProvider = Get.context?.read<PurchaseProvider>();
    if (purchaseProvider != null) {
      _isIntegralOpen = purchaseProvider.isIntegralOpen;
    }
    // print("99999999999999999${_isIntegralOpen}");
  }

  /// 检查积分模块是否开启
  /// 如果积分模块未开启，则返回true表示可以继续使用功能
  bool _isIntegralModuleEnabled() {
    // 修正逻辑：isIntegralOpen为true表示积分模块不展示，所以返回false
    return !_isIntegralOpen;
  }

  UserController get userController => Get.find<UserController>();
  //用户信息
  UserInfoBean? get userInfo => userController.user.value;

  /// 获取用户权益数据
  RightsByType? get rights => _rights.value;

  /// 获取所需积分
  int get requiredPoints => _requiredPoints.value;

  /// 获取免费次数
  int get freeCount => _rights.value?.freeCount ?? 0;

  /// 获取试用次数
  int get isTest => _rights.value?.testCount ?? 0;

  /// 获取实际消耗积分
  /// 如果有权益数据则使用权益数据中的积分,否则使用所需积分
  int get actualPoints {
    if (_rights.value?.configIntegral != null && isShowIntegral) {
      return _rights.value?.configIntegral ?? 0;
    }
    return _requiredPoints.value;
  }

  /// 判断积分是否不足
  bool get isPointsInsufficient => currentUserPoints < actualPoints;

  /// 获取用户当前积分
  int get currentUserPoints => isShowIntegral
      ? _rights.value?.userIntegral ?? 0
      : userInfo?.integral ?? 0;

  /// 判断是否需要前端计算积分（动态视频模块）
  bool isShowIntegral = false;

  /// 检查是否可以继续使用功能
  /// 返回true表示可以继续使用,false表示需要购买积分或开通VIP
  bool canContinueUse() {
    // 如果积分模块未开启，则允许继续使用
    // if (!_isIntegralModuleEnabled()) {
    //   return true;
    // }
    print(
      '_____$isPointsInsufficient,,${_rights.value?.userIntegral},  $actualPoints,,, $currentUserPoints',
    );
    // 只有VIP用户才校验积分
    if (userInfo?.isVip == 1) {
      return !isPointsInsufficient || freeCount > 0 || isTest > 0;
    }
    return true;
  }

  /// 显示积分购买弹窗
  void showIntegralPayDialog() {
    // 如果积分模块未开启，则不显示购买弹窗
    // if (!_isIntegralModuleEnabled()) {
    //   return;
    // }

    if (!Get.isDialogOpen! && !Get.isBottomSheetOpen!) {
      Get.bottomSheet(
        const IntegralPayDialog(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
      ).then((value) {
        // 刷新积分信息
        if (_type.value != null) {
          init(requiredPoints: _requiredPoints.value, type: _type.value!);
        }
      });
    }
  }

  /// 初始化Controller
  /// [requiredPoints] 所需积分
  /// [type] 权益类型
  /// [generateMode] 生成模式 std = 标准 和 pro = 高清
  /// [videoDuration] 视频时长
  void init({
    required int requiredPoints,
    required String type,
    String? generateMode,
    int? videoDuration,
  }) {
    // 更新积分模块状态
    _updateIntegralOpenStatus();
    // print("111111111111111111111111");

    // 如果积分模块未开启，则不进行初始化
    // if (!_isIntegralModuleEnabled()) {
    //   return;
    // }
    // print("00000000000000000000000");

    void apply() {
      _requiredPoints.value = requiredPoints;
      _type.value = type;
      if (videoDuration != null) {
        _videoDuration = videoDuration;
      }
      if (generateMode != null) {
        _generateMode = generateMode;
      }
      _loadRights();

      IntegralController.getOrPut();
      // 更新用户信息以刷新积分
      if (Get.isRegistered<UserController>()) {
        Get.find<UserController>().reloadUserInfo();
      }
    }

    // 在 State.initState / 首次 build 过程中同步改 Rx 会通知 Obx → setState，
    // 触发 “setState/markNeedsBuild during build”。仅在帧空闲时同步执行，否则推到帧末。
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      apply();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) => apply());
    }
  }

  /// 加载权益数据
  /// 根据权益类型从服务器获取对应的权益数据
  void _loadRights() {
    if (_type.value == null || _type.value!.isEmpty) return;

    HttpUtils.post(
      APIs.getRightsByType,
      {"type": _type.value!},
      success: (data) {
        print("权益接口---->${_type.value!}");
        byDebugPrint(data["data"]);
        try {
          final rghtsByType = RightsByType.fromJson(data["data"]);
          _rights.value = rghtsByType;
          updateRequiredPoints();
        } catch (e) {
          byDebugPrint("权益数据解析错误: $e");
          _rights.value = null;
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 更新所需积分
  void updateRequiredPoints({int? points = 0}) {
    if (points != 0) {
      isShowIntegral = false;
      _requiredPoints.value = points!;
      return;
    }
    // print(
    //     "111112222-${_generateMode}-${_videoDuration}-${_type.value}-${_rights.value?.currentIntegral}");
    // 前端根据选择进行积分消耗计算
    if (_type.value == "ai_text2_video" ||
        _type.value == "ai_image2_video" ||
        _type.value == "ai_video_f2e" ||
        _type.value == "ai_video_multi") {
      _requiredPoints.value = _calculateRequiredPoints(
        basePoints: _rights.value?.configIntegral ?? 0,
        generateMode: _generateMode,
        videoDuration: _videoDuration,
      );
      isShowIntegral = _shouldShowFreeCount(_generateMode, _videoDuration);
    } else {
      isShowIntegral = true;
      _requiredPoints.value = _rights.value?.configIntegral ?? 0;
    }
    print("0000000000000-${_requiredPoints.value}-${isShowIntegral}");
  }

  /// 更新权益类型
  /// [type] 新的权益类型
  void updateType(String type) {
    _type.value = type;
    _loadRights();
  }

  /// 处理状态码
  /// [code] 状态码
  /// [msg] 错误信息
  /// [mark] 来源标记
  void handleStatusCode(int code, String msg, String mark) {
    switch (code) {
      case 1002:
        // vip特价弹窗
        final provider = Get.context?.read<AiSquareProvider>();
        if (provider != null) {
          provider.showModelPayDialog(Get.context!, mark);
        }
        break;
      case 1000001:
        // 积分不足
        showIntegralPayDialog();
        break;
      // default:
      //   BotToast.showText(text: msg);
      //   break;
    }
  }

  /// 计算所需积分
  /// [basePoints] 基础积分
  /// [generateMode] 生成模式 std/pro
  /// [videoDuration] 视频时长
  int _calculateRequiredPoints({
    required int basePoints,
    String? generateMode,
    int? videoDuration,
  }) {
    if (basePoints <= 0) {
      return 0;
    }

    int multiplier = 1;

    // 根据生成模式计算倍数
    if (generateMode == "pro") {
      multiplier *= 2;
    }

    // 根据视频时长计算倍数
    if (videoDuration == 10) {
      multiplier *= 2;
    }

    // 确保最小积分为1
    return math.max(1, (basePoints * multiplier).round());
  }

  // 只有在标准模式且5秒时长的情况下才显示限免次数
  bool _shouldShowFreeCount(String? generateMode, int? videoDuration) {
    return generateMode == "std" && videoDuration == 5;
  }
}
