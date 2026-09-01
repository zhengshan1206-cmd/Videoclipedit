import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/core/network/provider/user_provider.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/flavors/build_config.dart';
import 'package:video_clip_edit/modules/login/controller/login_manager.dart';
import 'package:video_clip_edit/modules/login/login_page_ex.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/pre_login_config_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/wx_yeepay_order_bean.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/modules/purchase/beans/config_bean.dart';
import 'package:video_clip_edit/modules/main/beans/launch_info_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_page_bean.dart';
import 'package:video_clip_edit/modules/home/beans/home_banner_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_type_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/pay_method_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_special_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/wx_pay_order_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/ali_pay_order_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/purchase_function_bean.dart';
import 'package:video_clip_edit/modules/profile/providers/third_platform_pay_mixin.dart';
import 'package:video_clip_edit/v2/business/get_red_envelope_dialog.dart';
import 'package:wechat_kit/wechat_kit.dart';

import '../generated/assets.dart';
import '../modules/home/widgets/sub_funcs_view.dart';
import '../modules/purchase/beans/purchase_vip_benefits_bean.dart';
import '../utils/consts/const.dart';
import '../utils/pay/ios_buy_engine.dart';
import '../v2/aiSquare/widgets/ai_video_player.dart';
import '../widgets/toast_util.dart';
import 'package:video_clip_edit/modules/purchase/beans/pop_config_bean.dart';
import '../modules/purchase/mixins/purchase_page_top_mixin.dart';

enum PurchaseType { type1, type2 }

enum PayType { wxpay, yeepay, alipay }

extension PayTypeExt on PayType {
  String get payTypeName {
    switch (this) {
      case PayType.alipay:
        return "alipay";
      case PayType.yeepay:
        return "yeepay";
      default:
        return "wxpay";
    }
  }

  int get rawValue {
    switch (this) {
      case PayType.yeepay:
        return 2;
      case PayType.alipay:
        return 1;
      default:
        return 0;
    }
  }

  static PayType typeFromPayTypeNameValue(String val) {
    switch (val) {
      case "wxpay":
        return PayType.wxpay;
      case "yeepay":
        return PayType.yeepay;
      default:
        return PayType.alipay;
    }
  }
}

class PurchaseProvider extends ThirdPlatformPayMixin with PurchasePageTopMixin {
  PurchaseType type;

  Function? paySuccess;

  ///当前轮播循环的index
  int loopIndex = 0;

  ///金刚卫
  List<SubFunction> menuItemBeans2 = [];

  ///banner
  List<SubFunction> menuItemBeans = [];

  ///支付后跳转链接
  String payJumpUrl = "";

  ///支付后弹窗倒计时
  int payJumpCountdown = 0;

  ///支付后弹窗图片
  String payJumpImage = "";

  final UserController controller = Get.find<UserController>();

  changeSelectedIndex(int idx) {
    for (var i = 0; i < functionBeansDark.length; i++) {
      final bean = functionBeansDark[i];
      bean.selected = (idx == i);
    }
    notifyListeners();
  }

  List<HomeBannerBean> bannerBeans = [
    HomeBannerBean.fromJson({
      "id": 1,
      "title": "",
      "img_url": "assets/purchase/vip_banner_1.svga",
      "jump_url": "",
      "jump_param": "",
      "type": 1,
      "des": "",
    }),
    HomeBannerBean.fromJson({
      "id": 1,
      "title": "",
      "img_url": "assets/purchase/vip_banner_2.svga",
      "jump_url": "",
      "jump_param": "",
      "type": 1,
      "des": "",
    }),
    HomeBannerBean.fromJson({
      "id": 1,
      "title": "",
      "img_url": "assets/purchase/vip_banner_3.svga",
      "jump_url": "",
      "jump_param": "",
      "type": 1,
      "des": "",
    }),
    HomeBannerBean.fromJson({
      "id": 1,
      "title": "",
      "img_url": "assets/purchase/vip_banner_4.svga",
      "jump_url": "",
      "jump_param": "",
      "type": 1,
      "des": "",
    }),
  ];

  List<HomeBannerBean> bannerBeansDark = [
    HomeBannerBean.fromJson({
      "id": 1,
      "title": "",
      "img_url": "assets/purchase/banner_dark_tweets.png",
      "jump_url": "",
      "jump_param": "",
      "type": 1,
      "des": "",
    }),
    HomeBannerBean.fromJson({
      "id": 1,
      "title": "",
      "img_url": "assets/purchase/banner_dark_clip.png",
      "jump_url": "",
      "jump_param": "",
      "type": 1,
      "des": "",
    }),
    HomeBannerBean.fromJson({
      "id": 1,
      "title": "",
      "img_url": "assets/purchase/banner_dark_show.png",
      "jump_url": "",
      "jump_param": "",
      "type": 1,
      "des": "",
    }),
    HomeBannerBean.fromJson({
      "id": 1,
      "title": "",
      "img_url": "assets/purchase/banner_dark_auth.png",
      "jump_url": "",
      "jump_param": "",
      "type": 1,
      "des": "",
    }),
    HomeBannerBean.fromJson({
      "id": 1,
      "title": "",
      "img_url": "assets/purchase/banner_dark_extract.png",
      "jump_url": "",
      "jump_param": "",
      "type": 1,
      "des": "",
    }),
  ];

  List<PurchaseFunctionBean> functionBeansDark = [
    PurchaseFunctionBean.fromJson({
      "icon": "assets/purchase/dark/icon_clip_dark.png",
      "name": "漫画推文",
      "isNew": true,
      "selected": true,
    }),
    PurchaseFunctionBean.fromJson({
      "icon": "assets/purchase/dark/icon_show_dark.png",
      "name": "智能混剪",
      "isNew": false,
      "selected": false,
    }),
    PurchaseFunctionBean.fromJson({
      "icon": "assets/purchase/dark/icon_duplicate.dark.png",
      "name": "短剧解说",
      "isNew": false,
      "selected": false,
    }),
    PurchaseFunctionBean.fromJson({
      "icon": "assets/purchase/dark/icon_watermark_dark.png",
      "name": "内容授权",
      "isNew": false,
      "selected": false,
    }),
    PurchaseFunctionBean.fromJson({
      "icon": "assets/purchase/dark/icon_ex_dark.png",
      "name": "一键提取",
      "isNew": false,
      "selected": false,
    }),
  ];
  updateFunctionBeansDark(List<PurchaseFunctionBean> beans) {
    functionBeansDark = beans;
    notifyListeners();
  }

  String eventFunction;
  String pagePath;
  String prePagePath;

  /// 是否是半弹窗付费页
  bool isHalfScreen = false;

  PurchaseProvider({
    this.type = PurchaseType.type1,
    this.eventFunction = "",
    this.pagePath = "",
    this.prePagePath = "",
    this.isHalfScreen = false,
  });

  List<PurchaseFunctionBean> functionBeans = [
    PurchaseFunctionBean.fromJson({
      "icon": "assets/purchase/icon_generated_interpretation.png",
      "name": "自动生成解说",
      "isNew": true,
    }),
    PurchaseFunctionBean.fromJson({
      "icon": "assets/purchase/icon_algorithm_duplicate_removal.png",
      "name": "独家算法去重",
      "isNew": false,
    }),
    PurchaseFunctionBean.fromJson({
      "icon": "assets/purchase/icon_hit_skits.png",
      "name": "爆款短剧授权",
      "isNew": false,
    }),
    PurchaseFunctionBean.fromJson({
      "icon": "assets/purchase/icon_popular_dubbing.png",
      "name": "热门配音任选",
      "isNew": false,
    }),
    PurchaseFunctionBean.fromJson({
      "icon": "assets/purchase/icon_links_extraction.png",
      "name": "链接一键提取",
      "isNew": false,
    }),
    PurchaseFunctionBean.fromJson({
      "icon": "assets/purchase/icon_watermark_erase.png",
      "name": "一键去水印",
      "isNew": true,
    }),
    PurchaseFunctionBean.fromJson({
      "icon": "assets/purchase/icon_original_copy.png",
      "name": "原创文案改写",
      "isNew": false,
    }),
    PurchaseFunctionBean.fromJson({
      "icon": "assets/purchase/icon_unlimited_use.png",
      "name": "功能无限使用",
      "isNew": false,
    }),
  ];

  VipSpecialBean? vipSpecialBean;
  List<VipTypeBean> vipTypeBeans = [];

  int selectedVIPTypeIndex = 0;

  String premiumTips = '';

  String submitText = '立即解锁';

  changeSelectedVipTypeIndex(int index) {
    // 检查索引是否有效
    if (index < 0 || index >= vipTypeBeans.length) {
      return;
    }

    reportPayPageTopInfo(
      "member_page",
      vipPageTopDataList.isNotEmpty ? vipPageTopDataList.first : null,
      "click",
      vipId: vipTypeBeans[index].id.toString(),
      isHalfScreen: isHalfScreen,
    );
    selectedVIPTypeIndex = index;
    // submitText = vipTypeBeans[index].isPremiumMember() ? '一次付费终身试用' : '立即解锁';
    // premiumTips = vipTypeBeans[index].isPremiumMember()
    //     ? '一次性购买，永久使用，不会自动续费'
    //     : '一次性购买，不会自动续费';

    premiumTips = vipTypeBeans[index].des;
    isShowIntegralAgreement = vipTypeBeans[index].integral > 0 ? true : false;

    // 根据审核状态和归因用户状态设置协议状态
    if (isAudit == 1) {
      // 审核状态：无论什么状态都不勾选协议
      isAgreementChecked = false;
      agreementNum = false; //为 true 表示隐藏勾选框，为 false 表示显示勾选框
      // 保持 agreementNum 的值（根据服务器返回的 isAgreement 决定是否显示勾选框）
      // agreementNum = vipTypeBeans[index].isAgreement == 1 ? true : false;
    } else {
      // 非审核状态：Android普通支付
      // 最近48小时内有检测链接的用户：显示无勾选的协议（agreementNum = true），但默认同意协议（内部状态为true）
      if (isNewAttributionUser == 1) {
        isAgreementChecked = true;
        // 强制设置 agreementNum 为 true，不显示勾选框
        agreementNum = true;
      } else {
        isAgreementChecked = false;
        agreementNum = false;
        // // 最近48小时内无检测链接用户：保持服务器返回的值
        // if (vipTypeBeans[index].isAgreement == 1 || userAgreementChecked) {
        //   isAgreementChecked = true;
        // } else {
        //   isAgreementChecked = false;
        // }
        // agreementNum = vipTypeBeans[index].isAgreement == 1 ? true : false;
      }
    }

    ///判断选中会员列表按钮文案
    if (validateMemberBtnTxt(vipTypeBeans[index].buttonTitle)) {
      memberBtnTxt = vipTypeBeans[index].buttonTitle;
    } else {
      memberBtnTxt = "立即解锁";
    }
    notifyListeners();
  }

  List<PayMethodBean> payMethodBeans = [];

  int selectedPayMethodIndex = 0;

  changeSelectedPayMethodIndex(int index) {
    selectedPayMethodIndex = index;
    notifyListeners();
  }

  bool agreementChecked = true;

  /// 用户协议默认
  bool userAgreementChecked = false;

  ///是否默认同意协议 is_Agreement1是2否
  bool isAgreementChecked = true;

  ///当前下发vip协议是否选中
  bool agreementNum = true;

  ///是否前置登录
  bool isPreLogin = false;

  ///是否前置登录
  String memberBtnTxt = "立即解锁";

  ///是否拦截返回
  bool isPreBack = false;

  ///积分模块展示是
  bool isIntegralOpen = false;

  ///是否展示积分服务协议
  bool isShowIntegralAgreement = false;

  //是否是挽留弹出拉起支付
  bool isRetention = false;

  ///是否是弹窗拉起支付
  bool isPopPay = false;

  bool validateMemberBtnTxt(String? input) {
    return input?.isNotEmpty ?? false;
  }

  agreementCheckedStatusChanged(bool status) {
    agreementChecked = status;
    userAgreementChecked = status;
    isAgreementChecked = status;
    notifyListeners();
  }

  /// 根据审核状态和归因用户状态初始化协议勾选状态
  void initAgreementStatus() {
    // 审核状态：无论什么状态都不勾选协议
    if (isAudit == 1) {
      agreementChecked = false;
      userAgreementChecked = false;
      isAgreementChecked = false;
      // 审核状态下，保持 agreementNum 的值（根据服务器返回的 isAgreement 决定是否显示勾选框）
    } else {
      // 非审核状态：Android普通支付
      // 最近48小时内有检测链接的用户：显示无勾选的协议（agreementNum = true），但默认同意协议（内部状态为true）
      if (isNewAttributionUser == 1) {
        agreementChecked = true;
        userAgreementChecked = true;
        isAgreementChecked = true;
        // 强制设置 agreementNum 为 true，不显示勾选框
        agreementNum = true;
      } else {
        // 最近48小时内无检测链接用户：保持现有逻辑（有勾选弹框的协议）
        // 这里不修改 agreementNum，保持服务器返回的值
      }
    }
    notifyListeners();
  }

  loadVIPItems({void Function()? onSuccess}) {
    print("loadVIPItems");
    HttpUtils.get(
      APIs.vipHappys,
      {"ver": 1},
      success: (data) {
        final respData = data["data"];
        byDebugPrint(respData, tag: "获取VIP权益：");
        final List items = respData["items"] ?? [];
        final windows = respData["windows"] ?? {};
        final Map<String, dynamic> pays = respData["pays"] ?? {};

        /// 支付列表
        /// 原生的微信支付
        final wxpayEnable = (pays["wxpay"] ?? 0) == 1;

        /// 易宝的微信小程序支付
        final yeepayEnable = (pays["yeepay"] ?? 0) == 1;
        payMethodBeans.clear();

        log("支付顺序===> ${pays}");

        ///替换支付顺序为服务器下发的顺序
        pays.forEach((e1, e2) {
          log("e1===>$e1  e2===>$e2");
          if (e2 == 1) {
            if (e1 == "wxpay") {
              payMethodBeans.add(
                PayMethodBean.fromJson({
                  "payName": "微信支付",
                  "icon": "assets/purchase/four/four-16.png",
                  "payNameKey": "wxpay",
                }),
              );
            } else if (e1 == "alipay") {
              payMethodBeans.add(
                PayMethodBean.fromJson({
                  "payName": "支付宝支付",
                  "icon": "assets/purchase/four/four-15.png",
                  "payNameKey": "alipay",
                }),
              );
            } else if (e1 == "yeepay") {
              payMethodBeans.add(
                PayMethodBean.fromJson({
                  "payName": "微信支付",
                  "icon": "assets/purchase/four/four-16.png",
                  "payNameKey": "yeepay",
                }),
              );
            }
          }
        });
        if (wxpayEnable && yeepayEnable) {
          payMethodBeans.removeWhere((e) {
            return e.payNameKey == "wxpay";
          });
        }

        // if(wxpayEnable){
        //   payMethodBeans.removeWhere((e){
        //     return e.payNameKey=="wxpay";
        //   });
        // }

        /// VIP类型
        List<VipTypeBean> typeBeans = items
            .map((e) => VipTypeBean.fromJson(e))
            .toList();
        vipTypeBeans = typeBeans;

        // if (vipTypeBeans.isNotEmpty) {
        //   submitText = vipTypeBeans[selectedVIPTypeIndex].isPremiumMember() ? '一次付费终身试用' : '立即解锁';
        // }
        // 挽留套餐以 firstPopConfig.vipInfo 为准，不再在此设置

        if (vipTypeBeans.isNotEmpty) {
          // premiumTips = vipTypeBeans[selectedVIPTypeIndex].isPremiumMember()
          //     ? '一次性购买，永久使用，不会自动续费'
          //     : '一次性购买，不会自动续费';
          premiumTips = vipTypeBeans[selectedVIPTypeIndex].des;
          isShowIntegralAgreement =
              vipTypeBeans[selectedVIPTypeIndex].integral > 0 ? true : false;
        }

        // if (vipTypeBeans[selectedVIPTypeIndex].isAgreement == 1) {
        //   isAgreementChecked = true;
        // } else {
        //   isAgreementChecked = false;
        // }
        // agreementNum =
        //     vipTypeBeans[selectedVIPTypeIndex].isAgreement == 1 ? true : false;
        // 根据审核状态和归因用户状态重新设置协议状态（覆盖服务器返回的值）
        if (isAudit == 1) {
          // 审核状态：无论什么状态都不勾选协议
          isAgreementChecked = false;
          // 保持 agreementNum 的值（根据服务器返回的 isAgreement 决定是否显示勾选框）
          agreementNum = vipTypeBeans[selectedVIPTypeIndex].isAgreement == 1
              ? true
              : false;
        } else {
          // 非审核状态：Android普通支付
          // 最近48小时内有检测链接的用户：显示无勾选的协议（agreementNum = true），但默认同意协议（内部状态为true）
          if (isNewAttributionUser == 1) {
            isAgreementChecked = true;
            // 强制设置 agreementNum 为 true，不显示勾选框
            agreementNum = true;
          } else {
            // 最近48小时内无检测链接用户：保持服务器返回的值
            if (vipTypeBeans[selectedVIPTypeIndex].isAgreement == 1) {
              isAgreementChecked = true;
            } else {
              isAgreementChecked = false;
            }
            agreementNum = vipTypeBeans[selectedVIPTypeIndex].isAgreement == 1
                ? true
                : false;
          }
        }

        ///判断选中会员列表按钮文案
        if (validateMemberBtnTxt(
          vipTypeBeans[selectedVIPTypeIndex].buttonTitle,
        )) {
          memberBtnTxt = vipTypeBeans[selectedVIPTypeIndex].buttonTitle;
        } else {
          memberBtnTxt = "立即解锁";
        }

        /// 终身VIP
        VipSpecialBean specialBean = VipSpecialBean.fromJson(windows);
        vipSpecialBean = specialBean;

        //
        // /// 原生的支付宝支付
        // final alipayEnable = (pays["alipay"] ?? 0) == 1;

        // if (alipayEnable) {
        //   payMethodBeans.add(PayMethodBean.fromJson({
        //     "payName": "支付宝支付",
        //     "icon": "assets/purchase/icon_zfb_dark.png",
        //     "payNameKey": "alipay",
        //   }));
        // }
        //
        // if (yeepayEnable) {
        //   payMethodBeans.add(PayMethodBean.fromJson({
        //     "payName": "微信支付",
        //     "icon": "assets/purchase/icon_wx_dark.png",
        //     "payNameKey": "yeepay",
        //   }));
        // } else if (wxpayEnable&&!yeepayEnable) {
        //   payMethodBeans.add(PayMethodBean.fromJson({
        //     "payName": "微信支付",
        //     "icon": "assets/purchase/icon_wx_dark.png",
        //     "payNameKey": "wxpay",
        //   }));
        // }
        notifyListeners();

        onSuccess?.call();

        /// 更新UI
        notifyListeners();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  /// 加载VIP页面数据
  loadVipData() {
    loadVIPItems();
    _loadVipPageData();
  }

  VipPageBean? vipPageBean;
  _loadVipPageData() {
    HttpUtils.get(
      APIs.vipPage,
      {},
      success: (json) {
        final data = json["data"];
        if (data == null) return;
        vipPageBean = VipPageBean.fromJson(data);
        notifyListeners();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  _fetchPayTypeID() {
    if (vipTypeBeans.isEmpty) {}
    return vipTypeBeans[selectedVIPTypeIndex].id.toString();
  }

  static String kGroupPay = "zhu_ye_yin_dao_tan_chuang";
  static String kKeyPay = "kai_guan";

  /// 获取vip弹窗配置
  checkShowVipDialogConfig({
    void Function(KaiGuanConfigBean configBean)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.getConfig,
      {"group": kGroupPay},
      success: (data) {
        log("KaiGuanConfigBean  data=====> ${data["data"]}    ");

        final config = data["data"];
        if (config == null || config is List) {
          return;
        }
        KaiGuanConfigBean configBean = KaiGuanConfigBean.fromJson(config);
        onSuccess?.call(configBean);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  String orderID = "";

  /// 创建微信支付的订单，获取商户信息
  createOrder({
    required BuildContext context,
    // iOS支付的票据信息
    String? receiptData,
    //是否时挽留弹出拉起支付
    bool retentionPop = false,
    // 是否是弹窗拉起
    bool popPay = false,
    void Function(dynamic payOrderBean)? onSuccess,
  }) {
    ///上报
    isPopPay = popPay;

    // 挽留弹窗支付时，使用 firstPopConfig 中的 VipInfo 套餐ID；普通支付使用用户选中的套餐ID
    final reportVipId = retentionPop
        ? retentionDefaultVipInfo?.id.toString()
        : (vipTypeBeans.isNotEmpty && selectedVIPTypeIndex < vipTypeBeans.length
              ? vipTypeBeans[selectedVIPTypeIndex].id.toString()
              : null);

    reportPayPageTopInfo(
      "member_page_initiate_payment",
      vipPageTopDataList.isNotEmpty ? vipPageTopDataList.first : null,
      "click",
      vipId: reportVipId,
      payType: popPay == true ? 2 : 1,
      isHalfScreen: isHalfScreen,
    );
    // if (canCreateOrder(context) == false) return;

    ///使用ByNavigatorUtil
    ByNavigatorUtil.checkLogin(
      context: context,
      nextStepEvent: () {
        isRetention = retentionPop;
        if (vipTypeBeans.isEmpty) {
          loadVIPItems(
            onSuccess: () {
              _startCreateOrder(onSuccess: onSuccess);
            },
          );
        } else {
          _startCreateOrder(onSuccess: onSuccess);
        }
      },
    );
  }

  ///是否需要弹窗提示支付状态
  var needShowDialog = false;

  void _startCreateOrder({
    void Function(dynamic payOrderBean)? onSuccess,
  }) async {
    final PayMethodBean bean = payMethodBeans[selectedPayMethodIndex];
    final String originalType = bean.payNameKey;
    PayType type = PayTypeExt.typeFromPayTypeNameValue(originalType);

    ///检查微信支付是否正常
    if (type == PayType.wxpay || type == PayType.yeepay) {
      bool canWechatPay = await WechatKitPlatform.instance.isInstalled();
      if (!canWechatPay) {
        EasyLoading.showToast("由于您未安装微信，无法完成支付。请切换其他方式支付");
        return;
      }
    }
    EasyLoading.show();

    //旧版创建订单支付
    // 挽留弹窗支付时，使用 firstPopConfig 中的 VipInfo 套餐ID
    final retentionConfigId = isRetention
        ? retentionDefaultVipInfo?.id.toString()
        : null;

    HttpUtils.post(
      APIs.createVipOrder,
      {
        "pay": type.payTypeName,
        "config_id": retentionConfigId ?? _fetchPayTypeID(),
      },
      success: (data) {
        EasyLoading.dismiss();
        byDebugPrint(data["data"], tag: "创建支付订单:");
        postData();
        if (type == PayType.wxpay) {
          needShowDialog = true;
          WxPayOrderBean payOrderBean = WxPayOrderBean.fromJson(data["data"]);
          onSuccess?.call(payOrderBean);
          orderID = payOrderBean.id;
          wxPay(payOrderBean);
        } else if (type == PayType.yeepay) {
          needShowDialog = true;
          YeepayPayOrderBean payOrderBean = YeepayPayOrderBean.fromJson(
            data["data"],
          );
          onSuccess?.call(payOrderBean);
          orderID = payOrderBean.id;
          wxMiniProgramPay(payOrderBean);
        } else {
          AliPayOrderBean aliPayOrderBean = AliPayOrderBean.fromJson(
            data["data"],
          );
          onSuccess?.call(aliPayOrderBean);
          orderID = aliPayOrderBean.id;
          aliPay(aliPayOrderBean);
        }
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
        // BotToast.showText(text: msg);
        FlutterBugly.uploadException(message: "安卓支付-创建订单支付", detail: msg);
        ToastUtil().showToast(msg);
      },
    );

    ///新版创建订单支付-Android
    ///新版 type.payTypeName wxpay,yeepay都传wxpay
    // HttpUtils.post(
    //   APIs.iosOrder,
    //   {
    //     "pay": type.payTypeName == "yeepay" ? "wxpay" : type.payTypeName,
    //     "config_id": _fetchPayTypeID(),
    //     "support_pays": Platform.isAndroid ? "wxpay,alipay,yeepay" : "apple",
    //   },
    //   success: (data) {
    //     EasyLoading.dismiss();
    //     var payOrderinfo = data["data"];
    //     if (payOrderinfo["call_method"] == "wxpay") {
    //       needShowDialog = true;
    //       WxPayOrderBean payOrderBean = WxPayOrderBean.fromJson(data["data"]);
    //       onSuccess?.call(payOrderBean);
    //       orderID = payOrderBean.id;
    //       wxPay(payOrderBean);
    //     } else if (payOrderinfo["call_method"] == "wxpay_mini") {
    //       needShowDialog = true;
    //       YeepayPayOrderBean payOrderBean =
    //           YeepayPayOrderBean.fromJson(data["data"]);
    //       onSuccess?.call(payOrderBean);
    //       orderID = payOrderBean.id;
    //       wxMiniProgramPay(payOrderBean);
    //     } else if (payOrderinfo["call_method"] == "alipay") {
    //       AliPayOrderBean aliPayOrderBean =
    //           AliPayOrderBean.fromJson(data["data"]);
    //       onSuccess?.call(aliPayOrderBean);
    //       orderID = aliPayOrderBean.id;
    //       aliPay(aliPayOrderBean);
    //     }
    //   },
    //   fail: (code, msg) {
    //     EasyLoading.dismiss();
    //     BotToast.showText(text: msg);
    //   },
    // );
  }

  querryOrderStatus({
    void Function()? onSuccess,
    void Function()? onFailed,
    int retryCount = 0,
  }) {
    if (retryCount > 2) {
      BotToast.showText(text: "支付失败");
      onFailed?.call();
      return;
    }
    HttpUtils.get(
      APIs.queryOrderStatus,
      {"id": orderID},
      success: (data) {
        byDebugPrint(data["data"], tag: "订单状态:");

        /// 创建订单前刷新挽留弹窗配置，便于用户支付返回或关闭页面时使用最新配置
        getPopConfig();
        final status = data["data"]["order_status"] ?? "";
        if (status == 'SUCCESS') {
          eventBus.fire(const BuySuccessEvent());
          // 挽留弹窗支付时，使用 firstPopConfig 中的 VipInfo 套餐ID；普通支付使用用户选中的套餐ID
          final reportVipId = isRetention
              ? retentionDefaultVipInfo?.id.toString()
              : (vipTypeBeans.isNotEmpty &&
                        selectedVIPTypeIndex < vipTypeBeans.length
                    ? vipTypeBeans[selectedVIPTypeIndex].id.toString()
                    : null);
          reportPayPageTopInfo(
            "member_page_payment_success",
            vipPageTopDataList.isNotEmpty ? vipPageTopDataList.first : null,
            "click",
            vipId: reportVipId,
            payType: isPopPay == true ? 2 : 1,
            isHalfScreen: isHalfScreen,
          );
          onSuccess?.call();
        } else if (status == 'FAIL') {
          BotToast.showText(text: "支付失败");
          EasyLoading.dismiss();
          onFailed?.call();
        } else {
          Future.delayed(const Duration(seconds: 3)).then(
            (value) => querryOrderStatus(
              onSuccess: onSuccess,
              onFailed: onFailed,
              retryCount: retryCount + 1,
            ),
          );
        }
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
        FlutterBugly.uploadException(message: "安卓支付-查询订单状态", detail: msg);
      },
    );
  }

  ///获取当前渠道
  String app_channel = BuildConfig.instance.channelType.channel;

  /// 是否允许创建订单
  bool canCreateOrder(BuildContext context) {
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
    if (!value) {
      _showDialog(context);
    }
    return value;
  }

  _showDialog(context) {
    ///显示登录页面
    LoginManager.showLoginPage(useSafeArea: true);
  }

  /// 获取是否前置登录配置
  preLoginConfig({void Function()? onSuccess}) {
    HttpUtils.get(
      APIs.getConfig,
      {"group": "xi_tong_pei_zhi"},
      success: (data) {
        byDebugPrint(data, tag: "peizhi11111111111111---22");

        Get.log("获取的数据222===> $data");

        final config = data["data"]["deng_lu_qian_zhi"];
        if (config != null && config is! List) {
          PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(config);
          if (configBean.valText == "1") {
            isPreLogin = true;
          }
        }

        ///返回拦截
        final config2 = data["data"]["zhi_fu_ye_fan_hui_lan_jie"];
        if (config2 != null && config2 is! List) {
          PreLoginConfigBean configBean2 = PreLoginConfigBean.fromJson(config2);
          Get.log("获取的数据2===> ${configBean2.valText == "1"}");
          if (configBean2.valText == "1") {
            isPreBack = true;
          }
        }

        //积分前端控制
        // final config3 = data["data"]["ji_fen_mo_kuai_kai_guan"];
        // if (config3 != null && config3 is! List) {
        //   PreLoginConfigBean configBean3 = PreLoginConfigBean.fromJson(config3);
        //   isIntegralOpen = configBean3.valText == "1" ? true : false;
        // }

        ///支付后弹窗跳转链接
        final payJumpConfig = data["data"]["zhi_fu_hou_tan_chuang_tiao_zhuan"];
        if (payJumpConfig != null && payJumpConfig is! List) {
          PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(
            payJumpConfig,
          );
          payJumpUrl = configBean.valText;
        }

        ///支付后弹窗倒计时
        final payJumpCountdownConfig =
            data["data"]["zhi_fu_hou_tan_chuang_dao_ji_shi"];
        if (payJumpCountdownConfig != null && payJumpCountdownConfig is! List) {
          PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(
            payJumpCountdownConfig,
          );
          payJumpCountdown = int.parse(configBean.valText);
        }

        ///支付后弹窗图片
        final payJumpImageConfig = data["data"]["zhi_fu_hou_tan_chuang_tu"];
        if (payJumpImageConfig != null && payJumpImageConfig is! List) {
          PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(
            payJumpImageConfig,
          );
          payJumpImage = configBean.valText;
        }

        controller.updatePayJumpConfig(
          payJumpUrl,
          payJumpCountdown,
          payJumpImage,
        );

        notifyListeners();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 前置登录检查
  bool preLoginCheck(BuildContext context) {
    var value = false;
    LaunchInfoBean? launchInfoBean = context.read<LaunchProvider>().launchInfo;
    if (launchInfoBean?.isFormal == 1) {
      value = true;
    } else {
      if (isPreLogin == true) {
        value = false;
      } else {
        value = true;
      }
    }
    if (!value) {
      // _showDialog(context);
      controller.login();
    }
    return value;
  }

  /// 会员专属权益数据
  List<PurchaseVipBenefitsBean> vipRightsBeans = [
    PurchaseVipBenefitsBean.fromJson({
      "icon": Assets.purchaseVipAll,
      "name": "解锁全部功能",
      "redIcon": Assets.purchaseVipAllRed,
    }),
    PurchaseVipBenefitsBean.fromJson({
      "icon": Assets.purchaseVipAi,
      "name": "短剧AI混剪",
      "redIcon": Assets.purchaseVipAiRed,
    }),
    PurchaseVipBenefitsBean.fromJson({
      "icon": Assets.purchaseVipNovel,
      "name": "爆款小说推文",
      "redIcon": Assets.purchaseVipNovelRed,
    }),
    PurchaseVipBenefitsBean.fromJson({
      "icon": Assets.purchaseVipStory,
      "name": "民间故事生成",
      "redIcon": Assets.purchaseVipStoryRed,
    }),
    PurchaseVipBenefitsBean.fromJson({
      "icon": Assets.purchaseVipPlay,
      "name": "AI动态视频",
      "redIcon": Assets.purchaseVipPlayRed,
    }),
    PurchaseVipBenefitsBean.fromJson({
      "icon": Assets.purchaseVipDraw,
      "name": "30+绘图风格",
      "redIcon": Assets.purchaseVipDrawRed,
    }),
    PurchaseVipBenefitsBean.fromJson({
      "icon": Assets.purchaseVipDeepSeek,
      "name": "满血DeepSeek",
      "redIcon": Assets.purchaseVipDeepSeekRed,
    }),
    PurchaseVipBenefitsBean.fromJson({
      "icon": Assets.purchaseVipCustomer,
      "name": "专属客服",
      "redIcon": Assets.purchaseVipCustomerRed,
    }),
  ];

  ///更新轮播循环的index
  updateLoopIndex({required int index}) {
    loopIndex = index;
    notifyListeners();
  }

  ///加载金刚卫的数据
  loadBannerBottomData() {
    HttpUtils.get(
      APIs.homeBanner,
      {"postion": 18},
      success: (data) {
        final List bannerData = data["data"]["item"] ?? [];
        byDebugPrint(bannerData, tag: "Banner:---");
        List<SubFunction> beans = bannerData
            .map((e) => SubFunction.fromJson(e))
            .toList();
        menuItemBeans2 = beans;
        Get.log("===android获取配置的金刚卫=== ${data["data"]}");
        notifyListeners();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///查询轮播图配置的数据
  loadIosVipBanner({void Function()? onSuccess}) async {
    HttpUtils.get(
      APIs.homeBanner,
      {"postion": 17},
      success: (data) {
        final List bannerData = data["data"]["item"] ?? [];
        byDebugPrint(bannerData, tag: "Banner:---");
        List<SubFunction> beans = bannerData
            .map((e) => SubFunction.fromJson(e))
            .toList();
        menuItemBeans = beans;
        Get.log("===android获取配置的banner=== ${data["data"]}");

        /// 更新UI
        notifyListeners();
        loadBannerBottomData();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///创建订单数据的上报
  postData() {
    ///function 功能入口
    ///上一页面
    if (eventFunction.isEmpty) {
      return;
    }
    HttpUtils.post(APIs.apiPost, {
      "event": Consts.EVENT_PAID_PAGE,
      "event_function": eventFunction,
      "event_action": Consts.ACTION_CREATE_ORDER_REPORT,
      "page_path": pagePath,
      "pre_page_path": prePagePath,
      "payment_page_tag": "",
      "middle_page_tag": "",
    });
  }

  /// 触发支付挽留弹窗：
  /// 1）页面左上角关闭：按 popConfigList 顺序依次展示，受 maxShowLimit + 当日缓存 控制；若都不满足则不弹窗、直接关页。
  /// 2）二次弹窗（getPopConfigById）：由第一层挽留弹窗 closeBtnType==2 触发；不受 maxShowLimit 控制，逻辑完全跟随 config.closeBtnType。
  /// closeBtnType==1 仅表示可关闭当前弹窗且不触发二次弹窗；closeBtnType==2 表示关闭后触发二次弹窗。
  /// [overridePopConfig] 二次触发时传入，不校验 maxShowLimit。
  triggerRetentionDialog({
    required BuildContext context,
    required VoidCallback onPay,
    VoidCallback? onClose,
    VoidCallback? onImageTap,
    PopConfigBean? overridePopConfig,
  }) {
    PopConfigBean? popConfig;
    if (overridePopConfig != null) {
      // 二次弹窗：不受 maxShowLimit 控制，直接使用 getPopConfigById 返回的配置
      popConfig = overridePopConfig;
    } else {
      // 第一层弹窗：当次页面只展示一次；若当次已展示过则直接关页
      if (firstLayerRetentionShownThisSession) {
        onClose?.call();
        return;
      }
      // 按 popConfigList 顺序取第一个「当日未达 maxShowLimit」的配置，用完后自动往下轮
      popConfig = getCurrentRetentionPopConfig();
    }
    if (popConfig == null) {
      onClose?.call(); // 第一层次数用完或都不满足：不触发弹窗，直接关页
      return;
    }
    final config = popConfig;
    // 第一层弹窗：展示前二次校验 maxShowLimit，防止缓存未及时生效导致超限仍弹
    if (overridePopConfig == null) {
      final countsAgain = getRetentionPopShowCounts();
      if (config.maxShowLimit > 0 &&
          (countsAgain[config.id] ?? 0) >= config.maxShowLimit) {
        onClose?.call();
        return;
      }
    }
    // 与展示的弹窗保持一致，挽留支付/下单时使用同一 config 的 VipInfo
    firstPopConfig = config;
    final defaultVipInfo = config.vipInfo.isNotEmpty
        ? config.vipInfo.first
        : null;
    if (defaultVipInfo == null) {
      onClose?.call();
      return;
    }

    // 挽留弹窗埋点使用当前选中的 popConfig 的 VipInfo
    final retentionVipId = defaultVipInfo.id.toString();

    /// 上报 view 事件
    reportPayPageTopInfo(
      "member_page_retention_dialog",
      config.img,
      "view",
      vipId: retentionVipId,
      isHalfScreen: isHalfScreen,
    );

    // 第一层弹窗：按 ID+次数写入当日缓存（第二层不受 maxShowLimit 控制，不写入缓存）
    if (overridePopConfig == null) {
      incrementRetentionPopShowCount(config.id);
    }

    // 第一层弹窗：当次页面只展示一次，标记已展示
    if (overridePopConfig == null) {
      firstLayerRetentionShownThisSession = true;
    }

    /// 拦截弹窗规则：仅用户主动点关闭按钮才关闭弹窗；点开通/去支付不关闭弹窗，支付成功后再关。
    /// 第一层关闭且 closeBtnType==2 时，弹窗内部 Get.back() 关闭第一层，getPopConfigById.onSuccess 再展示二次弹窗。
    /// 弹窗类型：1=中部弹窗(RetentionVipNewDailog) 2=底部弹窗(PayPageBottomInterceptDialog)
    if (config.popType == 1) {
      Get.dialog(
        RetentionVipNewDailog(
          bgUrl: config.img,
          btnTxt: config.popBtnTitle,
          onTapForClaim: () {
            reportPayPageTopInfo(
              "member_page_retention_dialog_open_btn",
              config.img,
              "click",
              vipId: retentionVipId,
              isHalfScreen: isHalfScreen,
            );
            onPay();
          },
          onClose: () {
            reportPayPageTopInfo(
              "member_page_retention_dialog_close_btn",
              config.img,
              "click",
              vipId: retentionVipId,
              isHalfScreen: isHalfScreen,
            );
            if (config.closeBtnType == "2") {
              getPopConfigById(
                config.popUpId,
                onSuccess: () {
                  triggerRetentionDialog(
                    context: context,
                    onPay: onPay,
                    onClose: onClose,
                    onImageTap: onImageTap,
                    overridePopConfig: firstPopConfig,
                  );
                },
                onFailed: () {},
              );
              return;
            }
            // 由 RetentionVipNewDailog 内部 Get.back() 关闭
          },
        ),
        barrierDismissible: false,
      );
    } else if (config.popType == 2) {
      ///底部弹窗：从底部往上撑开，高度由内容决定
      Get.bottomSheet(
        PayPageBottomInterceptDialog(
          backgroundImageUrl: config.img,
          title: config.popBtnTitle,
          onClose: () {
            reportPayPageTopInfo(
              "member_page_retention_dialog_close_btn",
              config.img,
              "click",
              vipId: retentionVipId,
              isHalfScreen: isHalfScreen,
            );
            if (config.closeBtnType == "2") {
              getPopConfigById(
                config.popUpId,
                onSuccess: () {
                  triggerRetentionDialog(
                    context: context,
                    onPay: onPay,
                    onClose: onClose,
                    onImageTap: onImageTap,
                    overridePopConfig: firstPopConfig,
                  );
                },
                onFailed: () {},
              );
              return;
            }
            // 不在这里 Get.back()，由 PayPageBottomInterceptDialog 内部关闭按钮执行 Get.back()
          },
          onTapForClaim: () {
            reportPayPageTopInfo(
              "member_page_retention_dialog_open_btn",
              config.img,
              "click",
              vipId: retentionVipId,
              isHalfScreen: isHalfScreen,
            );
            onPay();
          },
        ),
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        ignoreSafeArea: false,
      );
    }
  }
}
