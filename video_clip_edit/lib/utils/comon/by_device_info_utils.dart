/*
 * @Author: duncy
 * @Date: 2025-11-28 17:17:09
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-30 14:31:55
 * @FilePath: /video_clip_edit/lib/utils/comon/by_device_info_utils.dart
 * @Description: 
 */
import 'dart:developer';
import 'dart:io';
import 'package:android_cn_oaid/android_cn_oaid.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:bda_signal/bda_signal.dart';
import 'package:connection_network_type/connection_network_type.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:tuple/tuple.dart';
import 'package:video_clip_edit/utils/channel/channel_operate.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';

import '../consts/const.dart';

class ByDeviceInfoUtils {
  loadDeviceInfo() {
    if (ByPackageUtils.isAndroid) return DeviceInfoPlugin().androidInfo;
    return DeviceInfoPlugin().iosInfo;
  }

  /// 使用 AndroidId 替代 UUID
  static Future<Tuple2<String, String>> deviceInfo() async {
    if (Platform.isAndroid) {
      final data = await ChannelOperate.getAppDeviceInfo();
      String androidId = "";
      String oaid = "";
      if (data != null) {
        androidId = data["androidId"] ?? "";
        oaid = data["oId"] ?? "";
      } else {
        final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
        androidId = info.id;
      }
      if (androidId.isEmpty || isEmptyOrSameChar(androidId)) {
        androidId = oaid;
        if (androidId.isEmpty || isEmptyOrSameChar(androidId)) {
          androidId = await deviceIdentifier();
        }
        if (androidId.isEmpty || isEmptyOrSameChar(androidId)) {
          final cached = ByStorageUtils.getString(Consts.kLocalDeviceUuid);
          if (cached != null &&
              cached.isNotEmpty &&
              !isEmptyOrSameChar(cached)) {
            androidId = cached;
          } else {
            androidId = 'local_${DateTime.now().millisecondsSinceEpoch}';
            ByStorageUtils.saveString(Consts.kLocalDeviceUuid, androidId);
          }
        }
      }
      return Tuple2(oaid, androidId);
    }
    final IosDeviceInfo info = await DeviceInfoPlugin().iosInfo;
    return Tuple2("", info.identifierForVendor ?? "");
  }

  static bool isEmptyOrSameChar(String text) {
    return RegExp(r'^(.)\1*$').hasMatch(text.replaceAll('-', ''));
  }

  /// 获取其他设备标识
  static Future<String> deviceIdentifier() async {
    final plugin = AndroidCnOaid();
    String id = '';
    try {
      await plugin.register();
    } catch (_) {}
    try {
      if (await plugin.isSupported()) {
        id = await plugin.getOAIDByManufacturer() ?? '';
      }
    } catch (_) {}
    if (id.isEmpty || isEmptyOrSameChar(id)) {
      try {
        id = await plugin.getPseudoID();
      } catch (_) {}
    }
    if (id.isEmpty || isEmptyOrSameChar(id)) {
      try {
        id = await plugin.getGUID();
      } catch (_) {}
    }
    return id;
  }

  static Future<dynamic> getUserDiviceInfo() async {
    ///app安装时间，即第一次打开app时间
    String installedTime =
        ByStorageUtils.getString(Consts.kAppInstalledTime) ?? '';
    if (installedTime.isEmpty) {
      DateTime now = DateTime.now();
      installedTime = (now.millisecondsSinceEpoch / 1000).round().toString();
      ByStorageUtils.saveString(Consts.kAppInstalledTime, installedTime);
    }
    final String network = await getNetworkStatus();
    if (ByPackageUtils.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final appVersion = await ByPackageUtils.version();
      final di = await deviceInfo();
      return {
        "uuid": di.item2,
        "android": di.item2,
        "imei": di.item2,
        "oaid": di.item1,
        "brand": androidInfo.brand,
        "sys_version": androidInfo.version.release,
        "model": androidInfo.model,
        "app_versions": appVersion,
        "network": network,
        "installed_time": installedTime,
      };
    } else if (ByPackageUtils.isIOS) {
      log("进入到ios 获取信息===");
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      final appVersion = await ByPackageUtils.version();
      final di = await deviceInfo();
      int systemBootTime = await BdaSignal.systemBootTime();
      String appInstallTime = await BdaSignal.appInstallTime();
      String asaToken = await BdaSignal.adToken();

      ///这里oaid 在ios里取的是idfv
      String oaid = await BdaSignal.idfv();

      // final status = await AppTrackingTransparency.requestTrackingAuthorization();
      String systemInitialTime = await BdaSignal.getDeviceInitialTime();

      String idfa = await AppTrackingTransparency.getAdvertisingIdentifier();
      log(
        "进入到ios 获取信息 idfa=== $idfa  系统更新时间==> $appInstallTime 系统启动时间==> $systemBootTime  系统初始化时间==> $systemInitialTime",
      );

      return {
        "uuid": di.item2,
        "boot_time": systemBootTime.toString(),
        "mb_time": appInstallTime.toString(),
        "asa_token": asaToken,
        "sys_version": iosInfo.systemVersion,
        "oaid": oaid,
        "app_versions": appVersion,
        "model": iosInfo.utsname.machine,
        "brand": "apple",
        "idfa": idfa,
        "boot_init_time": systemInitialTime,
        "network": network,
        "installed_time": installedTime,
      };
    }
    return {
      "uuid": "",
      "android": "",
      "imei": "",
      "oaid": "",
      "brand": "",
      "sys_version": "",
      "model": "",
      "app_versions": "",
      "network": network,
      "installed_time": installedTime,
    };
  }

  static Future<String> getNetworkStatus() async {
    // If this plugin is used on Android, request the READ_PHONE_STATE permission.
    // if(ByPackageUtils.isAndroid) {
    //     await Permission.phone.request();
    // }

    NetworkStatus networkStatus = await ConnectionNetworkType()
        .currentNetworkStatus();
    switch (networkStatus) {
      case NetworkStatus.unreachable:
        return 'none';
      case NetworkStatus.wifi:
        return 'wifi';
      case NetworkStatus.mobile2G:
        return '2G';
      case NetworkStatus.mobile3G:
        return '3G';
      case NetworkStatus.mobile4G:
        return '4G';
      case NetworkStatus.mobile5G:
        return '5G';
      case NetworkStatus.otherMobile:
        return 'unknown';
    }
  }
}
