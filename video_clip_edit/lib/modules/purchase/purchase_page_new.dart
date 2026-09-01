// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/main.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/modules/main/beans/launch_info_bean.dart';
import 'package:video_clip_edit/modules/main/controllers/new_user_benefits_controller.dart';
import 'package:video_clip_edit/modules/purchase/widgets/pay_success_dialog.dart';
import 'package:video_clip_edit/modules/purchase/widgets/pay_success_new_dialog.dart';
import 'package:video_clip_edit/modules/purchase/widgets/retention_vip_dailog.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/purchase/beans/pay_method_bean.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/modules/purchase/beans/purchase_guid_bean.dart';
import 'package:video_clip_edit/modules/purchase/widgets/new_vip_list_view.dart';
import 'package:video_clip_edit/modules/login/widgets/login_agreement_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/new_vip_method_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/vip_count_down_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/purchase_success_dialog.dart';
import 'package:video_clip_edit/utils/channel/channel_config.dart';
import 'package:video_clip_edit/flavors/build_config.dart';

import '../../widgets/toast_util.dart';
import 'mixins/purchase_page_back_mixin.dart';

class PurchasePageNew extends StatefulWidget {
  final bool? closePay;

  const PurchasePageNew({super.key, this.closePay});

  @override
  State<PurchasePageNew> createState() => _PurchasePageNewState();
}

class _PurchasePageNewState extends State<PurchasePageNew>
    with WidgetsBindingObserver, PurchasePageBackMixin {
  PurchaseProvider? provider;
  bool popWhenSuccess = false;
  bool _hasReportedExposure = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      final bool? shouldPop =
          ModalRoute.of(context)?.settings.arguments as bool?;
      popWhenSuccess = shouldPop ?? false;
    });

    provider = context.read<PurchaseProvider>();
    provider?.resetFirstLayerRetentionForSession();
    final isAudit = context.read<LaunchProvider>().launchInfo!.isAudit;
    if (isAudit == 1) {
      Future.microtask(() {
        provider?.agreementCheckedStatusChanged(false);
      });
    }

    /// 订阅微信支付通知
    provider?.subscribeWXPayResp(
      context,
      onSuccess: () {
        if (Get.isRegistered<NewUserBenefitsController>()) {
          Get.find<NewUserBenefitsController>().hideBottom();
        }
        _queryOrderStatus();
      },
    );

    /// 订阅支付宝支付通知
    provider?.subscribeAliPayResp(
      context,
      onSuccess: () {
        if (Get.isRegistered<NewUserBenefitsController>()) {
          Get.find<NewUserBenefitsController>().hideBottom();
        }
        _queryOrderStatus();
      },
    );

    /// 加载VIP权益
    provider?.loadVipData();
    provider?.preLoginConfig();

    /// 获取支付挽留配置信息（用于左上角关闭按钮触发挽留弹窗）
    provider?.getPopConfig();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0E101F),
        body: Consumer<PurchaseProvider>(
          builder:
              (
                BuildContext context,
                PurchaseProvider purchaseProvider,
                Widget? child,
              ) {
                // 数据加载完成后进行曝光上报（只上报一次）
                if (purchaseProvider.vipTypeBeans.isNotEmpty &&
                    !_hasReportedExposure) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _reportPageExposure();
                    }
                  });
                }

                return Stack(
                  children: [
                    const SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    _buildBg(),
                    _buildAppBar(context),
                    _buildMain(context),
                  ],
                );
              },
        ),
      ),
    );
  }

  Positioned _buildBg() {
    return Positioned.fill(
      child: ListView(
        padding: EdgeInsets.only(bottom: 340.h),
        children: [
          SizedBox(height: ByScreenUtils.navigationBarHeight),
          Stack(
            children: [
              Image.asset(
                Assets.newIconMemberPayBg,
                width: ByScreenUtils.screenWidth,
                fit: BoxFit.fitWidth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// app bar
  Positioned _buildAppBar(BuildContext context) {
    return Positioned(
      child: SizedBox(
        height: ByScreenUtils.navigationBarHeight,
        child: ByWidgetsUtil.gradientBgContainer(
          borderRadius: 0,
          padding: EdgeInsets.only(top: context.byTopSafeHeight),
          gradient: ByColorUtil.lineareGradient(
            colorStart: const Color(0xFF0E101F),
            colorEnd: const Color(0xFF341B26),
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      if (Get.isRegistered<NewUserBenefitsController>() ==
                              true &&
                          Get.find<NewUserBenefitsController>()
                                  .showType
                                  .value ==
                              2) {
                        bool value = await Get.find<NewUserBenefitsController>()
                            .retentionDialog(callPay: toPay);
                        if (value == true) {
                          Navigator.pop(context);
                          return;
                        }
                        return;
                      }
                      _showExitConfirmationDialog(context);
                      // provider?.preLoginConfig();
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/home/icon_back.png",
                        width: 16,
                        height: 16,
                        color: ByColorUtil.WhiteColor,
                      ),
                    ),
                  ),
                ],
              ),
              ByWidgetsUtil.commonText(
                text: "会员中心",
                fontSize: 16.sp,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w600,
                textColor: ByColorUtil.WhiteColor,
              ),
              Row(
                children: [
                  Offstage(
                    offstage: Platform.isAndroid,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        ByCommonUtils.debugPrintObj('恢复购买', tag: "Resume---");
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5,
                        ),
                        margin: EdgeInsets.only(right: 12.w),
                        decoration: BoxDecoration(
                          color: ByColorUtil.WhiteColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: ByWidgetsUtil.commonText(
                          text: "恢复购买",
                          fontSize: 12.sp,
                          textColor: ByColorUtil.CommonTextColor.withOpacity(
                            0.6,
                          ),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  Offstage(
                    offstage: !ChannelConfig.exclude_channel.contains(
                      BuildConfig.instance.channelType.channel,
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          ByNavRouterUtils.goBack(context);
                        } else {
                          Get.offNamed(Routes.main);
                        }
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/mine/mine-close-icon.png",
                          width: 32,
                          height: 32,
                          color: ByColorUtil.WhiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 支付列表
  _buildVIPTypeListView(BuildContext context) {
    return const NewVipListView();
  }

  /// 支付方式
  _buildPayMethods(BuildContext context) {
    final provider = context.read<PurchaseProvider>();
    final payMethodBeans = provider.payMethodBeans;
    return Container(
      padding: EdgeInsets.only(left: 55.w, right: 55.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: payMethodBeans.map((bean) {
          return NewVipMethodView(
            payMethodBean: bean,
            onSelected: (PayMethodBean bean) {
              provider.changeSelectedPayMethodIndex(
                provider.payMethodBeans.indexOf(bean),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  ///处理返回逻辑
  Future<void> _handleBack() async {
    // 检查 isPreBack 状态
    if (!context.read<PurchaseProvider>().isPreBack) {
      _goBack();
      return;
    }

    // 使用新的 PurchasePageBackMixin 逻辑（新版本逻辑3.10.41）
    await handlePurchasePageBack(
      context: context,
      onPay: () {
        toPay(popPay: true, retentionPop: true);
      },
      onGoBack: _goBack,
    );
  }

  ///路由返回页面方法
  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    } else {
      Get.offNamed(Routes.main);
    }
  }

  void toPay({bool popPay = false, bool retentionPop = false}) {
    final provider = context.read<PurchaseProvider>();

    // 上报开通按钮点击
    _reportPayPageTopInfo("member_page_open_btn", "click");

    if (!provider.isAgreementChecked) {
      // 上报协议弹窗显示
      _reportPayPageTopInfo("member_page_renew_protocol_dialog", "view");

      showDialog(
        context: context,
        builder: (context) {
          return LoginAgreementView(
            btnTitle: "成为会员",
            registerMember: true,
            callback: () {
              // 上报协议弹窗开通按钮点击
              _reportPayPageTopInfo(
                "member_page_renew_protocol_open_btn",
                "click",
              );

              provider.agreementCheckedStatusChanged(true);

              /// 显示弹窗并写入plist
              provider.createOrder(
                onSuccess: (payOrderBean) {},
                context: context,
                popPay: popPay,
                retentionPop: retentionPop,
              );
            },
            onClose: () {
              // 上报协议弹窗关闭按钮点击
              _reportPayPageTopInfo(
                "member_page_renew_protocol_close_btn",
                "click",
              );
            },
          );
        },
      );
      return;
    }
    provider.createOrder(
      onSuccess: (payOrderBean) {
        // Navigator.pop(context);
      },
      context: context,
      popPay: popPay,
      retentionPop: retentionPop,
    );
  }

  /// 订阅按钮
  _buildSubscribeBtn(BuildContext context) {
    // final submitText = context
    //     .select<PurchaseProvider, String>((val) => val.submitText);
    final provider = context.read<PurchaseProvider>();
    return ScaleTransitionWidget(
      child: Container(
        margin: EdgeInsets.only(top: 13.h, bottom: 5.h),
        height: 60.h,
        child: ByWidgetsUtil.gradientBtn(
          // title: /*submitText*/ '立即解锁',
          title: provider.memberBtnTxt,
          fontSize: 18.sp,
          onClick: () {
            toPay();
          },
          fontWeight: FontWeight.bold,
          borderRadius: 50,
          gradient: ByColorUtil.lineareGradient(
            colorStart: const Color(0xFFFF387A),
            colorEnd: const Color(0xFFFF6B6B),
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }

  /// 协议
  _buildAgreement(BuildContext context) {
    final provider = context.read<PurchaseProvider>();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 如果没有展示选择按钮且是默认同意状态，点击协议文字不应取消同意
        if (provider.agreementNum && provider.isAgreementChecked) return;
        provider.agreementCheckedStatusChanged(!provider.isAgreementChecked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!provider.agreementNum)
                Image.asset(
                  provider.isAgreementChecked
                      ? "assets/purchase/dark/checked_dark.png"
                      : "assets/purchase/dark/uncheck_dark.png",
                  height: 15.h,
                  color: const Color(0xFFFF3564),
                  fit: BoxFit.fitHeight,
                ),
              if (!provider.agreementNum) SizedBox(width: 5.w),
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    ByWidgetsUtil.commonRichText(
                      texts: [
                        const TextSpan(text: "我已阅读并同意"),
                        TextSpan(
                          text: "《会员服务协议》",
                          style: const TextStyle(
                            color: ByColorUtil.TabTextColorSelected,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              debugPrint(
                                "open Url:${provider.vipPageBean?.user.protocolUrl}",
                              );
                              if (provider
                                  .vipPageBean!
                                  .user
                                  .protocolUrl
                                  .isEmpty)
                                return;
                              ByNavRouterUtils.jumpWebViewPage(
                                context,
                                "",
                                provider.vipPageBean?.user.protocolUrl ?? "",
                              );
                            },
                        ),
                        if (provider.isShowIntegralAgreement)
                          TextSpan(
                            text: "《积分服务协议》",
                            style: const TextStyle(
                              color: ByColorUtil.TabTextColorSelected,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                debugPrint(
                                  "open Url:${provider.vipPageBean?.user.integralRule}",
                                );
                                if (provider
                                    .vipPageBean!
                                    .user
                                    .integralRule
                                    .isEmpty) {
                                  return;
                                }
                                ByNavRouterUtils.jumpWebViewPage(
                                  context,
                                  "",
                                  provider.vipPageBean?.user.integralRule ?? "",
                                );
                              },
                          ),
                      ],
                      fontSize: 12.sp,
                      textColor:
                          ByColorUtil.LoginTextfieldTextColor.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showExitConfirmationDialog(BuildContext context) async {
    LaunchProvider provider = context.read<LaunchProvider>();

    if (provider.launchInfo?.isVip == 1) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        Get.offNamed(Routes.main);
      }
    } else {
      // print("isPreBack:${context.read<PurchaseProvider>().isPreBack}");
      if (context.read<PurchaseProvider>().isPreBack) {
        return await showDialog(
              context: context,
              builder: (ctx) {
                return ChangeNotifierProvider.value(
                  value: context.read<PurchaseProvider>(),
                  child: RetentionVipDailog(
                    markUrl:
                        context
                            .read<PurchaseProvider>()
                            .vipPageBean
                            ?.retainWindowUrl ??
                        '',
                  ),
                );
              },
            ) ??
            false;
      } else {
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        } else {
          Get.offNamed(Routes.main);
        }
      }
    }
  }

  /// 查询订单状态
  void _queryOrderStatus({String? loaddingText}) {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..maskType = EasyLoadingMaskType.custom
      ..indicatorType = EasyLoadingIndicatorType.cubeGrid
      ..indicatorColor = ByColorUtil.PurchasePriceTextColor
      ..loadingStyle = EasyLoadingStyle.light;
    EasyLoading.show(status: loaddingText, dismissOnTap: false);
    context.read<PurchaseProvider>().querryOrderStatus(
      onSuccess: () async {
        EasyLoading.dismiss();
        // showAddWxDialog();

        // 充值成功
        context.read<LaunchProvider>().launch(
          Get.context!,
          onSuccess: (LaunchInfoBean bean) {
            /// 更新个人信息
            Get.find<UserController>().reloadUserInfo(
              successAction: (userInfo) {
                debugPrint("isBindPhone:${userInfo?.isBindPhone == 1}");

                ///未绑定手机号
                if (userInfo?.isBindPhone == 0) {
                  userController.showBindPhoneDialog(needConfirm: true).then((
                    value,
                  ) {
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
      onFailed: () {
        EasyLoading.dismiss();
        // final provider = context.read<PurchaseProvider>();

        // Get.normalDialog(
        //   width: Get.width * 0.85,
        //   title: '确认失败',
        //   showCancelBtn: false,
        //   content: '获取订单失败，如果已支付请点击联系客服解决问题',
        //   confirmText: '联系客服',
        //   confirmAction: () {
        //     ByNavRouterUtils.jumpWebViewPage(
        //         context, '在线客服', provider.vipPageBean?.kfUrl ?? "");
        //   },
        // );
      },
    );
  }

  showAddWxDialog() async {
    HttpUtils.get(
      APIs.checkVipGuidStaus,
      {},
      showLoading: true,
      success: (data) async {
        final guidData = data["data"];
        final bean = PurchaseVipGuidBean.fromJson(guidData);
        final showKfGuide = bean.showKfGuide == 1;
        await showDialog(
          context: navigatorKey.currentState!.context,
          builder: (context) {
            return PurchaseSuccessDialog(
              contents: showKfGuide ? "微信添加老师，解决你的所有问题" : null,
              btnTtle: showKfGuide ? '立即添加老师' : null,
              webUrl: showKfGuide ? bean.kfUrl : null,
            );
          },
        );
        if (popWhenSuccess == true) {
          if (Navigator.canPop(context)) {
            ByNavRouterUtils.goBack(context);
          } else {
            Get.offNamed(Routes.main);
          }
        }
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  showSuccessDialog({String? title}) async {
    // 上报成为会员弹框显示
    _reportPayPageTopInfo("member_page_become_member_dialog", "view");

    Get.customDialog(
      barrierDismissible: false,
      widget:
          userController.payJumpImage.isNotEmpty &&
              userController.payJumpUrl.isNotEmpty
          ? PaySuccessNewDialog(
              onAddBtnTap: () {
                // 上报成为会员弹框立即添加按钮点击
                _reportPayPageTopInfo(
                  "member_page_become_member_add_btn",
                  "click",
                );
              },
              onCloseBtnTap: () {
                // 上报成为会员弹框关闭按钮点击
                _reportPayPageTopInfo(
                  "member_page_become_member_close_btn",
                  "click",
                );
              },
            )
          : PaySuccessDialog(
              title: title,
              onAddBtnTap: () {
                // 上报成为会员弹框立即添加按钮点击
                _reportPayPageTopInfo(
                  "member_page_become_member_add_btn",
                  "click",
                );
              },
              onCloseBtnTap: () {
                // 上报成为会员弹框关闭按钮点击
                _reportPayPageTopInfo(
                  "member_page_become_member_close_btn",
                  "click",
                );
              },
            ),
    ).then((_) {
      if (Navigator.canPop(context)) {
        ByNavRouterUtils.goBack(context);
      } else {
        Get.offNamed(Routes.main);
      }
    });
  }

  /// 页面曝光上报
  void _reportPageExposure() {
    // 确保只上报一次
    if (_hasReportedExposure) return;
    _hasReportedExposure = true;

    try {
      final currentProvider = provider;
      if (currentProvider != null &&
          currentProvider.vipTypeBeans.isNotEmpty &&
          currentProvider.selectedVIPTypeIndex <
              currentProvider.vipTypeBeans.length) {
        currentProvider.reportPayPageTopInfo(
          "member_page",
          null, // 没有图片，传空
          "view",
          vipId: currentProvider
              .vipTypeBeans[currentProvider.selectedVIPTypeIndex]
              .id
              .toString(),
        );
      }
    } catch (e) {
      debugPrint("_reportPageExposure error: $e");
    }
  }

  /// 统一上报方法
  void _reportPayPageTopInfo(
    String pageTag,
    String operateType, {
    String? vipId,
    int payType = 0,
  }) {
    final currentProvider = provider;
    if (currentProvider == null) return;

    final currentVipId =
        vipId ??
        (currentProvider.vipTypeBeans.isNotEmpty &&
                currentProvider.selectedVIPTypeIndex <
                    currentProvider.vipTypeBeans.length
            ? currentProvider
                  .vipTypeBeans[currentProvider.selectedVIPTypeIndex]
                  .id
                  .toString()
            : null);
    // 没有图片，传空
    final funcDetailImg = null;

    currentProvider.reportPayPageTopInfo(
      pageTag,
      funcDetailImg,
      operateType,
      vipId: currentVipId,
      payType: payType,
    );
  }

  _buildMain(BuildContext context) {
    final premiumTips = context.select<PurchaseProvider, String>(
      (val) => val.premiumTips,
    );
    return Positioned(
      left: 0,
      bottom: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.w),
            topRight: Radius.circular(18.w),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 3.h),
            const Row(children: [Spacer(), VIPCountDownWidget()]),
            SizedBox(height: 16.h),
            _buildVIPTypeListView(context),
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: BYText.instance(
                premiumTips,
                12.sp,
                color: ByColorUtil.color67441E,
                fontWeight: BYFontWeight.medium,
              ),
            ),
            SizedBox(height: 13.h),
            _buildPayMethods(context),
            _buildSubscribeBtn(context),
            _buildAgreement(context),
            SizedBox(height: 6.h + context.byBottomSafeHeight),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<PurchaseProvider>();
    if (state == AppLifecycleState.resumed) {
      if (provider.needShowDialog && !(Get.isDialogOpen ?? false)) {
        provider.needShowDialog = false;
        _queryOrderStatus(loaddingText: '确认支付中，请稍后...');
        // Get.normalDialog(
        //   width: Get.width * 0.85,
        //   title: '支付确认',
        //   content: '支付成功，请点击【已支付】\n如未支付成功，请点击【取消】',
        //   confirmText: '已支付',
        //   cancelAction: () {
        //     provider.needShowDialog = false;
        //   },
        //   confirmAction: () {
        //     provider.needShowDialog = false;
        //     _queryOrderStatus(loaddingText: '确认支付中，请稍后...');
        //   },
        // );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    /// 取消支付通知订阅
    provider?.cancelSubscribeWXPayResp();
    provider?.cancelSubscribeAliPayResp();
    EasyLoading.dismiss();
    // final isAudit = context.read<LaunchProvider>().launchInfo!.isAudit;
    // if (isAudit == 1) {
    //   provider?.agreementChecked = false;
    // }
    super.dispose();
  }
}
