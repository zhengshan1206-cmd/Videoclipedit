import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/modules/main/beans/launch_info_bean.dart';
import 'package:video_clip_edit/modules/purchase/new_purchase/ios_purchase/ios_vip_half_list_view.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/modules/purchase/widgets/ios_purchase_agreement_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/pay_success_dialog.dart';
import 'package:video_clip_edit/providers/ios_purchase_provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/pay/ios_buy_engine.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';

import '../../utils/consts/const.dart';
import '../../utils/http/apis.dart';
import '../../utils/http/http_utils.dart';

class IosPurchaseHalfDialog extends StatefulWidget {
  const IosPurchaseHalfDialog({
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
  State<IosPurchaseHalfDialog> createState() => _IosPurchaseHalfDialogState();
}

class _IosPurchaseHalfDialogState extends State<IosPurchaseHalfDialog>
    with WidgetsBindingObserver {
  late IosPurchaseProvider _iosPurchaseProvider;
  bool _hasReportedExposure = false;
  SwiperController controller = SwiperController();

  ///苹果支付成功后查询订单状态的监听
  late StreamSubscription _iosPaySuccessSubscription;

  UserController get userController => Get.find<UserController>();

  late StreamSubscription _iosBuyStreamSubscription;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _iosPurchaseProvider = context.read<IosPurchaseProvider>();
    _iosPurchaseProvider.iosBuyEngin.initializeInAppPurchase();
    _iosPurchaseProvider.loadIosVipBanner();
    _iosPurchaseProvider.loadVipData();
    _iosPurchaseProvider.preLoginConfig();

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

  ///导航图片
  Widget _buildNavImage() {
    return Stack(
      children: [
        Container(
          height: 180.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.w),
              topRight: Radius.circular(24.w),
            ),
            image: DecorationImage(
              image: widget.bgImgUrl.startsWith('http') ||
                      widget.bgImgUrl.startsWith('https')
                  ? NetworkImage(widget.bgImgUrl)
                  : AssetImage(widget.bgImgUrl) as ImageProvider,
              fit: BoxFit.cover,
            ),
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
      child: IosVipHalfListView(isBlue: widget.isBlue),
    );
  }

  Widget _text() {
    String showText = context.select<IosPurchaseProvider, String>(
      (provider) => provider.showHintText,
    );
    return Text(
      showText,
      style: TextStyle(
        color: const Color(0xFF101E48).withOpacity(0.5),
        fontWeight: FontWeight.w400,
        fontSize: 12.sp,
      ),
    );
  }

  ///恢复购买
  Widget _buildRestorePurchase() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.w),
      child: Center(
        child: InkResponse(
          onTap: () {
            _iosPurchaseProvider.iosRepair(onSuccess: () {
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
                            title: value != null && value ? '绑定成功！' : null);
                      });
                      return;
                    }
                    showSuccessDialog();
                  });
                },
              );
            });
          },
          child: Container(
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color(0xFF697391), width: 1))),
            child: Text(
              "恢复购买",
              style: TextStyle(color: const Color(0xFF697391), fontSize: 12.sp),
            ),
          ),
        ),
      ),
    );
  }

  ///会员专属权益
  Widget _buildVipContent() {
    ///标题颜色
    Color titleColor =
        widget.isBlue ? const Color(0xFF101E48) : const Color(0xFF8F5626);

    ///文字颜色
    Color txtColor =
        widget.isBlue ? const Color(0xFF697391) : const Color(0xFF8F5626);
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
          _buildVipContentList()
        ],
      ),
    );
  }

  ///权益列表
  Widget _buildVipContentList() {
    ///字体颜色
    Color txtColor =
        widget.isBlue ? const Color(0xFF697391) : const Color(0xFF8F5626);

    ///背景颜色
    Color bgColor =
        widget.isBlue ? const Color(0xFFF8FAFF) : const Color(0xFFFFFDF6);

    ///边框颜色
    Color borderColor =
        widget.isBlue ? const Color(0xFFF2F5FF) : const Color(0xFFFFF5E6);
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
                border: Border.all(
                  color: borderColor,
                  width: 1.w,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    launchProvider.launchInfo?.verConfig
                            .halfScreenRightsDesc[index].icon ??
                        "",
                    width: 28.w,
                    height: 28.h,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    launchProvider.launchInfo?.verConfig
                            .halfScreenRightsDesc[index].title ??
                        "",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: txtColor,
                    ),
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
    Color colorStart =
        widget.isBlue ? const Color(0xFF5B4BF7) : const Color(0xFFFF7E33);
    Color colorEnd =
        widget.isBlue ? const Color(0xFF5B4BF7) : const Color(0xFFFCC25A);
    String memberBtnTxt = context.select<IosPurchaseProvider, String>(
      (provider) => provider.memberBtnTxt,
    );
    final provider = context.watch<IosPurchaseProvider>();
    return ScaleTransitionWidget(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        height: 54.h,
        child: ByWidgetsUtil.gradientBtn(
            title: memberBtnTxt,
            fontSize: 18.sp,
            onClick: () {
              // 上报开通按钮点击
              _reportPayPageTopInfo("member_page_open_btn", "click");

              if (!provider.agreementChecked) {
                // 上报协议弹窗显示
                _reportPayPageTopInfo(
                    "member_page_renew_protocol_dialog", "view");

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
                            "member_page_renew_protocol_open_btn", "click");

                        provider.agreementCheckedStatusChanged(true);

                        /// 显示弹窗并写入plist
                        provider.createIosOrder(
                          onSuccess: (payOrderBean) {},
                          context: context,
                        );
                      },
                      color1: colorStart,
                    );
                  },
                ).then((_) {
                  if (!hasClickedConfirm) {
                    _reportPayPageTopInfo(
                        "member_page_renew_protocol_close_btn", "click");
                  }
                });
                return;
              }
              provider.createIosOrder(
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
            )),
      ),
    );
  }

  /// 协议
  Widget _buildAgreement(BuildContext context) {
    bool agreementChecked = context.select<IosPurchaseProvider, bool>(
      (provider) => provider.agreementChecked,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _iosPurchaseProvider.agreementCheckedStatusChanged(
            !_iosPurchaseProvider.agreementChecked);
      },
      child: Container(
        padding:
            EdgeInsets.only(left: 12.w, right: 12.w, bottom: 15.h, top: 10.h),
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
                color: const Color(0xFF101E48).withOpacity(0.6),
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
                            color: const Color(0xFF101E48).withOpacity(0.6),
                          ),
                        ),
                        TextSpan(
                          text: "《会员服务协议》",
                          style: TextStyle(
                            color: const Color(0xFF101E48).withOpacity(0.6),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              debugPrint(
                                  "open Url:${_iosPurchaseProvider.vipPageBean?.user.protocolUrl}");
                              if (_iosPurchaseProvider.vipPageBean!.user
                                  .protocolUrl.isEmpty) return;
                              ByNavRouterUtils.jumpWebViewPage(
                                  context,
                                  "",
                                  _iosPurchaseProvider
                                          .vipPageBean?.user.protocolUrl ??
                                      "");
                            },
                        ),
                        TextSpan(
                          text: "和",
                          style: TextStyle(
                            color: const Color(0xFF101E48).withOpacity(0.6),
                          ),
                        ),
                        TextSpan(
                          text: "《自动续费服务协议》",
                          style: TextStyle(
                            color: const Color(0xFF101E48).withOpacity(0.6),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              debugPrint(
                                  "open Url:${_iosPurchaseProvider.vipPageBean?.user.subScribeProtocolUrl}");
                              if (_iosPurchaseProvider.vipPageBean!.user
                                  .subScribeProtocolUrl.isEmpty) return;
                              ByNavRouterUtils.jumpWebViewPage(
                                  context,
                                  "",
                                  _iosPurchaseProvider.vipPageBean?.user
                                          .subScribeProtocolUrl ??
                                      "");
                            },
                        ),
                        if (_iosPurchaseProvider.isShowIntegralAgreement)
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "和",
                                style: TextStyle(
                                  color:
                                      const Color(0xFF101E48).withOpacity(0.6),
                                ),
                              ),
                              TextSpan(
                                text: "《积分服务协议》",
                                style: TextStyle(
                                  color:
                                      const Color(0xFF101E48).withOpacity(0.6),
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    debugPrint(
                                        "open Url:${_iosPurchaseProvider.vipPageBean?.user.integralRule}");
                                    if (_iosPurchaseProvider.vipPageBean!.user
                                        .integralRule.isEmpty) return;
                                    ByNavRouterUtils.jumpWebViewPage(
                                        context,
                                        "",
                                        _iosPurchaseProvider.vipPageBean?.user
                                                .integralRule ??
                                            "");
                                  },
                              ),
                            ],
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
            SizedBox(height: 10.h),
            _text(),
            _buildRestorePurchase(),
            _buildVipContent(),
            _buildSubscribeBtn(context),
            _buildAgreement(context),
          ],
        ),
      ),
    );
  }

  /// 页面曝光上报（member_page view，只上报一次）
  void _reportPageExposure() {
    if (_hasReportedExposure) return;
    _hasReportedExposure = true;
    try {
      if (_iosPurchaseProvider.vipTypeBeans.isNotEmpty &&
          _iosPurchaseProvider.selectedVIPTypeIndex <
              _iosPurchaseProvider.vipTypeBeans.length) {
        _iosPurchaseProvider.reportPayPageTopInfo(
          "member_page",
          widget.bgImgUrl.isNotEmpty ? widget.bgImgUrl : null,
          "view",
          vipId: _iosPurchaseProvider
              .vipTypeBeans[_iosPurchaseProvider.selectedVIPTypeIndex].id
              .toString(),
          isHalfScreen: true,
        );
      }
    } catch (e) {
      debugPrint("_reportPageExposure error: $e");
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

  /// 查询订单状态
  void _queryOrderStatus({
    required String receiptData,
  }) {
    context.read<IosPurchaseProvider>().queryOrderStatus(
          receiptData: receiptData,
          onSuccess: () async {},
        );
  }

  ///监听苹果支付成功状态
  iniIosPaySuccessSubscription() {
    _iosPaySuccessSubscription =
        eventBus.on<QueryIosOrderEvent>().listen((event) {
      _queryOrderStatus(receiptData: event.serverVerificationData);
    });
    _iosBuyStreamSubscription =
        eventBus.on<IosProductBuySuccessEvent>().listen((e) {
      postPurchaseSuccess();

      /// 充值成功
      context.read<LaunchProvider>().launch(
        Get.context!,
        onSuccess: (LaunchInfoBean bean) {
          /// 更新个人信息
          Get.find<UserController>().reloadUserInfo(successAction: (userInfo) {
            debugPrint("isBindPhone:${userInfo?.isBindPhone == 1}");

            ///未绑定手机号
            if (userInfo?.isBindPhone == 0) {
              userController
                  .showBindPhoneDialog(needConfirm: true)
                  .then((value) {
                showSuccessDialog(
                    title: value != null && value ? '绑定成功！' : null);
              });
              return;
            }
            showSuccessDialog();
          });
        },
      );
    });
  }

  @override
  void dispose() {
    _iosBuyStreamSubscription.cancel();
    _iosPaySuccessSubscription.cancel();
    super.dispose();
  }

  /// 统一上报方法
  void _reportPayPageTopInfo(
    String pageTag,
    String operateType, {
    String? vipId,
    int payType = 0,
  }) {
    final currentVipId = vipId ??
        (_iosPurchaseProvider.vipTypeBeans.isNotEmpty &&
                _iosPurchaseProvider.selectedVIPTypeIndex <
                    _iosPurchaseProvider.vipTypeBeans.length
            ? _iosPurchaseProvider
                .vipTypeBeans[_iosPurchaseProvider.selectedVIPTypeIndex].id
                .toString()
            : null);
    // 半弹窗使用传入的 bgImgUrl 作为上报图片
    final funcDetailImg = widget.bgImgUrl.isNotEmpty ? widget.bgImgUrl : null;

    _iosPurchaseProvider.reportPayPageTopInfo(
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
      "middle_page_tag": "",
      "payment_page_tag": launchProvider.launchInfo?.verConfig.halfScreenPage,
    });
  }
}
