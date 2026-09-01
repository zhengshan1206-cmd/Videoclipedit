/*
 * @Author: cold-x
 * @Date: 2025-01-24 22:38:31
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-01-24 22:38:31
 * @FilePath: /video_clip_edit/lib/utils/push/privacy_manager.dart
 * @Description: 隐私政策管理类 - 确保推送服务合规性
 */

import 'package:get/get.dart';
import 'package:video_clip_edit/utils/consts/const.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';

class PrivacyManager {
  static const String _kPushServiceInitialized = 'push_service_initialized';

  /// 检查用户是否已同意隐私政策
  static bool hasAgreedPrivacy() {
    return ByStorageUtils.getBool(Consts.kAgreementChecked) ?? false;
  }

  /// 检查推送服务是否已初始化
  static bool isPushServiceInitialized() {
    return ByStorageUtils.getBool(_kPushServiceInitialized) ?? false;
  }

  /// 标记推送服务已初始化
  static Future<void> markPushServiceInitialized() async {
    await ByStorageUtils.saveBool(_kPushServiceInitialized, true);
  }

  /// 检查是否可以安全初始化推送服务
  static bool canInitializePushService() {
    return hasAgreedPrivacy() && !isPushServiceInitialized();
  }

  /// 重置推送服务状态（用于测试或重新初始化）
  static Future<void> resetPushServiceState() async {
    await ByStorageUtils.saveBool(_kPushServiceInitialized, false);
    Get.log('推送服务状态已重置');
  }
}
