import 'dart:io';
import 'dart:async';

import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/purchase/beans/integral_pay_list_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/pay/ios_buy_engine.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:wechat_kit/wechat_kit.dart';
import 'package:video_clip_edit/modules/purchase/beans/wx_pay_order_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/wx_yeepay_order_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/ali_pay_order_bean.dart';
import 'package:alipay_kit/alipay_kit_platform_interface.dart';
import 'package:video_clip_edit/modules/profile/providers/third_platform_pay_mixin.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';

import '../widgets/toast_util.dart';

class IntegralPayProvider extends ThirdPlatformPayMixin {
  integralinit() {
    // 初始化支付方式
    if (Platform.isAndroid || ByPackageUtils.isOhos) {
      currentPayMethod = "wxpay";
    } else {
      currentPayMethod = "applepay";
    }

    // 加载积分套餐列表
    loadScoreHappys();
  }

  //积分套餐列表
  List<IntegralPayListBean> integralRecords = [];

  //选中的索引
  int selectedIndex = 0;

  //支付支持
  String paySupport =
      (Platform.isAndroid || ByPackageUtils.isOhos)
          ? "wxpay,alipay,yeepay"
          : "applepay";

  //接口下发支持支付
  Map<String, dynamic>? _integralPays;

  //当前选中的支付方式
  String currentPayMethod = "wxpay";

  //可用的支付方式列表
  List<String> availablePayMethods = [];

  /// 用户协议默认
  bool userAgreementChecked = false;

  ///是否默认同意协议 is_Agreement1是2否
  bool isAgreementChecked = true;

  ///当前下发vip协议是否选中
  bool agreementNum = true;

  //接口下发按钮文案
  String memberBtnTxt = "立即购买";

  //积分协议
  String? integralIllustrate;

  ///当前订单Id
  String orderId = "";

  ///是否需要弹窗提示支付状态
  bool needShowDialog = false;

  ///Ios支付工具
  IosBuyEngin iosBuyEngin = IosBuyEngin();

  /// 是否正在查询订单
  bool _isQueryingOrder = false;

  //获取积分套餐列表
  void loadScoreHappys() {
    HttpUtils.get(
      APIs.scoreHappys,
      {"ver": 2, "support_pays": paySupport},
      success: (data) {
        byDebugPrint(data, tag: "----11111111111111111");
        final List items = data["data"]["items"] ?? [];
        if (items.isEmpty) {
          BotToast.showText(text: "暂无可用的积分套餐");
          return;
        }
        final List<IntegralPayListBean> records = items
            .map((ele) => IntegralPayListBean.fromJson(ele))
            .toList();
        integralIllustrate = data["data"]["integral_illustrate"] ?? "";
        if (integralIllustrate!.isEmpty) {
          // BotToast.showText(text: "获取协议链接失败");
        }
        integralRecords = records;

        // 处理支付方式
        if (Platform.isAndroid || ByPackageUtils.isOhos) {
          _integralPays = data["data"]["pays"];
          availablePayMethods.clear();
          _integralPays!.forEach((key, value) {
            if (value == 1) {
              if (key == "wxpay" || key == "yeepay") {
                // 如果已经有微信支付了，就不再添加
                if (!availablePayMethods.contains("wxpay")) {
                  availablePayMethods.add("wxpay");
                }
              } else if (key == "alipay") {
                availablePayMethods.add("alipay");
              }
            }
          });

          // 设置默认支付方式
          if (availablePayMethods.isNotEmpty) {
            currentPayMethod = availablePayMethods.first;
          }
        }

        if (integralRecords.isNotEmpty) {
          getAgreement(selectedIndex);
          validateMemberBtnTxt(integralRecords[selectedIndex].buttonTitle);
        }
        notifyListeners();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  //套餐点击
  void integralItemClick(IntegralPayListBean item) {
    if (integralRecords.isEmpty) return;
    selectedIndex = integralRecords.indexOf(item);
    getAgreement(selectedIndex);
    validateMemberBtnTxt(integralRecords[selectedIndex].buttonTitle);
    notifyListeners();
  }

  //按钮文案
  validateMemberBtnTxt(String? input) {
    if (integralRecords.isEmpty) return;
    if (input?.isNotEmpty ?? false) {
      memberBtnTxt = integralRecords[selectedIndex].buttonTitle;
    } else {
      memberBtnTxt = "立即购买";
    }
    notifyListeners();
  }

  agreementCheckedStatusChanged(bool status) {
    userAgreementChecked = status;
    isAgreementChecked = status;
    notifyListeners();
  }

  //判断当前选中套餐是否展示同意协议
  void getAgreement(int index) {
    if (integralRecords.isEmpty) return;
    if (integralRecords[index].isAgreement == 1 || userAgreementChecked) {
      isAgreementChecked = true;
    } else {
      isAgreementChecked = false;
    }
    agreementNum = integralRecords[index].isAgreement == 1 ? true : false;
    notifyListeners();
  }

  //切换支付方式
  void switchPayMethod() {
    if (availablePayMethods.length <= 1) {
      return;
    }
    // 获取当前支付方式在列表中的索引
    int currentIndex = availablePayMethods.indexOf(currentPayMethod);
    // 计算下一个索引，如果是最后一个则回到第一个
    int nextIndex = (currentIndex + 1) % availablePayMethods.length;
    // 更新当前支付方式
    currentPayMethod = availablePayMethods[nextIndex];
    notifyListeners();
  }

  //创建支付订单v2版本  createOrderv2
  void createPayOrderV2() {
    EasyLoading.show();
    HttpUtils.post(
      APIs.createOrderv2,
      {
        "pay": (Platform.isAndroid || ByPackageUtils.isOhos) ? currentPayMethod : "apple",
        "config_id": integralRecords[selectedIndex].id,
        "support_pays": (Platform.isAndroid || ByPackageUtils.isOhos) ? "wxpay,alipay,yeepay" : "apple",
      },
      success: (data) {
        EasyLoading.dismiss();
        byDebugPrint(data["data"], tag: "创建支付订单:");
        orderId = data["data"]["id"];
        //拉起支付
        pullUpPayment(data["data"]);
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  // 分平台拉起支付
  pullUpPayment(data) async {
    if (Platform.isAndroid || ByPackageUtils.isOhos) {
      if (data["call_method"] == "wxpay") {
        //微信支付
        bool canWechatPay = await WechatKitPlatform.instance.isInstalled();
        if (!canWechatPay) {
          EasyLoading.showToast("由于您未安装微信，无法完成支付。请切换其他方式支付");
          return;
        }
        WxPayOrderBean payOrderBean = WxPayOrderBean.fromJson(data);
        wxPay(payOrderBean);
      } else if (data["call_method"] == "wxpay_mini") {
        //易宝微信支付
        bool canWechatPay = await WechatKitPlatform.instance.isInstalled();
        if (!canWechatPay) {
          EasyLoading.showToast("由于您未安装微信，无法完成支付。请切换其他方式支付");
          return;
        }
        YeepayPayOrderBean payOrderBean = YeepayPayOrderBean.fromJson(data);
        needShowDialog = true;
        wxMiniProgramPay(payOrderBean);
      } else if (data["call_method"] == "alipay") {
        //支付宝支付
        bool canAliPay = await AlipayKitPlatform.instance.isInstalled();
        if (!canAliPay) {
          EasyLoading.showToast("由于您未安装支付宝，无法完成支付。请切换其他方式支付");
          return;
        }
        AliPayOrderBean aliPayOrderBean = AliPayOrderBean.fromJson(data);
        aliPay(aliPayOrderBean);
      }
    } else if (Platform.isIOS) {
      // 苹果支付
      buyIosProductData(orderId);
    }
  }

  ///购买ios产品
  buyIosProductData(String orderId) async {
    if (integralRecords[selectedIndex].appleVipId.isEmpty) {
      BotToast.showText(text: "未查找到商品，请重试");
    }
    await iosBuyEngin.loadProductDataAndBuy(
      integralRecords[selectedIndex].appleVipId,
      orderId,
    );
  }

  ///ios补单
  void iosRepair({void Function()? onSuccess}) {
    EasyLoading.show();
    Get.log("===点击恢复购买");
    String receiptData = SpUtil.getString("ios_last_server_verification") ?? "";
    HttpUtils.post(
      APIs.iosRepair,
      {"receipt_data": receiptData},
      success: (json) {
        EasyLoading.dismiss();
        Get.log("===ios补单返回来的数据===  $json");
        onSuccess?.call();
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  // 查询积分订单状态
  void integralQueryOrder({
    void Function()? onSuccess,
    void Function()? onFailed,
    int retryCount = 0,
    String receiptData = "",
  }) {
    if (_isQueryingOrder) {
      return;
    }

    if (retryCount > 2) {
      _isQueryingOrder = false;
      onFailed?.call();
      return;
    }

    if (receiptData.isEmpty && Platform.isIOS || orderId.isEmpty) {
      return;
    }

    _isQueryingOrder = true;
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..maskType = EasyLoadingMaskType.custom
      ..indicatorType = EasyLoadingIndicatorType.cubeGrid
      ..indicatorColor = ByColorUtil.PurchasePriceTextColor
      ..loadingStyle = EasyLoadingStyle.light;
    EasyLoading.show(status: "订单查询中，请稍后...", dismissOnTap: false);

    HttpUtils.post(
      APIs.queryOrder,
      {"id": orderId, "receipt_data": (Platform.isAndroid || ByPackageUtils.isOhos) ? "" : receiptData},
      success: (data) {
        byDebugPrint(data["data"], tag: "订单状态:");
        final status = data["data"]["order_status"] ?? "";
        if (status == 'SUCCESS') {
          EasyLoading.dismiss();
          _isQueryingOrder = false;

          /// 更新个人信息
          Get.find<UserController>().reloadUserInfo(
            successAction: (userInfo) {},
          );
          eventBus.fire(const IosProductBuySuccessEvent());
          onSuccess?.call();
        } else if (status == 'FAIL') {
          EasyLoading.dismiss();
          _isQueryingOrder = false;
          ToastUtil().showToast("支付失败");
          onFailed?.call();
        } else {
          Future.delayed(const Duration(seconds: 3)).then(
            (value) => integralQueryOrder(
              onSuccess: onSuccess,
              onFailed: onFailed,
              retryCount: retryCount + 1,
            ),
          );
        }
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
        _isQueryingOrder = false;
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }
}
