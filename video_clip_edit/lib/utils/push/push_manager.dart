/*
 * @Author: cold-x
 * @Date: 2025-05-16 09:37:23
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-05-20 18:15:52
 * @FilePath: /video_clip_edit/lib/utils/push/push_manager.dart
 * @Description: 推送数据管理器
 */



import 'dart:convert';
import 'package:get/get.dart';
import '../../routes/route_utils.dart';
import '../comon/by_common_utils.dart';
import '../comon/by_nav_router_utils.dart';
import 'push_bean.dart';

//推送数据类型
enum PushType {
  // 1: 页面跳转
  page(1),

  // 2: 内部webview
  internalWebView(2),

  // 3: 外部webview
  externalWebView(3);

  final int value;
  const PushType(this.value);
  
  static PushType fromRawValue(int rawValue) {
    switch (rawValue) {
      case 1:
        return page;
      case 2:
        return internalWebView;
      case 3:
        return externalWebView;
      default:
        return page;
    }
  }
}

class PushManager {

  static void handlePushNotification(dynamic message) {
    Map<String, dynamic> jsonMap = json.decode(message);
    if (jsonMap.keys.isEmpty){
      return;
    }
    Map<String, dynamic> params = {};
    if (jsonMap.keys.contains('extra')) {
      params = jsonMap['extra'];
    } else {
      params = jsonMap;
    }
    Get.log("~~~~~通知类型，跳转url：$params");
    PushBean pushBean = PushBean.fromJson(params);
    Get.log("~~~~~，跳转url：${pushBean.url}");
    // 消息处理
    switch (PushType.fromRawValue(int.parse(pushBean.type))) {
      //跳转至指定页面
      case PushType.page:
      RouteUtils.gotoPage(Get.context!, pushBean.url, params: pushBean.args);
        break;
      //跳转至内部网页链接
      case PushType.internalWebView:
        ByNavRouterUtils.jumpWebViewPage(
            Get.context!,
            "",
            pushBean.url,
            isRisk: false,
          );
        break;
      //跳转至外部网页链接
      case PushType.externalWebView:
        ByCommonUtils.launchWebURL(pushBean.url);
        break;
      default:
        break;
    }
  }
}