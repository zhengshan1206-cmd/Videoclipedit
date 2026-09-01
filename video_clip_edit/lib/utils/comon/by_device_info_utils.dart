/*
 * @Author: duncy
 * @Date: 2025-11-28 17:17:09
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-30 14:31:55
 * @FilePath: /video_clip_edit/lib/utils/comon/by_device_info_utils.dart
 * @Description: 设备信息，鸿蒙兼容与旧版对齐
 */
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:tuple/tuple.dart';
import 'package:video_clip_edit/utils/channel/channel_operate.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';

class ByDeviceInfoUtils {
  static const String _kAppInstalledTime = 'kAppInstalledTime';

  loadDeviceInfo() {
    if (ByPackageUtils.isAndroid) return DeviceInfoPlugin().androidInfo;
    // 鸿蒙不能直接使用 DeviceInfoPlugin().androidInfo，会抛异常
    return DeviceInfoPlugin().iosInfo;
  }

  /// 使用 AndroidId 替代 UUID
  /// isOhos 时返回 Tuple4(oaid, androidId, haid 作为 imei, odid 作为 asa_token)
  /// 其他平台返回 Tuple4，item3、item4 为空字符串以兼容
  static Future<Tuple4<String, String, String, String>> deviceInfo() async {
    if (ByPackageUtils.isOhos) {
      try {
        final data = await ChannelOperate.getAppDeviceInfo();
        String androidId = "";
        String oaid = "";
        String haid = "";
        String odid = "";
        if (data != null) {
          androidId = data["androidId"] ?? "";
          oaid = data["oId"] ?? "";
          haid = data["haid"] ?? ""; // haid 放 imei
          odid = data["odid"] ?? ""; // odid 放 asa_token
        } else {
          final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
          androidId = info.id;
        }
        byDebugPrint(androidId, tag: "归因androidId1:");
        byDebugPrint(oaid, tag: "归因oaid:");
        byDebugPrint(haid, tag: "归因haid(imei):");
        byDebugPrint(odid, tag: "归因odid(asa_token):");
        return Tuple4(oaid, androidId, haid, odid);
      } catch (e) {
        return const Tuple4("", "", "", "");
      }
    }
    if (ByPackageUtils.isAndroid) {
      try {
        final data = await ChannelOperate.getAppDeviceInfo();
        String androidId = "";
        String oaid = "";
        if (data != null) {
          androidId = data["androidId"] ?? "";
          oaid = data["oId"] ?? '';
        } else {
          final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
          androidId = info.id;
        }
        byDebugPrint(androidId, tag: "归因androidId1:");
        byDebugPrint(oaid, tag: "归因oaid:");
        return Tuple4(oaid, androidId, "", "");
      } catch (e) {
        try {
          final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
          return Tuple4("", info.id, "", "");
        } catch (_) {
          return const Tuple4("", "", "", "");
        }
      }
    }
    final IosDeviceInfo info = await DeviceInfoPlugin().iosInfo;
    return Tuple4("", info.identifierForVendor ?? "", "", "");
  }

  static Future<dynamic> getUserDiviceInfo() async {
    String installedTime = ByStorageUtils.getString(_kAppInstalledTime) ?? '';
    if (installedTime.isEmpty) {
      final now = DateTime.now();
      installedTime = (now.millisecondsSinceEpoch / 1000).round().toString();
      ByStorageUtils.saveString(_kAppInstalledTime, installedTime);
    }
    final String network = await getNetworkStatus();
    if (ByPackageUtils.isOhos) {
      // HarmonyOS：haid 放 imei，odid 放 asa_token，与旧版一致
      String brand = "";
      String sysVersion = "";
      String model = "";
      try {
        final data = await ChannelOperate.getAppDeviceInfo();
        if (data != null) {
          brand = data["brand"] ?? "";
          sysVersion = data["sysVersion"] ?? "";
          model = data["model"] ?? "";
        }
      } catch (_) {}
      if (brand.isEmpty || model.isEmpty || sysVersion.isEmpty) {
        try {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          if (brand.isEmpty) brand = androidInfo.brand;
          if (sysVersion.isEmpty) sysVersion = androidInfo.version.release;
          if (model.isEmpty) model = androidInfo.model;
        } catch (e) {
          log("HarmonyOS 获取设备信息失败: $e");
          if (brand.isEmpty) brand = "HarmonyOS";
        }
      }
      final appVersion = await ByPackageUtils.version();
      final di = await deviceInfo();
      return {
        "uuid": di.item2,
        "android": di.item2,
        "imei": di.item3, // haid 放 imei
        "oaid": di.item1,
        "asa_token": di.item4, // odid 放 asa_token
        "brand": brand,
        "sys_version": sysVersion,
        "model": model,
        "app_versions": appVersion,
        "network": network,
        "installed_time": installedTime
      };
    }
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
        "installed_time": installedTime
      };
    }
    // 仅维护鸿蒙与安卓，其余平台返回空结构
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
      "installed_time": installedTime
    };
  }

  /// 获取网络状态。connectivity_plus 无法区分 2G/3G/4G/5G，mobile 统一按 4G 上报。
  static Future<String> getNetworkStatus() async {
    try {
      final result = await Connectivity().checkConnectivity();
      final List<ConnectivityResult> list = result is List<ConnectivityResult>
          ? result as List<ConnectivityResult>
          : <ConnectivityResult>[result as ConnectivityResult];
      if (list.isEmpty) return 'unknown';
      final ConnectivityResult first = list.first;
      switch (first) {
        case ConnectivityResult.wifi:
          return 'wifi';
        case ConnectivityResult.mobile:
          return '4G';
        case ConnectivityResult.none:
          return 'none';
        case ConnectivityResult.ethernet:
          return 'wifi';
        case ConnectivityResult.bluetooth:
          return 'unknown';
        case ConnectivityResult.vpn:
          return 'unknown';
        case ConnectivityResult.other:
          return 'unknown';
      }
    } catch (_) {
      return 'unknown';
    }
  }
}
