import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_clip_edit/utils/comon/by_device_info_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';

/// 联系客服页面 URL（与 contactCustomerEvent 内跳转一致）
const String _kCustomerServiceUrl =
    'https://inchat.beiyinapp.com/api/common/customer?user_id=11407930';

class LaunchErrorController extends GetxController {
  var launching = false.obs;
  var launchFaild = false.obs;
  var progress = 0.0.obs;
  var reTryCount = 0.obs;

  ///记录错误信息
  var errorInfo = <String, dynamic>{}.obs;

  ///联系客服
  contactCustomerEvent() async {
    ///第一步 自动复制错误信息
    ///设备信息
    final Map deviceInfo = await ByDeviceInfoUtils.getUserDiviceInfo();

    ///从 LaunchProvider 获取启动接口的请求结果（重试时已经请求过了）
    final provider = Provider.of<LaunchProvider>(Get.context!, listen: false);
    final launchResult = provider.lastLaunchResult;
    final errorCode = provider.lastLaunchErrorCode;
    final errorMsg = provider.lastLaunchErrorMsg;

    // 组合信息
    Map<String, dynamic> combinedInfo = {
      "deviceInfo": deviceInfo,
      "launchRequest": {
        "result": launchResult ?? "",
        "error":
            (errorCode != null || (errorMsg != null && errorMsg.isNotEmpty))
            ? {"code": errorCode ?? "", "msg": errorMsg ?? ""}
            : "",
      },
    };

    errorInfo.value = combinedInfo;

    // 复制到剪贴板
    final errorInfoJson = json.encode(combinedInfo);
    await Clipboard.setData(ClipboardData(text: errorInfoJson));
    // BotToast.showText(text: "错误信息已复制到剪贴板");

    ///第二步 跳转客服页面（应用内 WebView）
    // ByNavRouterUtils.jumpWebViewPage(
    //   Get.context!,
    //   "联系客服",
    //   _kCustomerServiceUrl,
    // );
    openCustomerServiceInBrowser();
  }

  /// 在系统默认浏览器中打开联系客服链接。
  Future<void> openCustomerServiceInBrowser() async {
    final uri = Uri.parse(_kCustomerServiceUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
