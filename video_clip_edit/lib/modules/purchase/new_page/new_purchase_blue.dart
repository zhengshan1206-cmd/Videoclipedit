// ignore_for_file: use_build_context_synchronously
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/main.dart';
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
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/modules/purchase/beans/purchase_guid_bean.dart';
import 'package:video_clip_edit/modules/login/widgets/login_agreement_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/purchase_success_dialog.dart';
import '../../../flavors/build_config.dart';
import '../../../widgets/toast_util.dart';
import '../../home/widgets/sub_funcs_view.dart';
import 'widgets/new_purchase_vip_contdown.dart';
import 'widgets/new_purchase_vip_list.dart';
import 'widgets/new_purchase_vip_method.dart';
import '../mixins/purchase_page_back_mixin.dart';

class NewPurchasePageBlue extends StatefulWidget {
  final bool? closePay;

  const NewPurchasePageBlue({super.key, this.closePay});

  @override
  State<NewPurchasePageBlue> createState() => _NewPurchasePageBlueState();
}

class _NewPurchasePageBlueState extends State<NewPurchasePageBlue>
    with WidgetsBindingObserver, PurchasePageBackMixin {
  PurchaseProvider? provider;
  bool popWhenSuccess = false;
  bool _hasReportedExposure = false;

  // late IosPurchaseProvider _iosPurchaseProvider;
  SwiperController controller = SwiperController();

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
    provider?.loadIosVipBanner();
    provider?.preLoginConfig();

    /// 获取支付挽留配置信息（用于左上角关闭按钮触发挽留弹窗）
    provider?.getPopConfig();
  }

  /// 会员页曝光上报（PAGE_P_MEMBER_PAGE）
  void _reportPageExposure() {
    if (_hasReportedExposure) return;
    _hasReportedExposure = true;
    try {
      final p = provider;
      if (p != null &&
          p.vipTypeBeans.isNotEmpty &&
          p.selectedVIPTypeIndex < p.vipTypeBeans.length) {
        p.reportPayPageTopInfo(
          "member_page",
          p.vipPageTopDataList.isNotEmpty ? p.vipPageTopDataList.first : null,
          "view",
          vipId: p.vipTypeBeans[p.selectedVIPTypeIndex].id.toString(),
        );
      }
    } catch (e) {
      debugPrint("_reportPageExposure error: $e");
    }
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
        backgroundColor: Colors.black,
        body: Consumer<PurchaseProvider>(
          builder:
              (
                BuildContext context,
                PurchaseProvider purchaseProvider,
                Widget? child,
              ) {
                if (purchaseProvider.vipTypeBeans.isNotEmpty &&
                    !_hasReportedExposure) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _reportPageExposure();
                  });
                }
                return Stack(
                  children: [
                    ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: SizedBox(
                            width: 1.sw,
                            child: Stack(
                              children: [
                                _buildBannerView(context: context),
                                _bannerBottomView(context: context),
                              ],
                            ),
                          ),
                        ),
                        _buildTitle(),
                        _buildVIPTypeListView(context),
                        _buildPayMethods(context),
                        Padding(
                          padding: EdgeInsets.only(bottom: 7.h),
                          child: Row(
                            children: [
                              Container(
                                width: 2,
                                height: 12,
                                margin: const EdgeInsets.only(
                                  left: 12,
                                  right: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffffffff),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              const Text(
                                '会员专属权益',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xffffffff),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildVipContent(),
                        SizedBox(height: 150.w),
                      ],
                    ),
                    Positioned(
                      bottom: 0.w,
                      left: 0.w,
                      right: 0.w,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 20,
                            width: 1.sw,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xff000000).withOpacity(0.0),
                                  const Color(0xff000000).withOpacity(1),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.black,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const NewVIPCountDownWidget(),
                                _buildSubscribeBtn(context),
                                _buildAgreement(context),
                                SizedBox(height: 18.w),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _closeView(),
                  ],
                );
              },
        ),
      ),
    );
  }

  ///关闭按钮
  Widget _closeView() {
    return Positioned(
      left: 12.w,
      top: 45.w,
      child: GestureDetector(
        onTap: () async {
          await _handleBack();
        },
        child: Image.asset(
          "assets/purchase/new/ios_close.png",
          width: 32.w,
          height: 32.w,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  ///处理返回逻辑
  Future<void> _handleBack() async {
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
      Get.back();
    } else {
      Get.offNamed(Routes.main);
    }
  }

  ///展示二次购买弹窗
  void _showAgainPurchaseDialog() async {
    LaunchProvider provider = context.read<LaunchProvider>();
    if (provider.launchInfo?.isVip == 1) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        Get.offNamed(Routes.main);
      }
      return;
    }
    final pop =
        await showDialog(
          context: context,
          builder: (ctx) {
            return ChangeNotifierProvider.value(
              value: context.read<PurchaseProvider>(),
              // child: const DailogBonusGivnup(),
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

    if (pop) {
      _goBack();
    }
  }

  /// 开通会员文案
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      child: Image.asset(Assets.purchaseOpenVipBlue, height: 60.h),
    );
  }

  /// 会员专属权益
  Widget _buildVipContent() {
    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 4,
      childAspectRatio: 1.7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children:
          provider?.vipRightsBeans.map((e) {
            return Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(e.icon, width: 32, height: 32),
                  Text(
                    e.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xffffffff),
                    ),
                  ),
                ],
              ),
            );
          }).toList() ??
          [],
    );
  }

  ///Vip轮播区域
  Widget _buildBannerView({required BuildContext context}) {
    List<SubFunction> menuItemBeans = context
        .select<PurchaseProvider, List<SubFunction>>(
          (provider) => provider.menuItemBeans,
        );
    return SizedBox(
      width: 1.sw,
      child: Swiper(
        autoplay: true,
        itemCount: menuItemBeans.length,
        controller: controller,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: menuItemBeans[index].imgUrl,
            width: 1.sw,
            height: 140.w,
            fit: BoxFit.fitWidth,
          );
        },
        pagination: SwiperPagination(
          margin: EdgeInsets.zero,
          builder: SwiperCustomPagination(
            builder: (BuildContext context, SwiperPluginConfig config) {
              return Container(
                margin: EdgeInsets.only(bottom: 80.w, left: 8.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(menuItemBeans.length, (index) {
                    final isCurrent = index == config.activeIndex;
                    return Container(
                      width: isCurrent ? 12.h : 6.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Colors.white
                            : Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(1.5.w),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                    );
                  }),
                ),
              );
            },
          ),
        ),
        onIndexChanged: (value) {
          provider?.updateLoopIndex(index: value);
        },
      ),
    );
  }

  ///金刚卫
  Widget _bannerBottomView({required BuildContext context}) {
    List<SubFunction> menuItemBeans2 = context
        .select<PurchaseProvider, List<SubFunction>>(
          (provider) => provider.menuItemBeans2,
        );
    // Get.log("构建金刚卫===view===");
    return Positioned(
      bottom: 0,
      left: 8.w,
      child: Row(
        children: List.generate(menuItemBeans2.length, (index) {
          return GestureDetector(
            onTap: () {
              controller.move(index);
            },
            child: _bannerItemView(
              iconPath: menuItemBeans2[index].imgUrl,
              title: menuItemBeans2[index].des,
              index: index,
            ),
          );
        }),
      ),
    );
  }

  /// 金刚位item
  Widget _bannerItemView({
    required String iconPath,
    required String title,
    required int index,
  }) {
    return BannerItemView(iconPath: iconPath, title: title, index: index);
  }

  /// 支付列表
  Widget _buildVIPTypeListView(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10),
      child: NewVipListViewNew(),
    );
  }

  /// 支付方式
  Widget _buildPayMethods(BuildContext context) {
    final provider = context.read<PurchaseProvider>();
    final payMethodBeans = provider.payMethodBeans;

    return payMethodBeans.isEmpty
        ? const SizedBox.shrink()
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xff191C22),
            ),
            height: 44.h,
            margin: EdgeInsets.all(12.h),
            padding: EdgeInsets.only(left: 12.w, right: 12.w),
            child: Builder(
              builder: (context) {
                final PurchaseProvider provider = context
                    .read<PurchaseProvider>();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NewVipMethodViewNew(
                      payMethodBean:
                          payMethodBeans[provider.selectedPayMethodIndex],
                    ),
                    GestureDetector(
                      onTap: () {
                        var selectedIndex = provider.selectedPayMethodIndex + 1;
                        //当前是最后一种支付方式时，切换轮回第一种支付方式
                        if (selectedIndex == payMethodBeans.length) {
                          selectedIndex = 0;
                        }
                        provider.changeSelectedPayMethodIndex(selectedIndex);
                      },
                      child: Image.asset(
                        Assets.purchaseMethodChange,
                        width: 18,
                        height: 16,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
  }

  void toPay({bool popPay = false, bool retentionPop = false}) {
    final provider = context.read<PurchaseProvider>();

    // 上报开通按钮点击
    provider.reportPayPageTopInfo(
      "member_page_open_btn",
      null,
      "click",
      vipId:
          provider.vipTypeBeans.isNotEmpty &&
              provider.selectedVIPTypeIndex < provider.vipTypeBeans.length
          ? provider.vipTypeBeans[provider.selectedVIPTypeIndex].id.toString()
          : null,
    );

    if (!provider.isAgreementChecked) {
      // 上报协议弹窗显示
      provider.reportPayPageTopInfo(
        "member_page_renew_protocol_dialog",
        null,
        "view",
        vipId:
            provider.vipTypeBeans.isNotEmpty &&
                provider.selectedVIPTypeIndex < provider.vipTypeBeans.length
            ? provider.vipTypeBeans[provider.selectedVIPTypeIndex].id.toString()
            : null,
      );

      showDialog(
        context: context,
        builder: (context) {
          return LoginAgreementView(
            color1: const Color(0XFF5B4BF7),
            btnTitle: "成为会员",
            registerMember: true,
            callback: () {
              // 上报协议弹窗开通按钮点击
              provider.reportPayPageTopInfo(
                "member_page_renew_protocol_open_btn",
                null,
                "click",
                vipId:
                    provider.vipTypeBeans.isNotEmpty &&
                        provider.selectedVIPTypeIndex <
                            provider.vipTypeBeans.length
                    ? provider.vipTypeBeans[provider.selectedVIPTypeIndex].id
                          .toString()
                    : null,
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
              provider.reportPayPageTopInfo(
                "member_page_renew_protocol_close_btn",
                null,
                "click",
                vipId:
                    provider.vipTypeBeans.isNotEmpty &&
                        provider.selectedVIPTypeIndex <
                            provider.vipTypeBeans.length
                    ? provider.vipTypeBeans[provider.selectedVIPTypeIndex].id
                          .toString()
                    : null,
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
  Widget _buildSubscribeBtn(BuildContext context) {
    // final submitText = context
    //     .select<PurchaseProvider, String>((val) => val.submitText);
    final provider = context.read<PurchaseProvider>();
    return ScaleTransitionWidget(
      child: Container(
        margin: EdgeInsets.only(top: 17.h, bottom: 10.h),
        height: 54.h,
        child: ByWidgetsUtil.gradientBtn(
          // title: /*submitText*/ '立即解锁',
          title: provider.memberBtnTxt,
          fontSize: 18.sp,
          onClick: () {
            toPay();
          },
          fontWeight: FontWeight.bold,
          borderRadius: 27,
          gradient: ByColorUtil.lineareGradient(
            colorStart: const Color(0xFF5B4BF7),
            colorEnd: const Color(0xFF5B4BF7),
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }

  /// 协议
  Widget _buildAgreement(BuildContext context) {
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
                  color: Colors.white,
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
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
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
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
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
                      textColor: Colors.white.withOpacity(0.6),
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
        //       context,
        //       '在线客服',
        //       provider.vipPageBean?.kfUrl ?? "",
        //     );
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
    final p = provider;
    if (p != null) {
      p.reportPayPageTopInfo(
        "member_page_become_member_dialog",
        p.vipPageTopDataList.isNotEmpty ? p.vipPageTopDataList.first : null,
        "view",
        vipId: p.vipTypeBeans.isNotEmpty &&
                p.selectedVIPTypeIndex < p.vipTypeBeans.length
            ? p.vipTypeBeans[p.selectedVIPTypeIndex].id.toString()
            : null,
      );
    }
    Get.customDialog(
      barrierDismissible: false,
      widget:
          userController.payJumpImage.isNotEmpty &&
              userController.payJumpUrl.isNotEmpty
          ? PaySuccessNewDialog(
              onAddBtnTap: () {
                provider?.reportPayPageTopInfo(
                  "member_page_become_member_add_btn",
                  provider?.vipPageTopDataList.isNotEmpty == true
                      ? provider!.vipPageTopDataList.first
                      : null,
                  "click",
                  vipId: provider?.vipTypeBeans.isNotEmpty == true &&
                          (provider?.selectedVIPTypeIndex ?? 0) <
                              (provider?.vipTypeBeans.length ?? 0)
                      ? provider!
                          .vipTypeBeans[provider!.selectedVIPTypeIndex].id
                          .toString()
                      : null,
                );
              },
              onCloseBtnTap: () {
                provider?.reportPayPageTopInfo(
                  "member_page_become_member_close_btn",
                  provider?.vipPageTopDataList.isNotEmpty == true
                      ? provider!.vipPageTopDataList.first
                      : null,
                  "click",
                  vipId: provider?.vipTypeBeans.isNotEmpty == true &&
                          (provider?.selectedVIPTypeIndex ?? 0) <
                              (provider?.vipTypeBeans.length ?? 0)
                      ? provider!
                          .vipTypeBeans[provider!.selectedVIPTypeIndex].id
                          .toString()
                      : null,
                );
              },
            )
          : PaySuccessDialog(
              title: title,
              onAddBtnTap: () {
                provider?.reportPayPageTopInfo(
                  "member_page_become_member_add_btn",
                  provider?.vipPageTopDataList.isNotEmpty == true
                      ? provider!.vipPageTopDataList.first
                      : null,
                  "click",
                  vipId: provider?.vipTypeBeans.isNotEmpty == true &&
                          (provider?.selectedVIPTypeIndex ?? 0) <
                              (provider?.vipTypeBeans.length ?? 0)
                      ? provider!
                          .vipTypeBeans[provider!.selectedVIPTypeIndex].id
                          .toString()
                      : null,
                );
              },
              onCloseBtnTap: () {
                provider?.reportPayPageTopInfo(
                  "member_page_become_member_close_btn",
                  provider?.vipPageTopDataList.isNotEmpty == true
                      ? provider!.vipPageTopDataList.first
                      : null,
                  "click",
                  vipId: provider?.vipTypeBeans.isNotEmpty == true &&
                          (provider?.selectedVIPTypeIndex ?? 0) <
                              (provider?.vipTypeBeans.length ?? 0)
                      ? provider!
                          .vipTypeBeans[provider!.selectedVIPTypeIndex].id
                          .toString()
                      : null,
                );
              },
            ),
    ).then((_) {
      final launchProvider = context.read<LaunchProvider>();
      if (launchProvider.isFolkStoryPayback) {
        _folkStorySuccussPayBack();
      } else {
        _goBack();
      }
    });
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

  //民间故事支付成功后弹出成功页面
  void _folkStorySuccussPayBack() {
    final launchProvider = context.read<LaunchProvider>();
    if (launchProvider.isFolkStoryPayback) {
      Get.toNamed(Routes.folkStorySuccessPayback);
    }
  }
}

class BannerItemView extends StatelessWidget {
  final String iconPath;
  final String title;
  final int index;

  const BannerItemView({
    super.key,
    required this.iconPath,
    required this.title,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final loopIndex = context.select<PurchaseProvider, int>(
      (provider) => provider.loopIndex,
    );
    return Container(
      margin: EdgeInsets.only(right: 7.w),
      width: 54.w,
      height: 64.w,
      decoration: BoxDecoration(
        color: const Color(0XFF1E2022).withOpacity(0.6),
        border: Border.all(
          width: 0.5,
          color: index == loopIndex
              ? const Color(0XFF707478).withOpacity(0.5)
              : const Color(0XFF2D3032).withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: index == loopIndex ? 1 : 0.5,
            child: CachedNetworkImage(
              imageUrl: iconPath,
              width: 24.w,
              height: 24.w,
            ),
          ),
          SizedBox(height: 10.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w400,
              color: index == loopIndex
                  ? Colors.white
                  : const Color(0XFFFFFFFF).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
