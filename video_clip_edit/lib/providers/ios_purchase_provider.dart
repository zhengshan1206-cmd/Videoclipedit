import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/modules/login/controller/login_manager.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import '../modules/home/widgets/sub_funcs_view.dart';
import '../modules/login/login_page_ex.dart';
import '../modules/main/beans/launch_info_bean.dart';
import '../modules/purchase/beans/pre_login_config_bean.dart';
import '../modules/purchase/beans/vip_page_bean.dart';
import '../modules/purchase/beans/vip_type_bean.dart';
import '../modules/purchase/beans/pop_config_bean.dart';
import '../modules/purchase/mixins/purchase_page_top_mixin.dart';
import '../utils/comon/by_colors.dart';
import '../utils/comon/by_common_utils.dart';
import '../utils/consts/const.dart';
import '../utils/http/apis.dart';
import '../utils/http/http_utils.dart';
import '../utils/pay/ios_buy_engine.dart';
import '../widgets/toast_util.dart';
import 'launch_provider.dart';
import '../v2/business/get_red_envelope_dialog.dart';

///ios支付
class IosPurchaseProvider extends BaseProvider with PurchasePageTopMixin {
  ///banner
  List<SubFunction> menuItemBeans = [];

  ///当前轮播循环的index
  int loopIndex = 0;

  ///金刚卫
  List<SubFunction> menuItemBeans2 = [];

  ///商品ios列表
  List<VipTypeBean> vipTypeBeans = [];

  ///选中的vip类型
  int selectedVIPTypeIndex = 0;

  ///同意协议
  bool agreementChecked = true;

  ///vip页面数据
  VipPageBean? vipPageBean;

  ///Ios支付工具
  IosBuyEngin iosBuyEngin = IosBuyEngin();

  ///选中的vip购买类型产品Id
  String appleVipId = "";

  ///选中的vip购买类型产品Id -这里服务器有一个id与安卓适配
  int? appleVipIdFromSever;

  ///苹果支付成功后查询订单状态的监听
  late StreamSubscription iosPaySuccessSubscription;

  ///当前订单Id
  String orderId = "";

  ///产品购买提示语
  String showHintText = "";

  ///是否拦截返回
  bool isPreBack = false;

  ///是否前置登录
  String memberBtnTxt = "立即解锁";

  ///是否展示积分服务协议
  bool isShowIntegralAgreement = false;

  //是否是挽留弹出拉起支付
  bool isRetention = false;

  ///是否是弹窗拉起支付
  bool isPopPay = false;

  List<IconModel> iconModelList1 = [
    const IconModel(
      iconName: "解锁全部功能",
      iconPath: Assets.purchaseVipAll,
      iconRedPath: Assets.purchaseVipAllRed,
    ),
    const IconModel(
      iconName: "短剧AI混剪",
      iconPath: Assets.purchaseVipAi,
      iconRedPath: Assets.purchaseVipAiRed,
    ),
    const IconModel(
      iconName: "爆款小说推文",
      iconPath: Assets.purchaseVipNovel,
      iconRedPath: Assets.purchaseVipNovelRed,
    ),
    const IconModel(
      iconName: "故事生成",
      iconPath: Assets.purchaseVipStory,
      iconRedPath: Assets.purchaseVipStoryRed,
    ),
    const IconModel(
      iconName: "AI动态视频",
      iconPath: Assets.purchaseVipPlay,
      iconRedPath: Assets.purchaseVipPlayRed,
    ),
    const IconModel(
      iconName: "30+绘图风格",
      iconPath: Assets.purchaseVipDraw,
      iconRedPath: Assets.purchaseVipDrawRed,
    ),
    const IconModel(
      iconName: "满血DeepSeek",
      iconPath: Assets.purchaseVipDeepSeek,
      iconRedPath: Assets.purchaseVipDeepSeekRed,
    ),
    const IconModel(
      iconName: "专属客服",
      iconPath: Assets.purchaseVipCustomer,
      iconRedPath: Assets.purchaseVipCustomerRed,
    ),
  ];

  String eventFunction;
  String pagePath;
  String prePagePath;

  /// 是否是半弹窗付费页
  bool isHalfScreen = false;

  IosPurchaseProvider({
    this.eventFunction = "",
    this.pagePath = "",
    this.prePagePath = "",
    this.isHalfScreen = false,
  });

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
        Get.log("===ios获取配置的banner=== ${data["data"]}");

        /// 更新UI
        notifyListeners();
        loadBannerBottomData();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

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
        Get.log("===ios获取配置的金刚卫=== ${data["data"]}");
        notifyListeners();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///加载vip列表数据
  _loadVIPItems({void Function()? onSuccess}) {
    HttpUtils.get(
      APIs.vipHappys,
      {"ver": 1, "support_pays": "apple"},
      success: (data) {
        final respData = data["data"];
        byDebugPrint(respData, tag: "获取VIP权益：");
        final List items = respData["items"] ?? [];
        Get.log("商品列表的数据====>$data ");
        List<VipTypeBean> typeBeans = items
            .map((e) => VipTypeBean.fromJson(e))
            .toList();
        vipTypeBeans = typeBeans;
        // 挽留套餐以 firstPopConfig.vipInfo 为准，不再在此设置
        appleVipId = vipTypeBeans.first.appleVipId;
        appleVipIdFromSever = vipTypeBeans.first.id;
        String time = "月";
        if (vipTypeBeans.first.vipLevel == 365) {
          time = "年";
        } else if (vipTypeBeans.first.vipLevel == 30) {
          time = "月";
        } else if (vipTypeBeans.first.vipLevel == 90) {
          time = "季";
        }
        // if (vipTypeBeans.first.isSubscribe == 1) {
        //   showHintText = "到期后按${vipTypeBeans.first.money}¥/$time自动续费，可随时取消自动续费";
        // } else {
        //   showHintText = "一次性付费，到期后不会自动扣费，放心购买";
        // }
        showHintText = vipTypeBeans.first.des;

        isShowIntegralAgreement = vipTypeBeans.first.integral > 0
            ? true
            : false;
        Get.log("第一个分配到的苹果产品id====>$appleVipId ");

        ///判断选中会员列表按钮文案
        if (validateMemberBtnTxt(
          vipTypeBeans[selectedVIPTypeIndex].buttonTitle,
        )) {
          memberBtnTxt = vipTypeBeans[selectedVIPTypeIndex].buttonTitle;
        } else {
          memberBtnTxt = "立即解锁";
        }

        /// 更新UI
        notifyListeners();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  agreementCheckedStatusChanged(bool status) {
    agreementChecked = status;
    notifyListeners();
  }

  /// 根据审核状态初始化协议勾选状态
  void initAgreementStatus() {
    // 审核状态或非审核状态（iOS订阅）：无论什么状态都不勾选协议
    agreementChecked = false;
    notifyListeners();
  }

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

  ///加载vip数据
  loadVipData() {
    _loadVIPItems();
    _loadVipPageData();
  }

  ///选中的会员付费类型
  changeSelectedVipTypeIndex(
    int index,
    String newAppleVipId,
    int newAppleVipIdFromSever,
    String newShowHintText,
  ) {
    selectedVIPTypeIndex = index;
    appleVipId = newAppleVipId;
    appleVipIdFromSever = newAppleVipIdFromSever;
    showHintText = newShowHintText;

    ///判断选中会员列表按钮文案
    if (validateMemberBtnTxt(vipTypeBeans[index].buttonTitle)) {
      memberBtnTxt = vipTypeBeans[index].buttonTitle;
    } else {
      memberBtnTxt = "立即解锁";
    }
    isShowIntegralAgreement = vipTypeBeans[index].integral > 0 ? true : false;

    notifyListeners();
  }

  bool validateMemberBtnTxt(String? input) {
    return input?.isNotEmpty ?? false;
  }

  ///购买ios产品
  buyIosProductData(String orderId) async {
    // 挽留弹窗支付时，使用 firstPopConfig 中的 VipInfo 套餐信息
    if (isRetention && retentionDefaultVipInfo?.appleVipId.isNotEmpty == true) {
      appleVipId = retentionDefaultVipInfo!.appleVipId;
    }
    if (appleVipId.isEmpty) {
      BotToast.showText(text: "未查找到商品，请重试");
    }
    await iosBuyEngin.loadProductDataAndBuy(appleVipId, orderId);
  }

  /// 创建ios支付的订单，获取商户信息
  createIosOrder({
    required BuildContext context,
    bool retentionPop = false,
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
    ByNavigatorUtil.checkLogin(
      context: context,
      nextStepEvent: () {
        isRetention = retentionPop;
        if (vipTypeBeans.isEmpty) {
          _loadVIPItems(
            onSuccess: () {
              _startCreateOrder(onSuccess: onSuccess, context: context);
            },
          );
        } else {
          _startCreateOrder(onSuccess: onSuccess, context: context);
        }
      },
    );
  }

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
    // final purchaseProvider = context.read<PurchaseProvider>();
    if (!value) {
      ///显示登录页面
      LoginManager.showLoginPage(useSafeArea: true, onlyPhone: true);
    }
    return value;
  }

  ///开始创建订单
  void _startCreateOrder({
    void Function(dynamic payOrderBean)? onSuccess,
    required BuildContext context,
  }) {
    EasyLoading.show();
    // 挽留弹窗支付时，使用 firstPopConfig 中的 VipInfo 套餐ID
    final retentionConfigId = isRetention
        ? retentionDefaultVipInfo?.id.toString()
        : null;

    HttpUtils.post(
      APIs.iosOrder,
      {
        "pay": "apple",
        "config_id": retentionConfigId ?? appleVipIdFromSever,
        "support_pays": "apple",
      },
      success: (data) {
        EasyLoading.dismiss();
        byDebugPrint(data["data"], tag: "创建支付订单:");
        postData(context: context);
        Get.log("===创建ios订单的返回数据=== $data");
        orderId = data["data"]["id"];
        buyIosProductData(data["data"]["id"]);
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
        FlutterBugly.uploadException(message: "ios支付-创建订单", detail: msg);
      },
    );
  }

  ///查询订单状态
  queryOrderStatus({void Function()? onSuccess, required String receiptData}) {
    if (receiptData.isEmpty || orderId.isEmpty) {
      return;
    }
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..maskType = EasyLoadingMaskType.custom
      ..indicatorType = EasyLoadingIndicatorType.cubeGrid
      ..indicatorColor = ByColorUtil.PurchasePriceTextColor
      ..loadingStyle = EasyLoadingStyle.light;
    EasyLoading.show(dismissOnTap: false);
    HttpUtils.post(
      APIs.queryOrderStatus,
      {"id": orderId, "receipt_data": receiptData},
      success: (data) {
        byDebugPrint(data["data"], tag: "订单状态:");
        final status = data["data"]["order_status"] ?? "";
        if (status != "SUCCESS") {
          Future.delayed(const Duration(seconds: 3), () {
            queryOrderStatus(receiptData: receiptData);
          });
          return;
        } else {
          EasyLoading.dismiss();
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
          eventBus.fire(const IosProductBuySuccessEvent());
          eventBus.fire(const BuySuccessEvent());
        }
      },
      fail: (code, msg) {
        EasyLoading.dismiss();
        ToastUtil().showToast(msg);
        FlutterBugly.uploadException(message: "ios支付-查询订单状态", detail: msg);
      },
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

  /// 获取是否前置登录配置
  preLoginConfig({void Function()? onSuccess}) {
    // HttpUtils.get(
    //   APIs.getConfig,
    //   {"group": "xi_tong_pei_zhi"},
    //   success: (data) {
    //     // final config = data["data"]["deng_lu_qian_zhi"];
    //     // if (config == null || config is List) return;
    //     // PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(config);
    //     // // onSuccess?.call(configBean);
    //     // if (configBean.valText == "1") {
    //     //   isPreLogin = true;
    //     // }
    //
    //     ///返回拦截
    //     final config2 = data["data"]["zhi_fu_ye_fan_hui_lan_jie"];
    //     if (config2 == null || config2 is List) return;
    //     PreLoginConfigBean configBean2 = PreLoginConfigBean.fromJson(config2);
    //     // onSuccess?.call(configBean);
    //     if (configBean2.valText == "1") {
    //       isPreBack = true;
    //     }
    //
    //     notifyListeners();
    //   },
    //   fail: (code, msg) {
    //     BotToast.showText(text: msg);
    //   },
    // );
  }

  postData({required BuildContext context}) {
    ///function 功能入口
    ///上一页面
    if (eventFunction.isEmpty) {
      return;
    }
    final launchProvider = Provider.of<LaunchProvider>(context, listen: false);

    HttpUtils.post(APIs.apiPost, {
      "event": Consts.EVENT_PAID_PAGE,
      "event_function": eventFunction,
      "event_action": Consts.ACTION_CREATE_ORDER_REPORT,
      "page_path": pagePath,
      "pre_page_path": prePagePath,
      "middle_page_tag": "",
      "payment_page_tag": launchProvider.launchInfo?.verConfig.halfScreenPage,
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

    final retentionVipId = defaultVipInfo.id.toString();

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

    /// 拦截弹窗规则：仅允许用户手动关闭，不主动关闭；二次弹窗时由用户点关闭后当前弹窗关闭再展示二次。
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

class IconModel {
  final String iconName;
  final String iconPath;
  final String iconRedPath;

  const IconModel({
    required this.iconName,
    required this.iconPath,
    required this.iconRedPath,
  });
}
