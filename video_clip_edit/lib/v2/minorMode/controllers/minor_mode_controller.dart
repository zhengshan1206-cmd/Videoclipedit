import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/utils/comon/by_encrypt_utils.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/minorMode/beans/minor_mode_info_bean.dart';
import 'package:video_clip_edit/v2/minorMode/minor_mode_block_reason.dart';
import 'package:video_clip_edit/v2/minorMode/minor_mode_time_utils.dart';
import 'package:video_clip_edit/v2/minorMode/minor_mode_usage_tracker.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/v2/minorMode/beans/minor_page_type.dart';
import 'package:video_clip_edit/v2/minorMode/controllers/minor_create_controller.dart';

/// 未成年人模式全局配置，供首页及其他模块读取。
class MinorModeController extends GetxController {
  final info = Rxn<MinorModeInfoBean>();
  final usageSeconds = 0.obs;

  String? _cachedParentPassword;
  MinorModeUsageTracker? _usageTracker;

  bool get isMinorModeEnabled => info.value?.isMinorModeEnabled ?? false;

  bool get isInDisabledPeriodNow =>
      info.value?.isInDisabledPeriodNow() ?? false;

  bool get isUsageTimeExceeded =>
      info.value?.isUsageTimeExceeded(usageSeconds.value) ?? false;

  MinorModeBlockReason? get blockReason {
    final config = info.value;
    if (config == null || !config.isMinorModeEnabled) return null;

    final now = MinorModeTimeUtils.chinaNow();
    if (config.isInDisabledPeriodNow(now)) {
      return MinorModeBlockReason.disabledPeriod;
    }
    if (config.isUsageTimeExceeded(usageSeconds.value, now)) {
      return MinorModeBlockReason.usageLimit;
    }
    return null;
  }

  bool get shouldBlockHomeNavigation => blockReason != null;

  @override
  void onInit() {
    super.onInit();
    _initUsageTracker();
  }

  @override
  void onClose() {
    _usageTracker?.dispose();
    _usageTracker = null;
    super.onClose();
  }

  void _initUsageTracker() {
    _usageTracker?.dispose();
    _usageTracker = MinorModeUsageTracker(
      shouldTrack: () => isMinorModeEnabled,
      isInDisabledPeriod: () => isInDisabledPeriodNow,
      canContinueCounting: _canContinueCountingUsage,
      onUsageChanged: (seconds) {
        usageSeconds.value = seconds;
        _syncUsageTracking();
      },
    )..init();
    usageSeconds.value = _usageTracker!.usageSeconds;
  }

  bool _canContinueCountingUsage() {
    final config = info.value;
    if (config == null || !config.isMinorModeEnabled) return false;
    final limitMinutes = config.timeLimitForDate(MinorModeTimeUtils.chinaNow())?.totalUseTime;
    if (limitMinutes == null || limitMinutes <= 0) return true;
    return (_usageTracker?.usageSeconds ?? usageSeconds.value) < limitMinutes * 60;
  }

  void _syncUsageTracking() {
    _usageTracker?.syncTimer();
    usageSeconds.value = _usageTracker?.usageSeconds ?? usageSeconds.value;
  }

  /// 接口是否已下发家长密码（MD5 字段 p）
  bool get hasConfiguredPassword {
    final md5 = info.value?.passwordMd5?.trim();
    return md5 != null && md5.isNotEmpty;
  }

  /// 二次编辑/开关接口提交用的明文密码（验证通过后本地缓存）
  String? get resolvedParentPassword {
    final cached = _cachedParentPassword?.trim();
    if (cached != null && cached.length == 4) return cached;
    return null;
  }

  void setParentPassword(String? password) {
    final value = password?.trim();
    if (value != null && value.isNotEmpty) {
      _cachedParentPassword = value;
    }
  }

  /// 本地比对：输入明文 MD5 后与配置 p 字段比较
  bool verifyParentPassword(String input) {
    final plain = input.trim();
    if (plain.isEmpty) return false;

    final md5FromConfig = info.value?.passwordMd5?.trim();
    if (md5FromConfig != null && md5FromConfig.isNotEmpty) {
      return ByEncryptUtils.md5String(plain) == md5FromConfig;
    }

    final cached = _cachedParentPassword?.trim();
    if (cached != null && cached.isNotEmpty) {
      return plain == cached;
    }
    return false;
  }

  bool get canVerifyPassword =>
      hasConfiguredPassword || resolvedParentPassword != null;

  /// 关闭/开启未成年人模式，status：1-开启，2-关闭
  Future<bool> setMinorModeStatus({
    required int status,
    required String password,
  }) async {
    final completer = Completer<bool>();

    HttpUtils.post(
      APIs.setMinorModeStatus,
      {'status': status.toString(), 'password': password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
      showLoading: true,
      loadingText: '提交中...',
      success: (data) {
        byDebugPrint(data, tag: 'setMinorModeStatus:===>');
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          EasyLoading.showToast(message);
        }
        completer.complete(true);
      },
      fail: (code, msg) {
        byDebugPrint(
          'setMinorModeStatus fail: $code $msg',
          tag: 'setMinorModeStatus:===>',
        );
        if (msg.isNotEmpty) {
          EasyLoading.showToast(msg);
        }
        completer.complete(false);
      },
    );

    return completer.future;
  }

  /// 切换未成年人模式开关，成功后刷新配置并更新首页 UI
  Future<bool> changeMinorModeEnabled({
    required bool enabled,
    required String password,
  }) async {
    final status = enabled
        ? MinorModeInfoBean.statusEnabled
        : MinorModeInfoBean.statusDisabled;
    final success = await setMinorModeStatus(status: status, password: password);
    if (!success) return false;
    await fetchMinorModeInfo(showLoading: false);
    applyMinorModeState();
    return true;
  }

  static MinorModeController get to {
    if (!Get.isRegistered<MinorModeController>()) {
      Get.put(MinorModeController(), permanent: true);
    }
    return Get.find<MinorModeController>();
  }

  Future<bool> fetchMinorModeInfo({bool showLoading = false}) async {
    final completer = Completer<bool>();

    HttpUtils.get(
      APIs.minorModeInfo,
      {},
      showLoading: showLoading,
      loadingText: '加载中...',
      success: (data) {
        byDebugPrint(data, tag: 'minorModeInfo:===>');
        final infoData = data['data'];
        Map<String, dynamic>? configMap;
        if (infoData is Map) {
          configMap = Map<String, dynamic>.from(infoData);
        } else if (data is Map && data.containsKey('time_limit')) {
          configMap = Map<String, dynamic>.from(data);
        }
        if (configMap != null) {
          info.value = MinorModeInfoBean.fromJson(configMap);
          byDebugPrint(
            'parsed minorMode: enabled=${info.value?.isMinorModeEnabled}, '
            'disabledPeriod=${info.value?.isInDisabledPeriodNow()}, '
            'isEnable=${info.value?.unifiedTimeLimit?.isEnable}, '
            'period=${info.value?.unifiedTimeLimit?.disabledPeriodText}, '
            'chinaNow=${MinorModeTimeUtils.formatDateTime(MinorModeTimeUtils.chinaNow())}',
            tag: 'minorModeInfo:===>',
          );
        } else {
          info.value = null;
        }
        applyMinorModeState();
        completer.complete(true);
      },
      fail: (code, msg) {
        byDebugPrint(
          'minorModeInfo fail: $code $msg',
          tag: 'minorModeInfo:===>',
        );
        completer.complete(false);
      },
    );

    return completer.future;
  }

  /// 找回密码：phone + code + password
  Future<bool> forgotMinorModePassword({
    required String phone,
    required String code,
    required String password,
  }) async {
    final completer = Completer<bool>();

    HttpUtils.post(
      APIs.forgotMinorModePassword,
      {
        'phone': phone,
        'code': code,
        'password': password,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
      showLoading: true,
      loadingText: '提交中...',
      success: (data) {
        byDebugPrint(data, tag: 'forgotMinorModePassword:===>');
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          EasyLoading.showToast(message);
        }
        setParentPassword(password);
        completer.complete(true);
      },
      fail: (code, msg) {
        byDebugPrint(
          'forgotMinorModePassword fail: $code $msg',
          tag: 'forgotMinorModePassword:===>',
        );
        if (msg.isNotEmpty) {
          EasyLoading.showToast(msg);
        }
        completer.complete(false);
      },
    );

    return completer.future;
  }

  Future<bool> enableMinorMode({
    required String birthday,
    required String phone,
    required String password,
  }) async {
    final completer = Completer<bool>();

    HttpUtils.post(
      APIs.enableMinorMode,
      {'birthday': birthday, 'phone': phone, 'password': password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
      showLoading: true,
      loadingText: '提交中...',
      success: (data) {
        byDebugPrint(data, tag: 'enableMinorMode:===>');
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          EasyLoading.showToast(message);
        }
        setParentPassword(password);
        completer.complete(true);
      },
      fail: (code, msg) {
        byDebugPrint(
          'enableMinorMode fail: $code $msg',
          tag: 'enableMinorMode:===>',
        );
        if (code.toString() == '-1' && msg.contains('未成年人模式已配置')) {
          navigateToTimeManage();
          completer.complete(false);
          return;
        }
        if (msg.isNotEmpty) {
          EasyLoading.showToast(msg);
        }
        completer.complete(false);
      },
    );

    return completer.future;
  }

  /// 拉取最新配置并进入时间管理页（已配置时复用）。
  Future<void> navigateToTimeManage() async {
    await fetchMinorModeInfo(showLoading: false);

    if (Get.currentRoute == Routes.minorCreatePage &&
        Get.isRegistered<MinorCreateController>()) {
      final createController = Get.find<MinorCreateController>();
      createController.applyMinorModeInfo(info.value);
      createController.switchPageType(MinorPageType.timeManage);
      return;
    }

    await Get.toNamed(
      Routes.minorCreatePage,
      arguments: MinorPageType.timeManage,
    );
    if (Get.isRegistered<MinorCreateController>()) {
      Get.find<MinorCreateController>().applyMinorModeInfo(info.value);
    }
  }

  Future<bool> updateMinorModeTimeLimit({
    required int mode,
    required String timeLimit,
    String? password,
  }) async {
    final completer = Completer<bool>();
    final params = <String, dynamic>{
      'mode': mode.toString(),
      'time_limit': timeLimit,
    };
    if (password != null && password.isNotEmpty) {
      params['password'] = password;
    }

    HttpUtils.post(
      APIs.updateMinorModeTimeLimit,
      params,
      options: Options(contentType: Headers.formUrlEncodedContentType),
      showLoading: true,
      loadingText: '保存中...',
      success: (data) {
        byDebugPrint(data, tag: 'updateMinorModeTimeLimit:===>');
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          EasyLoading.showToast(message);
        }
        completer.complete(true);
      },
      fail: (code, msg) {
        byDebugPrint(
          'updateMinorModeTimeLimit fail: $code $msg',
          tag: 'updateMinorModeTimeLimit:===>',
        );
        if (msg.isNotEmpty) {
          EasyLoading.showToast(msg);
        }
        completer.complete(false);
      },
    );

    return completer.future;
  }

  void applyMinorModeState() {
    _syncUsageTracking();
    if (isMinorModeEnabled && Get.isRegistered<MainController>()) {
      Get.find<MainController>().enforceMinorModeHome();
    }
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().update();
    }
  }

  void _navigateToPasswordEnable() {
    Get.toNamed(
      Routes.minorCreatePage,
      arguments: const MinorCreateRouteArgs(
        pageType: MinorPageType.enterPassword,
        verifyIntent: MinorVerifyIntent.openMinorMode,
      ),
    );
  }

  /// 个人中心入口：已配置则验证密码后 setMinorModeStatus 开启，否则进介绍页
  Future<void> openMinorModeFromProfile() async {
    await fetchMinorModeInfo(showLoading: true);

    if (info.value?.canQuickEnable == true) {
      _navigateToPasswordEnable();
      return;
    }

    Get.toNamed(Routes.minorPage);
  }

  /// 介绍页「开启」：已配置则验证密码开启，否则进首次填表流程
  Future<void> openEnableMinorModeFlow() async {
    await fetchMinorModeInfo(showLoading: true);

    if (info.value?.canQuickEnable == true) {
      _navigateToPasswordEnable();
      return;
    }

    Get.toNamed(Routes.minorCreatePage, arguments: MinorPageType.enable);
  }
}
