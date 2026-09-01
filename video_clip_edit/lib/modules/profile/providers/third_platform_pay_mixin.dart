import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:wechat_kit/wechat_kit.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:alipay_kit/alipay_kit_platform_interface.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/modules/purchase/beans/wx_pay_order_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/ali_pay_order_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/wx_yeepay_order_bean.dart';

class ThirdPlatformPayMixin extends BaseProvider {
  /// 微信支付
  wxPay(WxPayOrderBean payOrderBean) {
    WechatKitPlatform.instance.pay(
      appId: payOrderBean.info.appid,
      partnerId: payOrderBean.info.partnerid,
      prepayId: payOrderBean.info.prepayid,
      package: payOrderBean.info.package,
      nonceStr: payOrderBean.info.noncestr,
      timeStamp: payOrderBean.info.timestamp,
      sign: payOrderBean.info.sign,
    );
  }

  /// 易宝微信小程序支付
  wxMiniProgramPay(YeepayPayOrderBean payOrderBean) {
    WechatKitPlatform.instance.launchMiniProgram(
      userName: payOrderBean.info.miniProgramOrgId,
      type: WechatMiniProgram.kRelease,
      path: payOrderBean.info.prePayTn,
    );
  }

  /// 支付宝支付
  aliPay(AliPayOrderBean payOrderBean) {
    AlipayKitPlatform.instance.pay(
      orderInfo: payOrderBean.info.orderInfo,
      isShowLoading: payOrderBean.info.isShowPayLoading,
    );
  }

  /// 订阅微信支付
  StreamSubscription<WechatResp>? _respSubs;
  StreamSubscription<AlipayResp>? _alipaySubs;
  WechatPayResp? payResp;
  AlipayResp? alipayResp;

  void subscribeWXPayResp(
    BuildContext context, {
    void Function()? onSuccess,
  }) {
    byDebugPrint("----subscribeWXPayResp", tag: "注册订阅:");
    _respSubs?.cancel();
    _respSubs = WechatKitPlatform.instance.respStream().listen(
      (resp) {
        final provider = context.read<PurchaseProvider>();
        provider.needShowDialog = false;
        if (resp is WechatPayResp) {
          payResp = resp;
          byDebugPrint("response: ${resp.toJson()}");
          if (resp.isSuccessful) {
            onSuccess?.call();
            BotToast.showText(text: "微信支付成功");
          } else {
            EasyLoading.dismiss();
            BotToast.showText(text: "微信支付失败");
          }
        } else if (resp is WechatLaunchMiniProgramResp) {
          /**
           * 由于易宝微信小程序取消支付后，返回的数据如下，
           * 【"isCancelled": false,"isSuccessful": true,】
              WechatLaunchMiniProgramResp ({
              "errorCode": 0,
              "errorMsg": null,
              "extMsg": "status=cancel",
              "isCancelled": false,
              "isSuccessful": true,
              })
           * 支付成功后的数据为：
           * 【"isCancelled": false,"isSuccessful": true,】
              WechatLaunchMiniProgramResp ({
              "errorCode": 0,
              "errorMsg": null,
              "extMsg": "status=success",
              "isCancelled": false,
              "isSuccessful": true,
              })
           * 无法通过 isSuccessful/isCancelled 的值来判断是否支付成功，
           * 暂时使用extMsg消息中包含 cancel 来判断是否取消支付
           * 暂时使用extMsg消息中包含 success 来判断是否取消支付
           */
          byDebugPrint("response111: ${resp.toJson()}");
          if ((resp.extMsg ?? "").toLowerCase().contains("cancel")) {
            EasyLoading.dismiss();
            BotToast.showText(text: "微信支付失败");
          } else if (resp.isSuccessful &&
              (resp.extMsg ?? "").toLowerCase().contains("success")) {
            onSuccess?.call();
            BotToast.showText(text: "微信支付成功");
          } else {
            EasyLoading.dismiss();
            BotToast.showText(text: "微信支付失败");
          }
        }
      },
      onError: (e) {
        byDebugPrint("登陆失败：$e");
        EasyLoading.dismiss();
      },
      onDone: () {
        EasyLoading.dismiss();
      },
      cancelOnError: true,
    );
  }

  void subscribeAliPayResp(
    BuildContext context, {
    void Function()? onSuccess,
  }) {
    byDebugPrint("----subscribeAliPayResp", tag: "注册订阅:");
    _alipaySubs?.cancel();
    _alipaySubs = AlipayKitPlatform.instance.payResp().listen(
      (resp) {
        alipayResp = resp;
        byDebugPrint("response: ${resp.toJson()}");

        if (resp.isSuccessful) {
          onSuccess?.call();
          BotToast.showText(text: "支付宝支付成功");
        } else {
          EasyLoading.dismiss();
          BotToast.showText(text: "支付宝支付失败");
        }
      },
      onError: (e) {
        byDebugPrint("登陆失败：$e");
        EasyLoading.dismiss();
      },
      onDone: () {
        EasyLoading.dismiss();
      },
    );
  }

  /// 取消订阅微信支付
  void cancelSubscribeWXPayResp() {
    byDebugPrint("----cancelSubscribeWXPayResp", tag: "取消订阅:");
    _respSubs?.cancel();
    _respSubs = null;
  }

  /// 取消订阅支付宝支付
  void cancelSubscribeAliPayResp() {
    byDebugPrint("----cancelSubscribeAliPayResp", tag: "取消订阅:");
    _alipaySubs?.cancel();
    _alipaySubs = null;
  }
}
