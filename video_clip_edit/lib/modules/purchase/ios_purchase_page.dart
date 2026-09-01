import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/modules/purchase/widgets/ios_purchase_agreement_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/new_ios_vip_list_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/pay_success_dialog.dart';
import 'package:video_clip_edit/modules/purchase/widgets/pay_success_new_dialog.dart';
import 'package:video_clip_edit/modules/purchase/widgets/retention_vip_dailog.dart';
import 'package:video_clip_edit/modules/purchase/widgets/vip_count_down_view%20copy.dart';
import 'package:video_clip_edit/providers/ios_purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import '../../controller/user_controller.dart';
import '../../providers/launch_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../routes/app_pages.dart';
import '../../utils/comon/by_colors.dart';
import '../../utils/comon/by_nav_router_utils.dart';
import '../../utils/comon/by_screen_utils.dart';
import '../../utils/comon/by_widgets_util.dart';
import '../../utils/pay/ios_buy_engine.dart';
import '../../v2/aiSquare/widgets/ai_video_player.dart';
import '../home/widgets/sub_funcs_view.dart';
import '../main/beans/launch_info_bean.dart';
import 'mixins/purchase_page_back_mixin.dart';

///苹果支付页面
class IosPurchasePage extends StatefulWidget {
  const IosPurchasePage({super.key});

  @override
  State<IosPurchasePage> createState() => _IosPurchasePageState();
}

class _IosPurchasePageState extends State<IosPurchasePage>
    with PurchasePageBackMixin {
  late IosPurchaseProvider _iosPurchaseProvider;
  SwiperController controller = SwiperController();

  ///苹果支付成功后查询订单状态的监听
  late StreamSubscription _iosPaySuccessSubscription;

  late StreamSubscription _iosBuyStreamSubscription;
  bool _hasReportedExposure = false;

  @override
  void initState() {
    super.initState();
    _iosPurchaseProvider = context.read<IosPurchaseProvider>();
    _iosPurchaseProvider.resetFirstLayerRetentionForSession();
    _iosPurchaseProvider.iosBuyEngin.initializeInAppPurchase();
    _iosPurchaseProvider.loadIosVipBanner();
    _iosPurchaseProvider.loadVipData();
    _iosPurchaseProvider.preLoginConfig();

    /// 获取支付挽留配置信息（用于左上角关闭按钮触发挽留弹窗）
    _iosPurchaseProvider.getPopConfig();

    iniIosPaySuccessSubscription();
  }

  ///Vip轮播区域
  Widget _buildBannerView({required BuildContext context}) {
    List<SubFunction> menuItemBeans = context
        .select<IosPurchaseProvider, List<SubFunction>>(
          (provider) => provider.menuItemBeans,
        );
    return SizedBox(
      height: 1.sh,
      child: ListView(
        padding: EdgeInsets.only(top: 0, bottom: 230.h),
        children: [
          Stack(
            children: [
              SizedBox(
                width: 1.sw,
                height: 1.sw,
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
                      builder:
                          (BuildContext context, SwiperPluginConfig config) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 80.w, left: 8.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: List.generate(menuItemBeans.length, (
                                  index,
                                ) {
                                  final isCurrent = index == config.activeIndex;
                                  return Container(
                                    width: isCurrent ? 12.h : 6.w,
                                    height: 3.w,
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? Colors.white
                                          : Colors.grey.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(
                                        1.5.w,
                                      ),
                                    ),
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                    ),
                                  );
                                }),
                              ),
                            );
                          },
                    ),
                  ),
                  onIndexChanged: (value) {
                    _iosPurchaseProvider.updateLoopIndex(index: value);
                  },
                ),
              ),
              _bannerBottomView(context: context),
            ],
          ),
          SizedBox(height: 20.w),
          Image.asset(
            "assets/purchase/new/ios_purchase_comment_bg.png",
            width: ByScreenUtils.screenWidth,
            fit: BoxFit.fitWidth,
          ),
        ],
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

  ///恢复购买 购买区域
  Widget _restorePurchaseView() {
    return Positioned(
      right: 12.w,
      top: 45.w,
      child: InkResponse(
        onTap: () {
          _iosPurchaseProvider.iosRepair(
            onSuccess: () {
              context.read<LaunchProvider>().launch(
                Get.context!,
                onSuccess: (LaunchInfoBean bean) {
                  /// 更新个人信息
                  Get.find<UserController>().reloadUserInfo(
                    successAction: (userInfo) {
                      debugPrint("isBindPhone:${userInfo?.isBindPhone == 1}");

                      ///未绑定手机号
                      if (userInfo?.isBindPhone == 0) {
                        userController
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
        },
        child: Container(
          padding: EdgeInsets.only(
            left: 6.w,
            right: 6.w,
            top: 3.w,
            bottom: 3.w,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0XFF000000).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Text(
            "恢复购买",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }

  ///金刚卫
  Widget _bannerBottomView({required BuildContext context}) {
    List<SubFunction> menuItemBeans2 = context
        .select<IosPurchaseProvider, List<SubFunction>>(
          (provider) => provider.menuItemBeans2,
        );
    Get.log("构建金刚卫===view===");
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

  ///
  Widget _bannerItemView({
    required String iconPath,
    required String title,
    required int index,
  }) {
    return BannerItemView(iconPath: iconPath, title: title, index: index);
  }

  ///购买套餐
  Widget _payView() {
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
            SizedBox(height: 16.h),
            _text(),
            // SizedBox(height: 13.h),
            _buildSubscribeBtn(context),
            _buildAgreement(context),
            SizedBox(height: 6.h + context.byBottomSafeHeight),
          ],
        ),
      ),
    );
  }

  /// 支付列表
  _buildVIPTypeListView(BuildContext context) {
    return const NewIosVipListView();
  }

  /// 订阅按钮
  _buildSubscribeBtn(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 13.h, bottom: 5.h),
      height: 60.h,
      child: ByWidgetsUtil.gradientBtn(
        title: "立即解锁",
        fontSize: 18.sp,
        onClick: () {
          // 上报开通按钮点击
          _reportPayPageTopInfo("member_page_open_btn", "click");
          _toPay();
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
    );
  }

  /// 协议
  _buildAgreement(BuildContext context) {
    bool agreementChecked = context.select<IosPurchaseProvider, bool>(
      (provider) => provider.agreementChecked,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _iosPurchaseProvider.agreementCheckedStatusChanged(
          !_iosPurchaseProvider.agreementChecked,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                agreementChecked
                    ? "assets/purchase/dark/checked_dark.png"
                    : "assets/purchase/dark/uncheck_dark.png",
                height: 15.h,
                color: const Color(0xFFFF3564),
                fit: BoxFit.fitHeight,
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    ByWidgetsUtil.commonRichText(
                      texts: [
                        const TextSpan(text: "同意"),
                        TextSpan(
                          text: "《会员服务协议》",
                          style: const TextStyle(
                            color: ByColorUtil.TabTextColorSelected,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              debugPrint(
                                "open Url:${_iosPurchaseProvider.vipPageBean?.user.protocolUrl}",
                              );
                              if (_iosPurchaseProvider
                                  .vipPageBean!
                                  .user
                                  .protocolUrl
                                  .isEmpty)
                                return;
                              ByNavRouterUtils.jumpWebViewPage(
                                context,
                                "",
                                _iosPurchaseProvider
                                        .vipPageBean
                                        ?.user
                                        .protocolUrl ??
                                    "",
                              );
                            },
                        ),
                        const TextSpan(text: "和"),
                        TextSpan(
                          text: "《自动续费服务协议》",
                          style: const TextStyle(
                            color: ByColorUtil.TabTextColorSelected,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              debugPrint(
                                "open Url:${_iosPurchaseProvider.vipPageBean?.user.subScribeProtocolUrl}",
                              );
                              if (_iosPurchaseProvider
                                  .vipPageBean!
                                  .user
                                  .protocolUrl
                                  .isEmpty)
                                return;
                              ByNavRouterUtils.jumpWebViewPage(
                                context,
                                "",
                                _iosPurchaseProvider
                                        .vipPageBean
                                        ?.user
                                        .subScribeProtocolUrl ??
                                    "",
                              );
                            },
                        ),
                        if (_iosPurchaseProvider.isShowIntegralAgreement)
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "和",
                                style: TextStyle(
                                  color: ByColorUtil.TabTextColorSelected,
                                ),
                              ),
                              TextSpan(
                                text: "《积分服务协议》",
                                style: const TextStyle(
                                  color: ByColorUtil.TabTextColorSelected,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    debugPrint(
                                      "open Url:${_iosPurchaseProvider.vipPageBean?.user.integralRule}",
                                    );
                                    if (_iosPurchaseProvider
                                        .vipPageBean!
                                        .user
                                        .integralRule
                                        .isEmpty)
                                      return;
                                    ByNavRouterUtils.jumpWebViewPage(
                                      context,
                                      "",
                                      _iosPurchaseProvider
                                              .vipPageBean
                                              ?.user
                                              .integralRule ??
                                          "",
                                    );
                                  },
                              ),
                            ],
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

  /// 查询订单状态
  void _queryOrderStatus({required String receiptData}) {
    context.read<IosPurchaseProvider>().queryOrderStatus(
      receiptData: receiptData,
      onSuccess: () async {},
    );
  }

  // showAddWxDialog() async {
  //   HttpUtils.get(
  //     APIs.checkVipGuidStaus,
  //     {},
  //     showLoading: true,
  //     success: (data) async {
  //       final guidData = data["data"];
  //       final bean = PurchaseVipGuidBean.fromJson(guidData);
  //       final showKfGuide = bean.showKfGuide == 1;
  //       await showDialog(
  //         context: navigatorKey.currentState!.context,
  //         builder: (context) {
  //           return PurchaseSuccessDialog(
  //             contents: showKfGuide ? "微信添加老师，解决你的所有问题" : null,
  //             btnTtle: showKfGuide ? '立即添加老师' : null,
  //             webUrl: showKfGuide ? bean.kfUrl : null,
  //           );
  //         },
  //       );
  //       if (popWhenSuccess == true) {
  //         if (Navigator.canPop(context)) {
  //           ByNavRouterUtils.goBack(context);
  //         } else {
  //           Get.offNamed(Routes.MAIN);
  //         }
  //       }
  //     },
  //     fail: (code, msg) {
  //       BotToast.showText(text: msg);
  //     },
  //   );
  // }

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
        ///todo 支付成功后通知上一页面
        ByNavRouterUtils.goBack(context);
      } else {
        Get.offNamed(Routes.main);
      }
    });
  }

  /// 统一上报方法
  void _reportPayPageTopInfo(
    String pageTag,
    String operateType, {
    String? vipId,
    int payType = 0,
  }) {
    final currentVipId =
        vipId ??
        (_iosPurchaseProvider.vipTypeBeans.isNotEmpty &&
                _iosPurchaseProvider.selectedVIPTypeIndex <
                    _iosPurchaseProvider.vipTypeBeans.length
            ? _iosPurchaseProvider
                  .vipTypeBeans[_iosPurchaseProvider.selectedVIPTypeIndex]
                  .id
                  .toString()
            : null);
    // 没有图片，传空
    final funcDetailImg = null;

    _iosPurchaseProvider.reportPayPageTopInfo(
      pageTag,
      funcDetailImg,
      operateType,
      vipId: currentVipId,
      payType: payType,
    );
  }

  Widget _text() {
    String showText = context.select<IosPurchaseProvider, String>(
      (provider) => provider.showHintText,
    );
    return Text(
      showText,
      style: TextStyle(
        color: const Color(0XFF0B1843).withOpacity(0.25),
        fontWeight: FontWeight.w400,
        fontSize: 11.sp,
      ),
    );
  }

  @override
  void dispose() {
    _iosBuyStreamSubscription.cancel();
    _iosPaySuccessSubscription.cancel();
    super.dispose();
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
        _toPay(popPay: true, retentionPop: true);
      },
      onGoBack: _goBack,
    );
  }

  ///支付方法
  void _toPay({bool popPay = false, bool retentionPop = false}) {
    final provider = context.read<IosPurchaseProvider>();
    if (!provider.agreementChecked) {
      // 上报协议弹窗显示
      _reportPayPageTopInfo("member_page_renew_protocol_dialog", "view");

      bool hasClickedConfirm = false;
      showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) {
          return IosPurchaseAgreementView(
            iosPurchaseProvider: _iosPurchaseProvider,
            btnTitle: "成为会员",
            registerMember: true,
            callback: () {
              hasClickedConfirm = true;
              // 上报协议弹窗开通按钮点击
              _reportPayPageTopInfo(
                "member_page_renew_protocol_open_btn",
                "click",
              );

              provider.agreementCheckedStatusChanged(true);

              /// 创建 iOS 订单
              provider.createIosOrder(
                onSuccess: (payOrderBean) {},
                context: context,
                popPay: popPay,
                retentionPop: retentionPop,
              );
            },
            color1: const Color(0xFFFF387A),
          );
        },
      ).then((_) {
        // 只有在用户没有点击确认按钮时才上报关闭
        if (!hasClickedConfirm) {
          _reportPayPageTopInfo(
            "member_page_renew_protocol_close_btn",
            "click",
          );
        }
      });
      return;
    }
    provider.createIosOrder(
      onSuccess: (payOrderBean) {
        // Navigator.pop(context);
      },
      context: context,
      popPay: popPay,
      retentionPop: retentionPop,
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

  @override
  Widget build(BuildContext context) {
    // 数据加载完成后进行曝光上报（只上报一次）
    final provider = context.watch<IosPurchaseProvider>();
    if (provider.vipTypeBeans.isNotEmpty && !_hasReportedExposure) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _reportPageExposure();
        }
      });
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            _buildBannerView(context: context),
            _closeView(),
            _restorePurchaseView(),
            _payView(),
          ],
        ),
      ),
    );
  }

  /// 页面曝光上报
  void _reportPageExposure() {
    // 确保只上报一次
    if (_hasReportedExposure) return;
    _hasReportedExposure = true;

    try {
      if (_iosPurchaseProvider.vipTypeBeans.isNotEmpty &&
          _iosPurchaseProvider.selectedVIPTypeIndex <
              _iosPurchaseProvider.vipTypeBeans.length) {
        _iosPurchaseProvider.reportPayPageTopInfo(
          "member_page",
          null, // 没有图片，传空
          "view",
          vipId: _iosPurchaseProvider
              .vipTypeBeans[_iosPurchaseProvider.selectedVIPTypeIndex]
              .id
              .toString(),
        );
      }
    } catch (e) {
      debugPrint("_reportPageExposure error: $e");
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
    final loopIndex = context.select<IosPurchaseProvider, int>(
      (provider) => provider.loopIndex,
    );
    return Container(
      margin: EdgeInsets.only(right: 7.w),
      width: 54.w,
      height: 64.w,
      decoration: BoxDecoration(
        color: const Color(0XFF1E2022),
        border: Border.all(
          width: 0.5,
          color: index == loopIndex
              ? const Color(0XFF707478)
              : const Color(0XFF2D3032),
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
