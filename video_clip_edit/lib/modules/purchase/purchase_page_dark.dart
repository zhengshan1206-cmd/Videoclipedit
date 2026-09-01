// ignore_for_file: use_build_context_synchronously
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/main.dart';
import 'package:video_clip_edit/modules/main/controllers/new_user_benefits_controller.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/modules/bind/bind_dialog.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/beans/home_banner_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_type_bean.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view_dark.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/modules/purchase/widgets/vip_method_view.dart';
import 'package:video_clip_edit/modules/purchase/beans/purchase_guid_bean.dart';
import 'package:video_clip_edit/modules/login/widgets/login_agreement_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/vip_type_view_dark.dart';
import 'package:video_clip_edit/modules/purchase/widgets/dailog_bonus_givnup.dart';
import 'package:video_clip_edit/modules/purchase/beans/purchase_function_bean.dart';
import 'package:video_clip_edit/modules/purchase/widgets/purchase_function_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/purchase_success_dialog.dart';

class PurchasePageDark extends StatefulWidget {
  final bool? closePay;
  const PurchasePageDark({
    super.key,
    this.closePay,
  });

  @override
  State<PurchasePageDark> createState() => _PurchasePageDarkState();
}

class _PurchasePageDarkState extends State<PurchasePageDark> {
  PurchaseProvider? provider;
  bool popWhenSuccess = false;
  final SwiperController _controller = SwiperController();

  @override
  void initState() {
    super.initState();

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
    // provider?.subscribeWXPayResp(
    //   context,
    //   onSuccess: () {
    //     _queryOrderStatus();
    //   },
    // );

    /// 订阅支付宝支付通知
    // provider?.subscribeAliPayResp(
    //   context,
    //   onSuccess: () {
    //     _queryOrderStatus();
    //   },
    // );

    /// 加载VIP权益
    provider?.loadVipData();
  }

  @override
  void dispose() {
    /// 取消支付通知订阅
    // provider?.cancelSubscribeWXPayResp();
    // provider?.cancelSubscribeAliPayResp();
    EasyLoading.dismiss();
    // final isAudit = context.read<LaunchProvider>().launchInfo!.isAudit;
    // if (isAudit == 1) {
    //   provider?.agreementChecked = false;
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        LaunchProvider provider = context.read<LaunchProvider>();
        if (provider.launchInfo?.isVip == 1) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context, true);
          } else {
            Get.offNamed(Routes.main);
          }
          return;
        }
        if (Get.isRegistered<NewUserBenefitsController>() == true &&
            Get.find<NewUserBenefitsController>().showType.value == 2) {
          bool value = await Get.find<NewUserBenefitsController>()
              .retentionDialog(callPay: toPay);
          if (value == true) {
            Navigator.pop(context);
            return;
          }
          return;
        }
        final pop = await showDialog(
                context: context,
                builder: (ctx) {
                  return ChangeNotifierProvider.value(
                    value: context.read<PurchaseProvider>(),
                    child: const DailogBonusGivnup(),
                  );
                }) ??
            false;
        if (pop) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context, true);
          } else {
            Get.offNamed(Routes.main);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF111315),
        body: Consumer<PurchaseProvider>(
          builder: (BuildContext context, PurchaseProvider purchaseProvider,
              Widget? child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Positioned.fill(
                        child: Container(),
                      ),
                      _buildBanner(context),
                      _buildAppBar(context),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Image.asset(
                    "assets/purchase/dark/icon_title_dark.png",
                    height: 66.h,
                    fit: BoxFit.fitHeight,
                  ),
                  SizedBox(height: 22.h),
                  _buildVIPTypeListView(context),

                  /// 支付方式
                  _buildPayMethods(context),

                  /// 订阅按钮
                  _buildSubscribeBtn(context),

                  /// 协议
                  _buildAgreement(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// app bar
  Positioned _buildAppBar(BuildContext context) {
    return Positioned(
      child: Padding(
        padding: EdgeInsets.only(top: context.byTopSafeHeight),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                if (Get.isRegistered<NewUserBenefitsController>() == true &&
                    Get.find<NewUserBenefitsController>().showType.value == 2) {
                  bool value = await Get.find<NewUserBenefitsController>()
                      .retentionDialog(callPay: toPay);
                  if (value == true) {
                    Navigator.pop(context);
                    return;
                  }
                  return;
                }
                _showExitConfirmationDialog(context);
              },
              child: Container(
                height: 44,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Image.asset(
                  "assets/purchase/icon_close.png",
                  width: 32.w,
                  height: 32.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Spacer(),
            Offstage(
              offstage: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ByCommonUtils.debugPrintObj('恢复购买', tag: "Resume---");
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5),
                  margin: EdgeInsets.only(right: 12.w),
                  decoration: BoxDecoration(
                      color: ByColorUtil.WhiteColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5)),
                  child: ByWidgetsUtil.commonText(
                    text: "恢复购买",
                    fontSize: 12.sp,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// banner
  _buildBanner(BuildContext context) {
    final bannerBeans = context.select<PurchaseProvider, List<HomeBannerBean>>(
        (p) => p.bannerBeansDark);

    final PurchaseProvider provider = context.read<PurchaseProvider>();
    final double marginH = 12.w;
    const int crossItemCount = 5;
    final beans = provider.functionBeansDark;
    final contentW = (context.byScreenWidth - marginH * 2);
    final spacingH = 10.w;
    final double itemW =
        (contentW - (crossItemCount - 1) * spacingH) / crossItemCount;
    final double itemH = itemW * 72 / 62 + 2;

    return bannerBeans.isEmpty
        ? Container()
        : Stack(
            children: [
              SizedBox(
                height: 375.h,
                width: context.byScreenWidth,
                child: BannerViewDark(
                  urls: bannerBeans.map((e) => e.imgUrl).toList(),
                  controller: _controller,
                  onIndexChanged: (idx) {
                    context.read<PurchaseProvider>().changeSelectedIndex(idx);
                  },
                ),
              ),
              Positioned(
                bottom: 1,
                left: 0,
                child: Container(
                  width: contentW,
                  height: itemH + 3,
                  margin: EdgeInsets.symmetric(horizontal: marginH),
                  child: GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: beans.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossItemCount,
                      mainAxisSpacing: 0.w,
                      crossAxisSpacing: 10,
                      childAspectRatio: itemW / itemH,
                    ),
                    itemBuilder: (context, index) {
                      return PurchaseFunctionViewDark(
                        functionBean: beans[index],
                        onSelected: (PurchaseFunctionBean funtionBean) {
                          _controller.move(index);
                          context
                              .read<PurchaseProvider>()
                              .changeSelectedIndex(index);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
  }

  /// 支付列表
  _buildVIPTypeListView(BuildContext context) {
    final vipTypeBeans = context.select<PurchaseProvider, List<VipTypeBean>>(
      (provider) => provider.vipTypeBeans,
    );
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final itemH = math.max(118.h, shortest * 0.30);
    // 横滑卡：在避免底栏裁切的前提下收紧单元高度，减少卡片内上下留白
    final gridH = math.max(itemH * 1.14, 150.h);
    final marginHor = 10.w;
    final contentW = context.byScreenWidth - marginHor * 2;
    const itemCount = 3;
    final itemW = (contentW - marginHor * (itemCount - 1)) / itemCount;
    return vipTypeBeans.isEmpty
        ? Container()
        : Container(
            height: gridH,
            margin: EdgeInsets.symmetric(horizontal: marginHor),
            alignment: Alignment.center,
            child: GridView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: vipTypeBeans.length,
              physics: vipTypeBeans.length > itemCount
                  ? null
                  : const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: marginHor,
                childAspectRatio: gridH / itemW,
              ),
              itemBuilder: (context, index) {
                return VipTypeViewDark(
                  vipTypeBean: vipTypeBeans[index],
                  index: index,
                  onSelected: (VipTypeBean bean) {
                    context
                        .read<PurchaseProvider>()
                        .changeSelectedVipTypeIndex(index);
                  },
                );
              },
            ),
          );
  }

  /// 支付方式
  _buildPayMethods(BuildContext context) {
    final provider = context.read<PurchaseProvider>();
    final payMethodBeans = provider.payMethodBeans;
    return Container(
      margin: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 15.h,
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
          color: const Color(0xFF191C22),
          borderRadius: BorderRadius.circular(10.w)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          payMethodBeans.isEmpty
              ? Container()
              : PayMethodView(
                  payMethodBean:
                      payMethodBeans[provider.selectedPayMethodIndex],
                  showCheckBox: false,
                ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final idx = payMethodBeans
                  .indexOf(payMethodBeans[provider.selectedPayMethodIndex]);
              int idxNext = idx + 1;
              final len = payMethodBeans.length;
              if (idxNext >= len) {
                idxNext = 0;
              }
              provider.changeSelectedPayMethodIndex(idxNext);
            },
            child: Container(
              width: 30.w,
              height: 44.h,
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 16.h,
                child: Image.asset(
                  "assets/purchase/dark/icon_exchange_dark.png",
                  height: 16.h,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void toPay(){
    final provider = context.read<PurchaseProvider>();

    if (!provider.agreementChecked) {
      showDialog(
        context: context,
        builder: (context) {
          return LoginAgreementView(
            btnTitle: "成为会员",
            callback: () {
              provider.agreementCheckedStatusChanged(true);

              /// 显示弹窗并写入plist
              provider.createOrder(
                onSuccess: (payOrderBean) {},
                context: context,
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
  }
  /// 订阅按钮
  _buildSubscribeBtn(BuildContext context) {
    return ScaleTransitionWidget(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        margin: EdgeInsets.only(bottom: 15.h, top: 17.h),
        height: 54.h,
        child: ByWidgetsUtil.gradientBtn(
            title: "立即解锁",
            fontSize: 18.sp,
            onClick: () {
              toPay();
            },
            fontWeight: FontWeight.bold,
            borderRadius: 50,
            gradient: ByColorUtil.lineareGradient(
              colorStart: const Color(0xFFFF2FDA),
              colorEnd: const Color(0xFF3333FF),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )),
      ),
    );
  }

  /// 协议
  _buildAgreement(BuildContext context) {
    final provider = context.read<PurchaseProvider>();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        provider.agreementCheckedStatusChanged(!provider.agreementChecked);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset(
            provider.agreementChecked
                ? "assets/purchase/dark/checked_dark.png"
                : "assets/purchase/dark/uncheck_dark.png",
            height: 15.h,
            fit: BoxFit.fitHeight,
          ),
          SizedBox(width: 5.w),
          ByWidgetsUtil.commonRichText(
            texts: [
              const TextSpan(text: "我已阅读并同意"),
              TextSpan(
                text: "《用户协议》",
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    final url = context
                            .read<LaunchProvider>()
                            .launchInfo
                            ?.config
                            .protocol ??
                        "";
                    if (url.isEmpty) return;
                    ByNavRouterUtils.jumpWebViewPage(context, "", url);
                  },
              ),
              const TextSpan(text: "和"),
              TextSpan(
                text: "《隐私政策》",
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    final url = context
                            .read<LaunchProvider>()
                            .launchInfo
                            ?.config
                            .privacy ??
                        "";
                    if (url.isEmpty) return;
                    ByNavRouterUtils.jumpWebViewPage(context, "", url);
                  },
              ),
            ],
            fontSize: 12.sp,
            textColor: ByColorUtil.WhiteColor.withOpacity(0.6),
          ),
          const Spacer(),
        ],
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
      return await showDialog(
              context: context,
              builder: (ctx) {
                return ChangeNotifierProvider.value(
                  value: context.read<PurchaseProvider>(),
                  child: const DailogBonusGivnup(),
                );
              }) ??
          false;
    }
  }

  /// 查询订单状态
  void _queryOrderStatus() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..maskType = EasyLoadingMaskType.custom
      ..indicatorType = EasyLoadingIndicatorType.cubeGrid
      ..indicatorColor = ByColorUtil.PurchasePriceTextColor
      ..loadingStyle = EasyLoadingStyle.light;
    EasyLoading.show(dismissOnTap: false);
    context.read<PurchaseProvider>().querryOrderStatus(
      onSuccess: () async {
        EasyLoading.dismiss();
        // showAddWxDialog();

        // 充值成功
        context.read<LaunchProvider>().launch(context);
        Get.find<UserController>().reloadUserInfo(successAction: (userInfo) {
          debugPrint("isBindPhone:${userInfo?.isBindPhone == 1}");
          if (userInfo != null && userInfo.isBindPhone == 0) {
            showDialog(
              useSafeArea: false,
              context: context,
              builder: (c) {
                return Column(
                  children: [
                    SizedBox(height: 300.h),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.w),
                          topRight: Radius.circular(15.w),
                        ),
                        child: BindDialog(
                          call: () {},
                        ),
                      ),
                    ),
                  ],
                );
              },
            );

            showAddWxDialog();
            return;
          } else {
            showAddWxDialog();
          }
        });
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
        BotToast.showText(text: msg);
      },
    );
  }
}
