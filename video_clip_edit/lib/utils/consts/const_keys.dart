import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ConstKeys {
  static const String kToken = "token";
  static const String kClientType = "client_type";
  static const String kSign = "sign";
  static const String kChannel = "channel";
  static const String kTimeStamp = "timestamp";
  static const String kAccept = "Accept";
  static const String kContentType = "Content-Type";
  static const String kAppVersion = "appVersion";
  static const String kAppFramework = "app_framework";
  static const String kUserAgent = "User-Agent";
  static const String kPagePath = "page_path";
  static const String kPrePagePath = "pre_page_path";

  static String userAgentData = "";

  initUserAgentData() async {
    userAgentData = await IosUserAgentUtil.getDefaultUserAgent();
    log("userAgentData======> $userAgentData");
  }
}

class IosUserAgentUtil {
  static String? _defaultUserAgent;

  static Future<String> getDetailedUserAgent() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        // 获取设备信息
        final deviceInfo = DeviceInfoPlugin();
        final iosInfo = await deviceInfo.iosInfo;

        // 获取默认User-Agent
        String defaultUserAgent = await getDefaultUserAgent();

        // 添加设备信息
        return '$defaultUserAgent (${iosInfo.model}; ${iosInfo.systemVersion})';
      } catch (e) {
        return await getDefaultUserAgent();
      }
    }

    return await getDefaultUserAgent();
  }

  static Future<String> getDefaultUserAgent() async {
    if (_defaultUserAgent != null) {
      return _defaultUserAgent!;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted);

        _defaultUserAgent = await controller.getUserAgent();
        return _defaultUserAgent ??
            'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1';
      } catch (e) {
        return 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1';
      }
    }

    return 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1';
  }
}
