import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bda_signal/bda_signal.dart';
import 'package:flutter/foundation.dart';
import 'package:video_clip_edit/utils/channel/channel_operate.dart';
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
    if (Platform.isAndroid) {
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
      if (Platform.isAndroid) {
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
        //注册
        //内置事件: “注册” ，属性：注册方式，是否成功，属性值为：wechat ，true
        String way = event["way"]; //登陆方式(wechat 微信,phone 手机)
        log("===抖音 注册事件上报===");
        BdaSignal.trackRegister(null);
      } else if (e == "purchase") {
        // 付费
        // 内置事件 “支付”，属性：商品类型，商品名称，商品 ID，商品数量，支付渠道，币种，是否成功（必传），金额（必传）
        // 付费金额单位为元
        final goodType = event['good_type'] ;
        final goodName = event['good_name'] ;
        final goodId = event['good_id'] ;
        final goodNum = event['good_num'];
        final payType = event['pay_type'] ;
        final currency = event['currency'] ;
        final money = event['money'];
        final intMoney = (money*100).toInt();
        log("===抖音 付费事件上报=== ${intMoney}");
        BdaSignal.trackPay({
          // "good_type": goodType,
          // "good_name": goodName,
          // "good_id":goodId,
          // "good_num":goodNum,
          // "pay_type":payType,
          // "currency":currency,
          // "money":intMoney,
          "pay_amount":intMoney,
        });
      } else if(e == 'game_addiction'){
        log("===抖音 自定义事件(game_addiction)上报===");
        // 关键行为
        final paramsObj = <String, dynamic>{};
        try {
          final originEvent = event['origin_event'];
          paramsObj['origin_event'] = originEvent; // 添加原始事件名称参数
        } catch (ex) {}
        BdaSignal.trackEvent("game_addiction", paramsObj);
      } else{
        try {
          event.remove('event');
          final eventStr = json.encode(event);
          final paramsObj = json.decode(eventStr) as Map<String, dynamic>;
          log("===抖音 自定义事件2($eventStr)上报===");
          BdaSignal.trackEvent(e, paramsObj);
          if (kDebugMode) {
            print('iniBDConvert onEventV3: $e: $eventStr');
          }
        } catch (ex) {}
      }
    } catch (e){

    }
  }
}
