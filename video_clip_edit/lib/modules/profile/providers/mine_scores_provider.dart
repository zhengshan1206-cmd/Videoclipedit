import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/flavors/build_config.dart';
import 'package:video_clip_edit/modules/login/controller/login_manager.dart';
import 'package:video_clip_edit/modules/login/login_page.dart';
import 'package:video_clip_edit/modules/main/beans/launch_info_bean.dart';
import 'package:video_clip_edit/modules/profile/beans/mine_score_order_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/ali_pay_order_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/wx_pay_order_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/wx_yeepay_order_bean.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/channel/channel_config.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:video_clip_edit/modules/profile/beans/mine_score_happys_bean.dart';
import 'package:video_clip_edit/modules/profile/beans/mine_score_record_bean.dart';
import 'package:video_clip_edit/modules/profile/beans/mine_scores_info_bean.dart';
import 'package:video_clip_edit/modules/profile/providers/third_platform_pay_mixin.dart';

import '../../login/login_page_ex.dart';

class MineScoresProvider extends ThirdPlatformPayMixin {
  int scores = 0;
  updateScores(int score) {
    scores = score;
    notifyListeners();
  }

  int selectedHappyIndex = -1;
  udateSelectedHappyIndex(int index) {
    selectedHappyIndex = index;
    notifyListeners();
  }

  int selectedPayMethodIndex = -1;
  udateSelectedPayMethodIndex(int index) {
    selectedPayMethodIndex = index;
    notifyListeners();
  }

  MineScoreHappysBean? scoreHappysBean;
  updateMineScoreHappysBean(MineScoreHappysBean bean) {
    scoreHappysBean = bean;
    notifyListeners();
  }

  loadScoreHappys() {
    HttpUtils.get(
      APIs.scoreHappys,
      {},
      success: (data) {
        final beanData = data["data"];
        MineScoreHappysBean bean = MineScoreHappysBean.fromJson(beanData);
        if (bean.items.isNotEmpty) {
          selectedHappyIndex = 0;
        }
        updateMineScoreHappysBean(bean);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  MineScoresInfoBean? scoresInfoBean;
  updateMineScoresInfoBean(MineScoresInfoBean bean) {
    scoresInfoBean = bean;
    notifyListeners();
  }

  loadScoresInfo() {
    HttpUtils.get(
      APIs.scoresInfo,
      {},
      success: (data) {
        final beanData = data["data"];
        MineScoresInfoBean bean = MineScoresInfoBean.fromJson(beanData);
        updateMineScoresInfoBean(bean);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  List<MineScoreRecordBean> scoreBeans = [];
  updateMineScoreRecordBeans(List<MineScoreRecordBean> beans) {
    scoreBeans = beans;
    notifyListeners();
  }

  int scoreRequestCount = 0;
  int scorePage = 1;
  int scorePageSized = 10;
  loadScoresRecords({
    bool reset = false,
    required EasyRefreshController controller,
  }) {
    if (reset) {
      scorePage = 1;
      scoreBeans.clear();
    }
    HttpUtils.get(
      APIs.scoreRecords,
      {
        "page": scorePage,
        "size": scorePageSized,
      },
      success: (data) {
        final items = data["data"]["items"] ?? [];
        scoreRequestCount++;
        List<MineScoreRecordBean> beans = List<MineScoreRecordBean>.from(
          items.map(
            (ele) => MineScoreRecordBean.fromJson(ele),
          ),
        );
        final results = List<MineScoreRecordBean>.from(scoreBeans);
        scorePage = results.addElementsByRemovingLast(
          beans,
          currentPage: scorePage,
          pageSize: scorePageSized,
        );
        updateMineScoreRecordBeans(results);
        if (reset) {
          controller.finishRefresh();
          controller.resetFooter();
        } else {
          controller.finishLoad(
            (beans.isNotEmpty && beans.length % 10 == 0)
                ? IndicatorResult.success
                : IndicatorResult.noMore,
          );
        }
      },
      fail: (code, msg) {
        controller.finishLoad();
        BotToast.showText(text: msg);
      },
    );
  }

  String orderID = "";
  String paymethods = "";
  createOrder({
    required BuildContext context,
    // iOS支付的票据信息
    String? receiptData,
    void Function(dynamic payOrderBean)? onSuccess,
  }) {
    if (selectedHappyIndex == -1) {
      BotToast.showText(text: "请选择积分套餐");
      return;
    }
    if (paymethods.isEmpty || selectedHappyIndex == -1) {
      BotToast.showText(text: "请选择支付方式");
      return;
    }

    if (_canCreateOrder(context) == false) return;
    EasyLoading.show();
    HttpUtils.post(
      APIs.createOrder,
      {
        "pay": paymethods,
        "config_id": scoreHappysBean!.items[selectedHappyIndex].id
      },
      success: (data) {
        EasyLoading.dismiss();
        final beanData = data["data"];
        MineScoreOrderBean bean = MineScoreOrderBean.fromJson(beanData);
        if (bean.pay == "wxpay") {
          WxPayOrderBean payOrderBean = WxPayOrderBean.fromJson(beanData);
          onSuccess?.call(payOrderBean);
          orderID = payOrderBean.id;
          // wxPay(payOrderBean);
        } else if (bean.pay == "yeepay") {
          YeepayPayOrderBean payOrderBean =
              YeepayPayOrderBean.fromJson(data["data"]);
          onSuccess?.call(payOrderBean);
          orderID = payOrderBean.id;
          // wxMiniProgramPay(payOrderBean);
        } else {
          AliPayOrderBean aliPayOrderBean = AliPayOrderBean.fromJson(beanData);
          onSuccess?.call(aliPayOrderBean);
          orderID = aliPayOrderBean.id;
          // aliPay(aliPayOrderBean);
        }
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
        BotToast.showText(text: msg);
      },
    );
  }

  /// 是否允许创建订单
  bool _canCreateOrder(BuildContext context) {
    var value = false;
    LaunchInfoBean? launchInfoBean = context.read<LaunchProvider>().launchInfo;

    if (launchInfoBean?.isVip == 0) {
      if (launchInfoBean?.isFormal == 1) {
        value = true;
      } else {
        /// 游客
        if (launchInfoBean?.verConfig.allowTouristsVip == 1) {
          /// 支付界面
          value = true;
        } else {
          /// 登陆界面
          value = false;
        }
      }
    } else {
      value = true;
    }
    // final purchaseProvider = context.read<PurchaseProvider>();
    if (!value) {
      ///显示登录页面
      LoginManager.showLoginPage();
    }
    return value;
  }

  bool loading = false;
  querryOrderStatus({
    CancelToken? cancelToken,
    void Function()? onSuccess,
    void Function(CancelToken cancelToken)? onFaild,
    bool checkStatus = true,
  }) {
    if (loading) {
      return;
    }
    loading = true;
    HttpUtils.get(
      APIs.queryOrder,
      {"id": orderID},
      cancelToken: cancelToken,
      success: (data) {
        loading = false;
        final status = data["status"] ?? -1;
        if (status != 200) {
          final token = CancelToken();
          onFaild?.call(token);
        } else {
          final status = data["data"]["order_status"] ?? "";
          if (status == "PAYINE") {
            final token = CancelToken();
            onFaild?.call(token);
            return;
          } else if (status == "SUCCESS") {
            onSuccess?.call();
          } else {}
        }
      },
      fail: (code, msg) {
        loading = false;
        BotToast.showText(text: msg);
        // final token = CancelToken();
        // onFaild?.call(token);
      },
    );
  }
}
