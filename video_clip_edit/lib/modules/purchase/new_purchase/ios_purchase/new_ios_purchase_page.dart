import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/modules/purchase/new_page/widgets/new_purchase_vip_contdown.dart';
import 'package:video_clip_edit/modules/purchase/new_purchase/ios_purchase/new_ios_vip_list_view_ex.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/modules/purchase/widgets/dailog_bonus_givnup.dart';
import 'package:video_clip_edit/modules/purchase/widgets/ios_purchase_agreement_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/new_ios_vip_list_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/pay_success_dialog.dart';
import 'package:video_clip_edit/modules/purchase/widgets/pay_success_new_dialog.dart';
import 'package:video_clip_edit/modules/purchase/widgets/retention_vip_dailog.dart';
import 'package:video_clip_edit/modules/purchase/widgets/vip_count_down_view%20copy.dart';
import 'package:video_clip_edit/providers/ios_purchase_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import '../../../../controller/user_controller.dart';
import '../../../../providers/launch_provider.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/comon/by_colors.dart';
import '../../../../utils/comon/by_nav_router_utils.dart';
import '../../../../utils/comon/by_screen_utils.dart';
import '../../../../utils/comon/by_widgets_util.dart';
import '../../../../utils/pay/ios_buy_engine.dart';
import '../../../../v2/aiSquare/widgets/ai_video_player.dart';
import '../../../home/widgets/sub_funcs_view.dart';
import '../../../main/beans/launch_info_bean.dart';
import '../../mixins/purchase_page_back_mixin.dart';
import 'ui_type_enum.dart';

///苹果支付页面
class NewIosPurchasePage extends StatefulWidget {
  const NewIosPurchasePage({super.key, this.type = PurchaseUiType.Blue});

  final PurchaseUiType type; // 支付ui类型，Blue、Red

  @override
  State<NewIosPurchasePage> createState() => _NewIosPurchasePageState();
}

class _NewIosPurchasePageState extends State<NewIosPurchasePage>
    with PurchasePageBackMixin {
  late IosPurchaseProvider _iosPurchaseProvider;
  SwiperController controller = SwiperController();

  ///苹果支付成功后查询订单状态的监听
  late StreamSubscription _iosPaySuccessSubscription;

  late StreamSubscription _iosBuyStreamSubscription;

  late PurchaseUiType type; // 1 2 指向的不同付费配置模式（3.10.17版本只是UI不同） 1蓝色，2红色
  bool _hasReportedExposure = false;

  @override
  void initState() {
    super.initState();
    type = widget.type;
    _iosPurchaseProvider = context.read<IosPurchaseProvider>();
    _iosPurchaseProvider.resetFirstLayerRetentionForSession();
    _iosPurchaseProvider.iosBuyEngin.initializeInAppPurchase();
    _iosPurchaseProvider.loadIosVipBanner();
    _iosPurchaseProvider.loadVipData();
    _iosPurchaseProvider.preLoginConfig();

    /// 获取支付挽留配置信息（用于左上角关闭按钮触发挽留弹窗）
    _iosPurchaseProvider.getPopConfig();

    initData();
    iniIosPaySuccessSubscription();
  }

  initData() {
    final isAudit = context.read<LaunchProvider>().launchInfo!.isAudit;
    Get.log("isAudit====> $isAudit");
    if (isAudit == 1) {
      Future.microtask(() {
        _iosPurchaseProvider.agreementCheckedStatusChanged(false);
      });
    }
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
          SizedBox(height: 10.w),

          ///历史版本的用户评价图
          // Image.asset(
          //   "assets/purchase/new/ios_purchase_comment_bg.png",
          //   width: ByScreenUtils.screenWidth,
          //   fit: BoxFit.fitWidth,
          // ),
          _openVipAreaView(),
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
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.8),
                width: 1,
              ),
            ),
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

  Widget _bannerItemView({
    required String iconPath,
    required String title,
    required int index,
  }) {
    return BannerItemView(iconPath: iconPath, title: title, index: index);
  }

  /// 订阅按钮
  _buildSubscribeBtn(BuildContext context) {
    String memberBtnTxt = context.select<IosPurchaseProvider, String>(
      (provider) => provider.memberBtnTxt,
    );

    return ScaleTransitionWidget(
      child: Container(
        margin: EdgeInsets.only(top: 17.h, bottom: 10.h),
        height: 54.h,
        child: GestureDetector(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: type.color,
              borderRadius: BorderRadius.circular(27.w),
            ),
            child: Text(
              memberBtnTxt,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          onTap: () {
            // 上报开通按钮点击
            final provider = context.read<IosPurchaseProvider>();
            provider.reportPayPageTopInfo(
              "member_page_open_btn",
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
            _toPay();
          },
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
                color: Colors.white,
                fit: BoxFit.fitHeight,
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    ByWidgetsUtil.commonRichText(
                      texts: [
                        TextSpan(
                          text: "同意",
                          style: TextStyle(
                            color: const Color(0xFFFFFFFF).withOpacity(0.6),
                          ),
                        ),
                        TextSpan(
                          text: "《会员服务协议》",
                          style: TextStyle(
                            color: const Color(0xFFFFFFFF).withOpacity(0.6),
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
                        TextSpan(
                          text: "和",
                          style: TextStyle(
                            color: const Color(0xFFFFFFFF).withOpacity(0.6),
                          ),
                        ),
                        TextSpan(
                          text: "《自动续费服务协议》",
                          style: TextStyle(
                            color: const Color(0xFFFFFFFF).withOpacity(0.6),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              debugPrint(
                                "open Url:${_iosPurchaseProvider.vipPageBean?.user.subScribeProtocolUrl}",
                              );
                              if (_iosPurchaseProvider
                                  .vipPageBean!
                                  .user
                                  .subScribeProtocolUrl
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
                              TextSpan(
                                text: "和",
                                style: TextStyle(
                                  color: const Color(
                                    0xFFFFFFFF,
                                  ).withOpacity(0.6),
                                ),
                              ),
                              TextSpan(
                                text: "《积分服务协议》",
                                style: TextStyle(
                                  color: const Color(
                                    0xFFFFFFFF,
                                  ).withOpacity(0.6),
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
    final p = _iosPurchaseProvider;
    p.reportPayPageTopInfo(
      "member_page_become_member_dialog",
      p.vipPageTopDataList.isNotEmpty ? p.vipPageTopDataList.first : null,
      "view",
      vipId: p.vipTypeBeans.isNotEmpty &&
              p.selectedVIPTypeIndex < p.vipTypeBeans.length
          ? p.vipTypeBeans[p.selectedVIPTypeIndex].id.toString()
          : null,
    );
    Get.customDialog(
      barrierDismissible: false,
      widget:
          userController.payJumpImage.isNotEmpty &&
              userController.payJumpUrl.isNotEmpty
          ? PaySuccessNewDialog(
              onAddBtnTap: () {
                final p = _iosPurchaseProvider;
                p.reportPayPageTopInfo(
                  "member_page_become_member_add_btn",
                  p.vipPageTopDataList.isNotEmpty ? p.vipPageTopDataList.first : null,
                  "click",
                  vipId: p.vipTypeBeans.isNotEmpty &&
                          p.selectedVIPTypeIndex < p.vipTypeBeans.length
                      ? p.vipTypeBeans[p.selectedVIPTypeIndex].id.toString()
                      : null,
                );
              },
              onCloseBtnTap: () {
                final p = _iosPurchaseProvider;
                p.reportPayPageTopInfo(
                  "member_page_become_member_close_btn",
                  p.vipPageTopDataList.isNotEmpty ? p.vipPageTopDataList.first : null,
                  "click",
                  vipId: p.vipTypeBeans.isNotEmpty &&
                          p.selectedVIPTypeIndex < p.vipTypeBeans.length
                      ? p.vipTypeBeans[p.selectedVIPTypeIndex].id.toString()
                      : null,
                );
              },
            )
          : PaySuccessDialog(
              title: title,
              onAddBtnTap: () {
                final p = _iosPurchaseProvider;
                p.reportPayPageTopInfo(
                  "member_page_become_member_add_btn",
                  p.vipPageTopDataList.isNotEmpty ? p.vipPageTopDataList.first : null,
                  "click",
                  vipId: p.vipTypeBeans.isNotEmpty &&
                          p.selectedVIPTypeIndex < p.vipTypeBeans.length
                      ? p.vipTypeBeans[p.selectedVIPTypeIndex].id.toString()
                      : null,
                );
              },
              onCloseBtnTap: () {
                final p = _iosPurchaseProvider;
                p.reportPayPageTopInfo(
                  "member_page_become_member_close_btn",
                  p.vipPageTopDataList.isNotEmpty ? p.vipPageTopDataList.first : null,
                  "click",
                  vipId: p.vipTypeBeans.isNotEmpty &&
                          p.selectedVIPTypeIndex < p.vipTypeBeans.length
                      ? p.vipTypeBeans[p.selectedVIPTypeIndex].id.toString()
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

  //民间故事支付成功后弹出成功页面
  void _folkStorySuccussPayBack() {
    final launchProvider = context.read<LaunchProvider>();
    if (launchProvider.isFolkStoryPayback) {
      Get.toNamed(Routes.folkStorySuccessPayback);
    }
  }

  Widget _text() {
    String showText = context.select<IosPurchaseProvider, String>(
      (provider) => provider.showHintText,
    );
    return Text(
      showText,
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
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
              provider.createIosOrder(
                onSuccess: (payOrderBean) {},
                context: context,
                popPay: popPay,
                retentionPop: retentionPop,
              );
            },
            color1: type == PurchaseUiType.Blue
                ? const Color(0XFF5B4BF7)
                : const Color(0xffFF387A),
          );
        },
      ).then((_) {
        // 只有在用户没有点击确认按钮时才上报关闭
        if (!hasClickedConfirm) {
          provider.reportPayPageTopInfo(
            "member_page_renew_protocol_close_btn",
            null,
            "click",
            vipId:
                provider.vipTypeBeans.isNotEmpty &&
                    provider.selectedVIPTypeIndex < provider.vipTypeBeans.length
                ? provider.vipTypeBeans[provider.selectedVIPTypeIndex].id
                      .toString()
                : null,
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

  ///开通会员区域
  Widget _openVipAreaView() {
    return Column(
      children: [
        Image.asset(
          type == PurchaseUiType.Blue
              ? Assets.purchaseOpenVip
              : Assets.purchaseOpenVipRed,
          width: 250.w,
          height: 62.w,
        ),
        SizedBox(height: 20.w),

        ///购买套餐列表
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: NewIosVipListViewEx(type: type),
        ),
        SizedBox(height: 10.w),
        _text(),
        _showVipRightsView(),
      ],
    );
  }

  ///会员专属权益展示区域
  Widget _showVipRightsView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 15.w),
        Row(
          children: [
            Container(
              width: 2.w,
              height: 12.w,
              color: Colors.white,
              margin: EdgeInsets.only(right: 5.w, left: 12.w),
            ),
            Text(
              "会员专属权益",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 5.w),

        ///会员专属权益图标展示区域
        Padding(
          padding: const EdgeInsets.only(
            // left: 12.w,
            // right: 12.w,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ..._iosPurchaseProvider.iconModelList1
                  .sublist(0, 4)
                  .map(
                    (e) => SizedBox(
                      width: 90.w,
                      child: Column(
                        children: [
                          Image.asset(
                            type == PurchaseUiType.Blue
                                ? e.iconPath
                                : e.iconRedPath,
                            width: 32.w,
                            height: 32.w,
                          ),
                          SizedBox(height: 5.w),
                          Text(
                            e.iconName,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
        SizedBox(height: 15.w),
        Padding(
          padding: const EdgeInsets.only(
            // left: 12.w,
            // right: 12.w,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ..._iosPurchaseProvider.iconModelList1
                  .sublist(4, 8)
                  .map(
                    (e) => SizedBox(
                      width: 90.w,
                      child: Column(
                        children: [
                          Image.asset(
                            type == PurchaseUiType.Blue
                                ? e.iconPath
                                : e.iconRedPath,
                            width: 32.w,
                            height: 32.w,
                          ),
                          SizedBox(height: 5.w),
                          Text(
                            e.iconName,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  /// 会员页曝光上报（PAGE_P_MEMBER_PAGE）
  void _reportPageExposure() {
    if (_hasReportedExposure) return;
    _hasReportedExposure = true;
    try {
      if (_iosPurchaseProvider.vipTypeBeans.isNotEmpty &&
          _iosPurchaseProvider.selectedVIPTypeIndex <
              _iosPurchaseProvider.vipTypeBeans.length) {
        _iosPurchaseProvider.reportPayPageTopInfo(
          "member_page",
          _iosPurchaseProvider.vipPageTopDataList.isNotEmpty
              ? _iosPurchaseProvider.vipPageTopDataList.first
              : null,
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

  @override
  Widget build(BuildContext context) {
    if (!_hasReportedExposure && _iosPurchaseProvider.vipTypeBeans.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reportPageExposure();
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

            ///立即订阅按钮
            Positioned(
              bottom: 0,
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
                    width: 1.sw,
                    color: const Color(0XFF000000),
                    padding: EdgeInsets.only(bottom: 18.h),
                    child: Column(
                      children: [
                        NewVIPCountDownWidget(
                          isBlue: type == PurchaseUiType.Blue,
                        ),
                        _buildSubscribeBtn(context),
                        _buildAgreement(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        color: const Color(0xff1E2022).withOpacity(0.6),
        border: Border.all(
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
