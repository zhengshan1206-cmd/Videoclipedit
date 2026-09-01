import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/purchase/beans/pop_config_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_page_top_bean.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/controller/user_controller.dart';

/// 付费页顶部运营素材信息的 Mixin
/// 用于在 PurchaseProvider 和 IosPurchaseProvider 之间共享 loadPayPageTopInfo 方法
mixin PurchasePageTopMixin {
  /// 付费页面顶部数据
  VipPageTopData? vipPageTopData;

  /// 付费页面顶部图片列表
  List<String> vipPageTopDataList = [];

  /// 挽留弹窗/创建订单使用的套餐：取 firstPopConfig 中的默认 VipInfo（isDefault==1 或第一个）
  VipInfo? get retentionDefaultVipInfo {
    final list = firstPopConfig?.vipInfo;
    if (list == null || list.isEmpty) return null;

    return list.first;
  }

  ///支付挽留配置信息 list
  List<PopConfigBean> popConfigList = [];

  ///支付挽留配置第一个
  PopConfigBean? firstPopConfig;

  /// 支付挽留配置信息
  PopConfigBean? popConfig;

  /// 挽留弹窗展示次数缓存 key（仅保留当天，第二天重新记录）
  static const String _retentionPopCacheKey = 'retention_pop_show_cache';

  /// 当日内存叠加：防止 SpUtil 未及时持久化导致同会话内次数被漏算（读时与持久化取 max）
  static String? _retentionPopMemoryDate;
  static final Map<int, int> _retentionPopMemoryCounts = {};

  /// 当次付费页是否已展示过第一层挽留弹窗（每次进入付费页只展示一次，离开后再次进入会重置）
  bool firstLayerRetentionShownThisSession = false;

  /// 进入付费页时调用，重置当次页面的第一层弹窗展示标记
  void resetFirstLayerRetentionForSession() {
    firstLayerRetentionShownThisSession = false;
  }

  /// 通知监听者（由使用此 mixin 的类提供）
  void notifyListeners();

  /// 获取当天日期字符串 yyyy-MM-dd，用于缓存按日失效
  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 读取当天挽留弹窗展示次数缓存：{ configId -> 已展示次数 }（与当日内存叠加取 max，避免持久化延迟导致超限仍弹）
  Map<int, int> getRetentionPopShowCounts() {
    final today = _todayString();
    if (_retentionPopMemoryDate != today) {
      _retentionPopMemoryCounts.clear();
      _retentionPopMemoryDate = today;
    }
    Map<int, int> persisted = {};
    try {
      final raw = SpUtil.getString(_retentionPopCacheKey);
      if (raw != null && raw.isNotEmpty) {
        final map = json.decode(raw) as Map<String, dynamic>?;
        if (map != null && map['date'] == today) {
          final counts = map['counts'] as Map<String, dynamic>?;
          if (counts != null) {
            persisted = counts.map(
              (k, v) => MapEntry(int.tryParse(k) ?? 0, (v is int) ? v : 0),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("getRetentionPopShowCounts error: $e");
    }
    final merged = Map<int, int>.from(persisted);
    for (final e in _retentionPopMemoryCounts.entries) {
      final v = merged[e.key] ?? 0;
      if (e.value > v) merged[e.key] = e.value;
    }
    return merged;
  }

  /// 写入挽留弹窗展示次数：将指定 configId 的当日展示次数 +1（同时更新内存叠加，保证同会话内立即生效）
  void incrementRetentionPopShowCount(int configId) {
    final counts = getRetentionPopShowCounts();
    final newCount = (counts[configId] ?? 0) + 1;
    counts[configId] = newCount;
    _retentionPopMemoryCounts[configId] = newCount;
    try {
      SpUtil.putString(
        _retentionPopCacheKey,
        json.encode({'date': _todayString(), 'counts': counts}),
      );
    } catch (e) {
      debugPrint("incrementRetentionPopShowCount error: $e");
    }
  }

  /// 根据 popConfigList 顺序与当日缓存、maxShowLimit，选出当前应展示的挽留配置（第一项用完后依次往下轮）；若都不满足则返回 null
  PopConfigBean? getCurrentRetentionPopConfig() {
    if (popConfigList.isEmpty) return null;
    final counts = getRetentionPopShowCounts();
    for (final config in popConfigList) {
      final limit = config.maxShowLimit;
      if (limit <= 0) continue; // 未配置或 0 表示不展示
      final shown = counts[config.id] ?? 0;
      if (shown < limit) return config;
    }
    return null;
  }

  /// 获取审核状态 是否在审核中 1是 0否
  int get isAudit {
    try {
      // 尝试通过 Get.context 获取 LaunchProvider（通过 Provider 注册）
      LaunchProvider? launchProvider;
      if (Get.context != null) {
        try {
          launchProvider = Provider.of<LaunchProvider>(
            Get.context!,
            listen: false,
          );
        } catch (e) {
          debugPrint("isAudit get LaunchProvider from context error: $e");
        }
      }

      // 如果通过 context 获取失败，尝试使用 Get.find
      if (launchProvider == null) {
        try {
          launchProvider = Get.find<LaunchProvider>();
        } catch (e) {
          debugPrint("isAudit get LaunchProvider from Get.find error: $e");
        }
      }

      return launchProvider?.launchInfo?.isAudit ?? 0;
    } catch (e) {
      debugPrint("isAudit error: $e");
      return 0;
    }
  }

  /// 获取是否是48小时内重新归因的用户 0否 1是
  int get isNewAttributionUser {
    try {
      UserController? userController;

      // 尝试通过 Get.context 获取 UserController（通过 Get 注册）
      // 注意：UserController 是通过 Get 注册的，不是 Provider
      if (Get.isRegistered<UserController>()) {
        try {
          userController = Get.find<UserController>();
        } catch (e) {
          debugPrint("isNewAttributionUser get UserController error: $e");
        }
      }

      return userController?.user.value?.isNewAttributionUser ?? 0;
    } catch (e) {
      debugPrint("isNewAttributionUser error: $e");
      return 0;
    }
  }

  String get landingPage {
    try {
      if (Get.context != null) {
        return Provider.of<LaunchProvider>(
              Get.context!,
              listen: false,
            ).launchInfo?.verConfig.landingPage ??
            "";
      }
      // 如果 Get.context 为空，尝试使用 Get.find
      return Get.find<LaunchProvider>().launchInfo?.verConfig.landingPage ?? "";
    } catch (e) {
      return "";
    }
  }

  String get halfScreenPage {
    try {
      if (Get.context != null) {
        return Provider.of<LaunchProvider>(
              Get.context!,
              listen: false,
            ).launchInfo?.verConfig.halfScreenPage ??
            "";
      }
      // 如果 Get.context 为空，尝试使用 Get.find
      return Get.find<LaunchProvider>().launchInfo?.verConfig.halfScreenPage ??
          "";
    } catch (e) {
      return "";
    }
  }

  /// 获取付费页顶部运营素材信息
  void loadPayPageTopInfo() {
    String payPageId = "";
    String topOperateMaterialId = "";
    try {
      payPageId = Get.find<LaunchProvider>().payPageId ?? "";
      topOperateMaterialId =
          Get.find<LaunchProvider>().topOperateMaterialId ?? "";
    } catch (e) {
      // LaunchProvider 未注册时，静默失败
      debugPrint("loadPayPageTopInfo error: $e");
      return;
    }

    if (payPageId.isEmpty && topOperateMaterialId.isEmpty) {
      return;
    }
    HttpUtils.get(
      APIs.getPayPageTopMaterial,
      {
        "pay_page_id": payPageId,
        "top_operate_material_id": topOperateMaterialId,
      },
      showMsgWhenFailed: false,
      success: (data) {
        VipPageTopBeanResponse vipPageTopBeanResponse =
            VipPageTopBeanResponse.fromJson(data);
        if (vipPageTopBeanResponse.data != null) {
          vipPageTopData = vipPageTopBeanResponse.data;
          if (vipPageTopData != null) {
            vipPageTopDataList.clear();
            vipPageTopDataList.addAll(vipPageTopData!.pics);
            notifyListeners();
          }
        }
      },
      fail: (code, msg) {},
    );
  }

  ///付费页曝光上报
  void reportPayPageTopInfo(
    String? pageTag,
    String? funcDetailImg,
    String? operateType, {
    String? vipId,
    int payType = 0,
    bool isHalfScreen = false,
  }) {
    try {
      String payPageId = "";
      String funcDetailTagValue = "";

      // 尝试通过 Get.context 获取 LaunchProvider（通过 Provider 注册）
      LaunchProvider? launchProvider;
      if (Get.context != null) {
        try {
          launchProvider = Provider.of<LaunchProvider>(
            Get.context!,
            listen: false,
          );
        } catch (e) {
          debugPrint(
            "reportPayPageTopInfo get LaunchProvider from context error: $e",
          );
        }
      }

      // 如果通过 context 获取失败，尝试使用 Get.find
      if (launchProvider == null) {
        try {
          launchProvider = Get.find<LaunchProvider>();
        } catch (e) {
          debugPrint(
            "reportPayPageTopInfo get LaunchProvider from Get.find error: $e",
          );
        }
      }

      // 获取 payPageId 和 funcDetailTagValue
      if (launchProvider != null) {
        payPageId = launchProvider.payPageId ?? "";
        // 如果是半弹窗付费页，使用 halfScreenPage，否则使用 landingPage
        if (isHalfScreen) {
          funcDetailTagValue =
              launchProvider.launchInfo?.verConfig.halfScreenPage ?? "";
        } else {
          funcDetailTagValue =
              launchProvider.launchInfo?.verConfig.landingPage ?? "";
        }
      } else {
        // 如果 LaunchProvider 获取失败，使用 getter 方法作为备选
        funcDetailTagValue = isHalfScreen ? halfScreenPage : landingPage;
      }

      // 即使 LaunchProvider 未注册，也继续上报
      ByNavigatorUtil.reportDataPoint(
        pageTag: pageTag ?? "member_page",
        operateType: operateType ?? "click",
        funcDetailTag: funcDetailTagValue,
        funcDetailImg: funcDetailImg ?? "",
        extra: payType > 0
            ? {
                "pay_page_id": payPageId,
                "vip_id": vipId ?? "0",
                "pay_type2": payType,
              }
            : {"pay_page_id": payPageId, "vip_id": vipId ?? "0"},
      );
    } catch (e) {
      // 上报失败时记录错误，但不影响其他功能
      debugPrint("reportPayPageTopInfo error: $e");
    }
  }

  ///获取支付挽留配置信息 新版本逻辑3.10.45
  void getPopConfig() {
    HttpUtils.get(
      APIs.getPopConfig,
      {},
      success: (data) {
        byDebugPrint(data, tag: "getPopConfig:---");
        final config = data["data"]["item"];
        if (config != null && config is List) {
          popConfigList.clear();
          popConfigList.addAll(config.map((e) => PopConfigBean.fromJson(e)));
          firstPopConfig = popConfigList.first;
        }
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
      },
    );
  }

  ///根据id获取支付挽留配置信息 新版本逻辑3.10.45
  void getPopConfigById(int id, {Function()? onSuccess, Function()? onFailed}) {
    HttpUtils.get(
      APIs.getPopUpConfigById,
      {"id": id},
      success: (data) {
        final config = data["data"];
        byDebugPrint(config, tag: "getPopConfigById:---");
        if (config != null && config is Map && (config as Map).isNotEmpty) {
          firstPopConfig = PopConfigBean.fromJson(
            Map<String, dynamic>.from(config),
          );
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        onFailed?.call();
      },
    );
  }
}
