import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/modules/login/widgets/login_agreement_view.dart';
import 'package:video_clip_edit/modules/main/beans/launch_info_bean.dart';
import 'package:video_clip_edit/modules/purchase/new_page/widgets/new_purchase_vip_method.dart';
import 'package:video_clip_edit/modules/purchase/new_page/widgets/purchase_vip_half_list.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/modules/purchase/widgets/pay_success_dialog.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

import '../../utils/consts/const.dart';
import '../../utils/http/apis.dart';
import '../../utils/http/http_utils.dart';

///支付半弹窗
class PurchaseHalfDialog extends StatefulWidget {
  const PurchaseHalfDialog({
    super.key,
    this.isBlue = false,
    required this.bgImgUrl,
    this.eventFunction = "",
    this.pagePath = "",
    this.prePagePath = "",
  });

  final bool isBlue;
  final String bgImgUrl;

  final String eventFunction;
  final String pagePath;
  final String prePagePath;

  @override
  State<PurchaseHalfDialog> createState() => _PurchaseHalfDialogState();
}

class _PurchaseHalfDialogState extends State<PurchaseHalfDialog>
    with WidgetsBindingObserver {
  PurchaseProvider? provider;
  bool popWhenSuccess = false;
  final ScrollController _scrollController = ScrollController();

  UserController get userController => Get.find<UserController>();
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
        postPurchaseSuccess();
        _queryOrderStatus();
      },
    );

    /// 订阅支付宝支付通知
    provider?.subscribeAliPayResp(
      context,
      onSuccess: () {
        postPurchaseSuccess();
        _queryOrderStatus();
      },
    );

    /// 加载VIP权益
    provider?.loadVipData();
  }

  ///导航图片
  Widget _buildNavImage() {
    return Stack(
      children: [
        // Container(
        //   // height: 180.h,
        //   width: MediaQuery.of(context).size.width,
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.only(
        //       topLeft: Radius.circular(24.w),
        //       topRight: Radius.circular(24.w),
        //     ),
        //     image: DecorationImage(
        //       image: widget.bgImgUrl.startsWith('http') ||
        //               widget.bgImgUrl.startsWith('https')
        //           ? NetworkImage(widget.bgImgUrl)
        //           : AssetImage(widget.bgImgUrl) as ImageProvider,
        //       fit: BoxFit.cover,
        //     ),
        //   ),
        // ),
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.w),
            topRight: Radius.circular(24.w),
          ),
          child:
              (widget.bgImgUrl.startsWith('http') ||
                  widget.bgImgUrl.startsWith('https'))
              ? CachedNetworkImage(
                  imageUrl: widget.bgImgUrl,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fitWidth,
                )
              : Image.asset(
                  widget.bgImgUrl,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fitWidth,
                ),
        ),
        // Positioned(
        //   bottom: 0,
        //   left: 0,
        //   right: 0,
        //   child: Container(
        //     height: 180.h,
        //     decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //         begin: Alignment.bottomCenter,
        //         end: Alignment.topCenter,
        //         colors: [
        //           Colors.white,
        //           Colors.white.withOpacity(0),
        //         ],
        //         stops: const [0.1, 1.0],
        //       ),
        //     ),
        //   ),
        // ),
        Positioned(
          top: 10.h,
          right: 10.w,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              'assets/purchase/icon_close_2.png',
              fit: BoxFit.contain,
              width: 36.w,
              height: 36.h,
            ),
          ),
        ),
      ],
    );
  }

  /// 支付列表
  Widget _buildVIPTypeListView(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
      child: PurchaseVipHalfList(isBlue: widget.isBlue),
    );
  }

  ///支付方式
  Widget _buildPayMethodView(BuildContext context) {
    final provider = context.watch<PurchaseProvider>();
    final payMethodBeans = provider.payMethodBeans;

    return payMethodBeans.isEmpty
        ? SizedBox(height: 44.h)
        : GestureDetector(
            onTap: () {
              var selectedIndex = provider.selectedPayMethodIndex + 1;
              //当前是最后一种支付方式时，切换轮回第一种支付方式
              if (selectedIndex == payMethodBeans.length) {
                selectedIndex = 0;
              }
              provider.changeSelectedPayMethodIndex(selectedIndex);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF8FAFF),
              ),
              height: 44.h,
              margin: EdgeInsets.all(12.h),
              padding: EdgeInsets.only(left: 12.w, right: 12.w),
              child: Builder(
                builder: (context) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NewVipMethodViewNew(
                        textColor: const Color(0xFF999999),
                        payMethodBean:
                            payMethodBeans[provider.selectedPayMethodIndex],
                      ),
                      Image.asset(
                        Assets.purchaseMethodChange,
                        width: 18,
                        height: 16,
                      ),
                    ],
                  );
                },
              ),
            ),
          );
  }

  ///会员专属权益
  Widget _buildVipContent() {
    ///标题颜色
    Color titleColor = widget.isBlue
        ? const Color(0xFF101E48)
        : const Color(0xFF8F5626);

    ///文字颜色
    Color txtColor = widget.isBlue
        ? const Color(0xFF697391)
        : const Color(0xFF8F5626);
    return Padding(
      padding: EdgeInsets.only(left: 12.w, bottom: 12.h),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 2.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: titleColor,
                  borderRadius: const BorderRadius.all(Radius.circular(1)),
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                "会员专属权益",
                style: TextStyle(
                  color: txtColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildVipContentList(),
        ],
      ),
    );
  }

  ///权益列表
  Widget _buildVipContentList() {
    ///字体颜色
    Color txtColor = widget.isBlue
        ? const Color(0xFF697391)
        : const Color(0xFF8F5626);

    ///背景颜色
    Color bgColor = widget.isBlue
        ? const Color(0xFFF8FAFF)
        : const Color(0xFFFFFDF6);

    ///边框颜色
    Color borderColor = widget.isBlue
        ? const Color(0xFFF2F5FF)
        : const Color(0xFFFFF5E6);

    final launchProvider = context.watch<LaunchProvider>();
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount:
            launchProvider.launchInfo?.verConfig.halfScreenRightsDesc.length ??
            0,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // 计算目标滚动位置，使点击项居中
              final itemWidth = 105.w;
              final itemMargin = 8.w;
              final screenWidth = MediaQuery.of(context).size.width;
              final itemTotalWidth = itemWidth + itemMargin;

              // 计算目标位置：当前项的位置 - (屏幕宽度 - 项宽度) / 2
              final targetPosition =
                  index * itemTotalWidth - (screenWidth - itemWidth) / 2;

              // 确保不会出现负值
              final finalPosition = targetPosition.clamp(0.0, double.infinity);

              _scrollController.animateTo(
                finalPosition,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 105.w,
              height: 40.h,
              margin: EdgeInsets.only(right: 8.w),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10.w),
                border: Border.all(color: borderColor, width: 1.w),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    launchProvider
                            .launchInfo
                            ?.verConfig
                            .halfScreenRightsDesc[index]
                            .icon ??
                        "",
                    width: 28.w,
                    height: 28.h,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    launchProvider
                            .launchInfo
                            ?.verConfig
                            .halfScreenRightsDesc[index]
                            .title ??
                        "",
                    style: TextStyle(fontSize: 12.sp, color: txtColor),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 订阅按钮
  Widget _buildSubscribeBtn(BuildContext context) {
    Color colorStart = widget.isBlue
        ? const Color(0xFF5B4BF7)
        : const Color(0xFFFF7E33);
    Color colorEnd = widget.isBlue
        ? const Color(0xFF5B4BF7)
        : const Color(0xFFFCC25A);
    final provider = context.watch<PurchaseProvider>();
    return ScaleTransitionWidget(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        height: 54.h,
        child: ByWidgetsUtil.gradientBtn(
          title: provider.memberBtnTxt,
          fontSize: 18.sp,
          onClick: () {
            // 上报开通按钮点击
            _reportPayPageTopInfo("member_page_open_btn", "click");

            if (!provider.isAgreementChecked) {
              // 上报协议弹窗显示
              _reportPayPageTopInfo(
                "member_page_renew_protocol_dialog",
                "view",
              );

              showDialog(
                context: context,
                builder: (context) {
                  return LoginAgreementView(
                    btnTitle: "成为会员",
                    registerMember: true,
                    color1: colorStart,
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
            );
          },
          fontWeight: FontWeight.bold,
          borderRadius: 27,
          gradient: ByColorUtil.lineareGradient(
            colorStart: colorStart,
            colorEnd: colorEnd,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  /// 协议
  Widget _buildAgreement(BuildContext context) {
    final provider = context.watch<PurchaseProvider>();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 如果没有展示选择按钮且是默认同意状态，点击协议文字不应取消同意
        if (provider.agreementNum && provider.isAgreementChecked) return;
        provider.agreementCheckedStatusChanged(!provider.isAgreementChecked);
      },
      child: Container(
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          bottom: 15.h,
          top: 10.h,
        ),
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
                  color: const Color(0xFF101E48).withOpacity(0.6),
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
                            color: const Color(0xFF101E48).withOpacity(0.6),
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
                              color: const Color(0xFF101E48).withOpacity(0.6),
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
                      textColor: const Color(0xFF101E48).withOpacity(0.6),
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
    // 半弹窗使用传入的 bgImgUrl 作为上报图片
    final funcDetailImg = widget.bgImgUrl.isNotEmpty ? widget.bgImgUrl : null;

    currentProvider.reportPayPageTopInfo(
      pageTag,
      funcDetailImg,
      operateType,
      vipId: currentVipId,
      payType: payType,
      isHalfScreen: true,
    );
  }

  ///付费成功上报
  postPurchaseSuccess() {
    if (widget.eventFunction.isEmpty) {
      return;
    }
    final launchProvider = Provider.of<LaunchProvider>(context, listen: false);
    HttpUtils.post(APIs.apiPost, {
      "event": Consts.EVENT_PAID_PAGE,
      "event_function": widget.eventFunction,
      "event_action": Consts.ACTION_PAID_SUCCESS_REPORT,
      "page_path": widget.pagePath,
      "pre_page_path": widget.prePagePath,
      "payment_page_tag": launchProvider.launchInfo?.verConfig.halfScreenPage,
      "middle_page_tag": "",
    });
  }

  @override
  Widget build(BuildContext context) {
    // 数据加载完成后进行曝光上报
    final provider = context.watch<PurchaseProvider>();
    if (provider.vipTypeBeans.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _reportPageExposure();
        }
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.w),
          topRight: Radius.circular(24.w),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNavImage(),
            SizedBox(height: 26.h),
            _buildVIPTypeListView(context),
            _buildPayMethodView(context),
            _buildVipContent(),
            _buildSubscribeBtn(context),
            _buildAgreement(context),
          ],
        ),
      ),
    );
  }

  /// 页面曝光上报
  void _reportPageExposure() {
    try {
      final currentProvider = provider;
      if (currentProvider != null &&
          currentProvider.vipTypeBeans.isNotEmpty &&
          currentProvider.selectedVIPTypeIndex <
              currentProvider.vipTypeBeans.length) {
        currentProvider.reportPayPageTopInfo(
          "member_page",
          widget.bgImgUrl.isNotEmpty ? widget.bgImgUrl : null,
          "view",
          vipId: currentProvider
              .vipTypeBeans[currentProvider.selectedVIPTypeIndex]
              .id
              .toString(),
          isHalfScreen: true,
        );
      }
    } catch (e) {
      debugPrint("_reportPageExposure error: $e");
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

  showSuccessDialog({String? title}) async {
    // 上报成为会员弹框显示
    _reportPayPageTopInfo("member_page_become_member_dialog", "view");

    Get.customDialog(
      barrierDismissible: false,
      widget: PaySuccessDialog(
        title: title,
        onAddBtnTap: () {
          // 上报成为会员弹框立即添加按钮点击
          _reportPayPageTopInfo("member_page_become_member_add_btn", "click");
        },
        onCloseBtnTap: () {
          // 上报成为会员弹框关闭按钮点击
          _reportPayPageTopInfo("member_page_become_member_close_btn", "click");
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

  ///路由返回页面方法
  void _goBack() {
    if (Navigator.canPop(context)) {
      Get.back();
    } else {
      Get.offNamed(Routes.main);
    }
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
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    /// 取消支付通知订阅
    provider?.cancelSubscribeWXPayResp();
    provider?.cancelSubscribeAliPayResp();
    EasyLoading.dismiss();
    final isAudit = context.read<LaunchProvider>().launchInfo!.isAudit;
    if (isAudit == 1) {
      provider?.agreementChecked = false;
    }
    super.dispose();
  }
}
