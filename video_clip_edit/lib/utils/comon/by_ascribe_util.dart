import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:video_clip_edit/utils/channel/channel_operate.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

/**
 * 归因
 */
class ByAscribeUtil {
  static int oceanengineState = 0;
  static List<Map<String, dynamic>> oceanengineEventList = [];
  //初始化
  static Future<dynamic> iniBDConvert() async {
    dynamic r;
    if (ByPackageUtils.isAndroid || ByPackageUtils.isOhos) {
      r = await ChannelOperate.initAppConfig("578909", "channel");
    }
    oceanengineState = 1;
    if (oceanengineEventList.isNotEmpty) {
      for (var i = 0; i < oceanengineEventList.length; i++) {
        oceanengineEvent(oceanengineEventList[i]);
      }
      oceanengineEventList = [];
    }
    return r;
  }

  /**
   * 贝因插件
   */
  static void byuniplugin(List<dynamic> list) async {
    for (var i = 0; i < list.length; i++) {
      Map<String, dynamic> item = list[i];
      String method = item["method"];
      Map<String, dynamic> params = item["params"];
      if (method == "oceanengineEvent") {
        if (oceanengineState == 0) {
          oceanengineEventList.add(params);
        } else {
          oceanengineEvent(params);
        }
      }
    }
  }

  /**
   * 头条SDK回传
   */
  static void oceanengineEvent(Map<String, dynamic> params) async {
    String url;
    try {
      String jsonString = jsonEncode(params);
      if (ByPackageUtils.isAndroid || ByPackageUtils.isOhos) {
        ChannelOperate.oceanengineEvent(jsonString);
      } else {
        /// 这里处理 抖音 ios归因 上传事件的逻辑
        douYinEvent(jsonParams: jsonString);
      }
      url = APIs.oceanengineSuccess;
    } catch (e) {
      url = APIs.oceanengineFail;
    }
    HttpUtils.post(
      url,
      params,
      success: (data) {},
      fail: (code, msg) {},
    );
  }

  ///抖音sdk回传事件
  static void douYinEvent({
    required String jsonParams,
  }) {
    log("===抖音事件上报===  服务下发的参数 $jsonParams");
    try{
      final event = json.decode(jsonParams) as Map<String, dynamic>;
      final e = event['event'].toString();
      String _auto_id_ = "";
      if (event.containsKey("_auto_id_")) {
        _auto_id_ = event["_auto_id_"].toString();
        event.remove('_auto_id_');
      }
      if (e == "register") {
        log("===抖音 注册事件上报===");
        // BdaSignal.trackRegister(null); // 依赖 bda_signal，鸿蒙/安卓未使用
      } else if (e == "purchase") {
        final money = event['money'];
        final intMoney = (money is num ? money * 100 : 0).toInt();
        log("===抖音 付费事件上报=== $intMoney");
        // BdaSignal.trackPay(...); // 依赖 bda_signal，鸿蒙/安卓未使用
      } else if (e == 'game_addiction') {
        log("===抖音 自定义事件(game_addiction)上报===");
        // BdaSignal.trackEvent(...); // 依赖 bda_signal
      } else {
        try {
          event.remove('event');
          final eventStr = json.encode(event);
          log("===抖音 自定义事件2($eventStr)上报===");
          // BdaSignal.trackEvent(e, paramsObj); // 依赖 bda_signal
          if (kDebugMode) {
            print('iniBDConvert onEventV3: $e: $eventStr');
          }
        } catch (ex) {}
      }
    } catch (e){

    }
  }
}
