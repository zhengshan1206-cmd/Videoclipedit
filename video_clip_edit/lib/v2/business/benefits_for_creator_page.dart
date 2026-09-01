import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/modules/login/widgets/login_agreement_view.dart';
import 'package:video_clip_edit/modules/main/beans/launch_info_bean.dart';
import 'package:video_clip_edit/modules/main/controllers/new_user_benefits_controller.dart';
import 'package:video_clip_edit/modules/purchase/widgets/ios_purchase_agreement_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/pay_success_dialog.dart';
import 'package:video_clip_edit/modules/purchase/widgets/retention_vip_dailog.dart';
import 'package:video_clip_edit/providers/ios_purchase_provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/pay/ios_buy_engine.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:video_clip_edit/v2/business/get_red_envelope_dialog.dart';

class BenefitsForCreatorPage extends StatefulWidget {
  const BenefitsForCreatorPage({super.key});

  @override
  State<StatefulWidget> createState() => BenefitsForCreatorPageState();
}

class BenefitsForCreatorPageState extends State<BenefitsForCreatorPage> {
  bool allowClose = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (allowClose == true) {
          Navigator.pop(context, false);
          return true;
        }
        showDialog(
          context: Get.context!,
          builder: (context) => PopScope(
            child: LimitBuyWidget(
              purchaseProvider: _purchaseProvider,
              iosPurchaseProvider: _iosPurchaseProvider,
              onTapForClaim: () {
                Navigator.pop(context);
                toPay();
              },
              onClose: () {
                allowClose = true;
              },
            ),
            onPopInvoked: (_) {
              allowClose = true;
            },
          ),
        );
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFDCCB), Color(0xFFFFDCCB), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset(
                      "assets/v2/business/img_benefits_for_creator_bg.png",
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(height: 10.h),
                    Stack(
                      children: [
                        Image.asset(
                          "assets/v2/business/img_benefits_details_bg.png",
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                        ),
                        Positioned(
                          top: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 26.h),
                              Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: 32.w,
                                ),
                                child: Image.asset(
                                  "assets/v2/business/img_benefits_details_head.png",
                                  height: 24.h,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: 32.w,
                                ),
                                child: GetBuilder<NewUserBenefitsController>(
                                  id: "updatePriceInfo",
                                  builder: (NewUserBenefitsController controller) {
                                    return Text(
                                      "每天${controller.getVipHappy()?.dayMoney ?? ""}元，快人一步解锁高效创作世界~",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(.7),
                                        fontSize: 14.sp,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 17.h,
                          left: 32.w,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 32.w,
                            child: Row(
                              children: [
                                Stack(
                                  alignment: AlignmentDirectional.topCenter,
                                  children: [
                                    Image.asset(
                                      "assets/v2/business/img_benefits_details_price_bg1.png",
                                      width: 110.w,
                                      height: 110.w,
                                    ),
                                    Positioned(
                                      top: 16.h,
                                      child: GetBuilder<NewUserBenefitsController>(
                                        id: "updatePriceInfo",
                                        builder:
                                            (
                                              NewUserBenefitsController
                                              controller,
                                            ) {
                                              return RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "¥",
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFFFF5752,
                                                        ),
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          "${(int.tryParse(controller.getVipHappy()?.crossedMoney ?? "0") ?? 0) - (int.tryParse(controller.getVipHappy()?.money ?? "0") ?? 0)}",
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFFFF5752,
                                                        ),
                                                        fontSize: 32.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ],
                                ),
                                const Expanded(child: SizedBox()),
                                Image.asset(
                                  "assets/v2/business/img_vertical_line.png",
                                  width: 1.w,
                                  fit: BoxFit.fitWidth,
                                ),
                                const Expanded(child: SizedBox()),
                                Column(
                                  children: [
                                    Image.asset(
                                      "assets/v2/business/img_benefits_details_head2.png",
                                      height: 24.h,
                                      fit: BoxFit.fitHeight,
                                    ),
                                    SizedBox(height: 13.h),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            bottom: 6.h,
                                          ),
                                          child: Text(
                                            "每天仅需",
                                            style: TextStyle(
                                              color: Color(0xFFD67C37),
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Stack(
                                          alignment:
                                              AlignmentDirectional.bottomCenter,
                                          children: [
                                            Image.asset(
                                              "assets/v2/business/img_benefits_details_price_bg.png",
                                              width: 110.h,
                                              fit: BoxFit.fitWidth,
                                            ),
                                            GetBuilder<
                                              NewUserBenefitsController
                                            >(
                                              id: "updatePriceInfo",
                                              builder: (controller) {
                                                return RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            controller
                                                                .getVipHappy()
                                                                ?.dayMoney ??
                                                            "",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 26.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: "元",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(width: 30.w),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    GetBuilder<NewUserBenefitsController>(
                      id: "updatePriceInfo",
                      builder: (controller) {
                        return Text(
                          // "到期按¥${controller.getVipHappy()?.money}/年自动续费，可随时取消自动抛续费",
                          controller.getVipHappy()?.des ?? "",
                          style: TextStyle(
                            color: Color(0xFFD2A087),
                            fontSize: 12.sp,
                          ),
                        );
                      },
                    ),
                    // SizedBox(
                    //   height: 14.h,
                    // ),
                    if (Platform.isAndroid)
                      Obx(() {
                        int currentPay = Get.find<NewUserBenefitsController>()
                            .currentPay
                            .value;
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsetsDirectional.only(start: 12.w),
                          margin: EdgeInsetsDirectional.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.w),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.only(
                                  top: 12.w,
                                  bottom: 12.w,
                                ),
                                child: Image.asset(
                                  currentPay == 0
                                      ? "assets/v2/business/img_wechat_pay_icon.png"
                                      : "assets/v2/business/img_alipay_icon.png",
                                  width: 20.w,
                                  height: 20.w,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                currentPay == 0 ? "微信支付" : "支付宝支付",
                                style: TextStyle(
                                  color: Color(0xFF101E48),
                                  fontSize: 14.sp,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              GestureDetector(
                                child: Container(
                                  color: Colors.transparent,
                                  padding: EdgeInsetsDirectional.only(
                                    end: 12.w,
                                    start: 12.w,
                                    top: 10.w,
                                    bottom: 10.w,
                                  ),
                                  child: Image.asset(
                                    "assets/v2/business/img_switch_pay.png",
                                    height: 16.h,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                                onTap: () {
                                  Get.find<NewUserBenefitsController>()
                                      .switchPayType();
                                  _purchaseProvider
                                      ?.changeSelectedPayMethodIndex(
                                        Get.find<NewUserBenefitsController>()
                                            .currentPay
                                            .value,
                                      );
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    // const Expanded(child: SizedBox()),
                    SizedBox(height: 50.h),
                    GestureDetector(
                      child: BtnBreathingAnimationWidget(
                        child: Image.asset(
                          "assets/v2/business/img_click_and_claim.png",
                          width: 280.w,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      onTap: () {
                        toPay();
                      },
                    ),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      child: Container(
                        color: Colors.transparent,
                        width: double.infinity,
                        padding: EdgeInsetsDirectional.only(
                          start: 20.w,
                          end: 20.w,
                        ),
                        alignment: AlignmentDirectional.center,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          children: [
                            Obx(() {
                              bool agreed =
                                  Get.find<NewUserBenefitsController>()
                                      .agreed
                                      .value;
                              return Image.asset(
                                agreed == true
                                    ? "assets/v2/business/img_agree_press.png"
                                    : "assets/v2/business/img_agree_normal.png",
                                width: 15.w,
                                height: 15.w,
                              );
                            }),
                            SizedBox(width: 6.w),
                            Text(
                              "同意",
                              style: TextStyle(
                                color: Color(0xFFD2A087).withOpacity(.8),
                                fontSize: 12.sp,
                              ),
                            ),
                            GestureDetector(
                              child: Text(
                                "《会员服务协议》",
                                style: TextStyle(
                                  color: Color(0xFFD2A087).withOpacity(.8),
                                  fontSize: 12.sp,
                                ),
                              ),
                              onTap: () {
                                if (_purchaseProvider
                                        ?.vipPageBean
                                        ?.user
                                        .protocolUrl
                                        .isEmpty ==
                                    true)
                                  return;
                                ByNavRouterUtils.jumpWebViewPage(
                                  context,
                                  "",
                                  _purchaseProvider!
                                      .vipPageBean!
                                      .user
                                      .protocolUrl,
                                );
                              },
                            ),
                            if (Platform.isIOS)
                              Text(
                                "和",
                                style: TextStyle(
                                  color: Color(0xFFD2A087).withOpacity(.8),
                                  fontSize: 12.sp,
                                ),
                              ),
                            if (Platform.isIOS)
                              GestureDetector(
                                child: Text(
                                  "《自动续费服务协议》",
                                  style: TextStyle(
                                    color: Color(0xFFD2A087).withOpacity(.8),
                                    fontSize: 12.sp,
                                  ),
                                ),
                                onTap: () {
                                  debugPrint(
                                    "open Url:${_iosPurchaseProvider?.vipPageBean?.user.subScribeProtocolUrl}",
                                  );
                                  if (_iosPurchaseProvider
                                          ?.vipPageBean
                                          ?.user
                                          .subScribeProtocolUrl
                                          .isEmpty ==
                                      true)
                                    return;
                                  ByNavRouterUtils.jumpWebViewPage(
                                    context,
                                    "",
                                    _iosPurchaseProvider
                                            ?.vipPageBean
                                            ?.user
                                            .subScribeProtocolUrl ??
                                        "",
                                  );
                                },
                              ),
                            Text(
                              "和",
                              style: TextStyle(
                                color: Color(0xFFD2A087).withOpacity(.8),
                                fontSize: 12.sp,
                              ),
                            ),
                            GestureDetector(
                              child: Text(
                                "《积分服务协议》",
                                style: TextStyle(
                                  color: Color(0xFFD2A087).withOpacity(.8),
                                  fontSize: 12.sp,
                                ),
                              ),
                              onTap: () {
                                if (Platform.isIOS) {
                                  debugPrint(
                                    "open Url:${_iosPurchaseProvider?.vipPageBean?.user.integralRule}",
                                  );
                                  if (_iosPurchaseProvider
                                          ?.vipPageBean!
                                          .user
                                          .integralRule
                                          .isNotEmpty !=
                                      true)
                                    return;
                                  ByNavRouterUtils.jumpWebViewPage(
                                    context,
                                    "",
                                    _iosPurchaseProvider!
                                            .vipPageBean
                                            ?.user
                                            .integralRule ??
                                        "",
                                  );
                                } else {
                                  debugPrint(
                                    "open Url:${_purchaseProvider?.vipPageBean?.user.integralRule}",
                                  );
                                  if (_purchaseProvider
                                          ?.vipPageBean!
                                          .user
                                          .integralRule
                                          .isNotEmpty !=
                                      true) {
                                    return;
                                  }
                                  ByNavRouterUtils.jumpWebViewPage(
                                    context,
                                    "",
                                    _purchaseProvider!
                                            .vipPageBean
                                            ?.user
                                            .integralRule ??
                                        "",
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Get.find<NewUserBenefitsController>().switchAgree();
                        if (Platform.isIOS) {
                          _iosPurchaseProvider?.agreementCheckedStatusChanged(
                            !(_iosPurchaseProvider?.agreementChecked ?? false),
                          );
                        } else {
                          context
                              .read<PurchaseProvider>()
                              .agreementCheckedStatusChanged(
                                Get.find<NewUserBenefitsController>()
                                    .agreed
                                    .value,
                              );
                        }
                      },
                    ),
                    SizedBox(height: 34.h),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12.w,
              top: 44.h,
              child: GestureDetector(
                child: Container(
                  color: Colors.transparent,
                  width: 36.w,
                  height: 36.w,
                  child: Image.asset(
                    "assets/v2/business/img_benefits_for_creator_close.png",
                  ),
                ),
                onTap: () {
                  if (allowClose == true) {
                    Navigator.pop(context, false);
                    return;
                  }
                  showDialog(
                    context: Get.context!,
                    builder: (context) => PopScope(
                      child: LimitBuyWidget(
                        purchaseProvider: _purchaseProvider,
                        iosPurchaseProvider: _iosPurchaseProvider,
                        onTapForClaim: () {
                          Navigator.pop(context);
                          toPay();
                        },
                        onClose: () {
                          allowClose = true;
                        },
                      ),
                      onPopInvoked: (_) {
                        allowClose = true;
                      },
                    ),
                  ).then((_) {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IosPurchaseProvider? _iosPurchaseProvider;

  PurchaseProvider? _purchaseProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _iosPurchaseProvider = context.read<IosPurchaseProvider>();
      _purchaseProvider = context.read<PurchaseProvider>();
      _purchaseProvider?.loadVipData();
      _iosPurchaseProvider?.loadVipData();
      if (Platform.isIOS) {
        _iosPurchaseProvider?.iosBuyEngin.initializeInAppPurchase();
        _iosPurchaseProvider?.loadIosVipBanner();
        _iosPurchaseProvider?.loadVipData();
        _iosPurchaseProvider?.preLoginConfig();
        iniIosPaySuccessSubscription();
      }
      _purchaseProvider?.agreementCheckedStatusChanged(
        Get.find<NewUserBenefitsController>().agreed.value,
      );

      /// 订阅微信支付通知
      _purchaseProvider?.subscribeWXPayResp(
        context,
        onSuccess: () {
          if (Get.isRegistered<NewUserBenefitsController>()) {
            Get.find<NewUserBenefitsController>().hideBottom();
          }
        },
      );

      /// 订阅支付宝支付通知
      _purchaseProvider?.subscribeAliPayResp(
        context,
        onSuccess: () {
          if (Get.isRegistered<NewUserBenefitsController>()) {
            Get.find<NewUserBenefitsController>().hideBottom();
          }
        },
      );
    });
  }

  ///苹果支付成功后查询订单状态的监听
  StreamSubscription? _iosPaySuccessSubscription;

  StreamSubscription? _iosBuyStreamSubscription;

  /// 查询订单状态
  void _queryOrderStatus({required String receiptData}) {
    _iosPurchaseProvider?.queryOrderStatus(
      receiptData: receiptData,
      onSuccess: () async {},
    );
  }

  ///监听苹果支付成功状态
  iniIosPaySuccessSubscription() {
    _iosPaySuccessSubscription = eventBus.on<QueryIosOrderEvent>().listen((
      event,
    ) {
      _queryOrderStatus(receiptData: event.serverVerificationData);
    });
    _iosBuyStreamSubscription = eventBus.on<IosProductBuySuccessEvent>().listen(
      (e) {
        /// 充值成功
        context.read<LaunchProvider>().launch(
          Get.context!,
          onSuccess: (LaunchInfoBean bean) {
            /// 更新个人信息
            Get.find<UserController>().reloadUserInfo(
              successAction: (userInfo) {
                debugPrint("isBindPhone:${userInfo?.isBindPhone == 1}");

                ///未绑定手机号
                if (userInfo?.isBindPhone == 0) {
                  Get.find<UserController>()
                      .showBindPhoneDialog(needConfirm: true)
                      .then((value) {
                        showSuccessDialog(
                          title: value != null && value ? '绑定成功！' : null,
                        );
                      });
                  return;
                }
                showSuccessDialog();
              },
            );
          },
        );
      },
    );
  }

  showSuccessDialog({String? title}) async {
    Get.customDialog(
      barrierDismissible: false,
      widget: PaySuccessDialog(title: title),
    ).then((_) {
      _goBack();
    });
  }

  ///路由返回页面方法
  void _goBack() {
    LaunchProvider provider = context.read<LaunchProvider>();
    if (provider.launchInfo?.isVip == 1) {
      if (Navigator.canPop(context)) {
        Get.back();
      } else {
        Get.offNamed(Routes.main);
      }
      return;
    }
    if (!context.read<PurchaseProvider>().isPreBack) {
      if (Navigator.canPop(context)) {
        Get.back();
        return;
      } else {
        Get.offNamed(Routes.main);
        return;
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return ChangeNotifierProvider.value(
          value: context.read<IosPurchaseProvider>(),
          child: RetentionVipDailog(
            markUrl: _iosPurchaseProvider?.vipPageBean?.retainWindowUrl ?? '',
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _iosBuyStreamSubscription?.cancel();
    _iosPaySuccessSubscription?.cancel();
    _purchaseProvider?.cancelSubscribeWXPayResp();
    _purchaseProvider?.cancelSubscribeAliPayResp();
  }

  ///调起支付方法
  void toPay() {
    if (Platform.isIOS) {
      IosPurchaseProvider? provider = _iosPurchaseProvider;
      provider ??= context.read<IosPurchaseProvider>();
      if (Get.find<NewUserBenefitsController>().agreed.value != true) {
        showDialog(
          useSafeArea: true,
          context: context,
          builder: (context) {
            return IosPurchaseAgreementView(
              iosPurchaseProvider: provider!,
              btnTitle: "确认并立即解锁",
              registerMember: true,
              callback: () {
                provider!.agreementCheckedStatusChanged(true);
                Get.find<NewUserBenefitsController>().switchAgree();

                /// 显示弹窗并写入plist
                createOrderForIos(provider);
              },
              // color1: type == PurchaseUiType.Blue
              //     ? const Color(0XFF5B4BF7)
              //     : const Color(0xffFF387A),
            );
          },
        );
        return;
      }
      createOrderForIos(provider);
    } else {
      final provider = context.read<PurchaseProvider>();

      if (!provider.isAgreementChecked) {
        showDialog(
          context: context,
          builder: (context) {
            return LoginAgreementView(
              btnTitle: "确认并立即解锁",
              registerMember: true,
              callback: () {
                provider.agreementCheckedStatusChanged(true);
                Get.find<NewUserBenefitsController>().switchAgree();

                /// 显示弹窗并写入plist
                createOrder(provider);
              },
            );
          },
        );
        return;
      }
      createOrder(provider);
    }
  }

  void createOrderForIos(IosPurchaseProvider? provider) {
    ByNavigatorUtil.checkLogin(
      withOutGotoBind: false,
      context: Get.context!,
      nextStepEvent: () {
        if ((Get.find<UserController>().user.value?.activeDay ?? 0) <= 1 &&
            Get.find<UserController>().user.value?.isVip != 1) {
          provider!.createIosOrder(
            onSuccess: (payOrderBean) {},
            context: context,
          );
        } else {
          if (Get.isRegistered<NewUserBenefitsController>()) {
            Get.find<NewUserBenefitsController>().hideBottom();
          }
          Navigator.pop(context);
        }
      },
    );
  }

  void createOrder(PurchaseProvider? provider) {
    ByNavigatorUtil.checkLogin(
      withOutGotoBind: false,
      context: Get.context!,
      nextStepEvent: () {
        if ((Get.find<UserController>().user.value?.activeDay ?? 0) <= 1 &&
            Get.find<UserController>().user.value?.isVip != 1) {
          provider?.createOrder(
            onSuccess: (payOrderBean) {
              // Navigator.pop(context);
            },
            context: context,
          );
        } else {
          if (Get.isRegistered<NewUserBenefitsController>()) {
            Get.find<NewUserBenefitsController>().hideBottom();
          }
          Navigator.pop(context);
          context.read<LaunchProvider>().gotoPay(
            context,
            closePay: true,
            replace: true,
          );
        }
      },
    );
  }
}
