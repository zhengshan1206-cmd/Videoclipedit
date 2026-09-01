// ignore_for_file: use_build_context_synchronously

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/main.dart';
import 'package:video_clip_edit/modules/bind/bind_dialog.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/modules/main/main_page.dart';
import 'package:video_clip_edit/modules/purchase/beans/purchase_guid_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/home/beans/home_banner_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_type_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/pay_method_bean.dart';
import 'package:video_clip_edit/modules/purchase/widgets/vip_type_view.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/modules/purchase/widgets/vip_banner_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/vip_method_view.dart';
import 'package:video_clip_edit/modules/purchase/beans/count_down_config.dart';
import 'package:video_clip_edit/modules/purchase/widgets/count_down_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/dailog_bonus_givnup.dart';
import 'package:video_clip_edit/modules/purchase/beans/purchase_function_bean.dart';
import 'package:video_clip_edit/modules/purchase/widgets/purchase_function_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/purchase_success_dialog.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';

class PurchasePage extends StatefulWidget {
  final bool? closePay;
  const PurchasePage({super.key, this.closePay});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  PurchaseProvider? provider;

  bool popWhenSuccess = false;
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
    // provider?.subscribeWXPayResp(
    //   context,
    //   onSuccess: () {
    //     _queryOrderStatus();
    //   },
    // );
    // provider?.subscribeAliPayResp(
    //   context,
    //   onSuccess: () {
    //     _queryOrderStatus();
    //   },
    // );

    provider?.loadVipData();
  }

  @override
  void dispose() {
    // provider?.cancelSubscribeWXPayResp();
    // provider?.cancelSubscribeAliPayResp();
    EasyLoading.dismiss();
    final isAudit = context.read<LaunchProvider>().launchInfo!.isAudit;
    if (isAudit == 1) {
      provider?.agreementChecked = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PurchaseProvider>(
        builder: (BuildContext context, PurchaseProvider purchaseProvider,
            Widget? child) {
          return Column(
            children: [
              Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFFFFFEFB),
                    ),
                  ),
                  _buildBanner(context),
                  _buildAppBar(context),
                ],
              ),

              /// VIP view
              _buildVIPView(context),

              Expanded(
                child: _buildVIPTypeListView(context),
              ),

              /// 支付方式
              _buildPayMethods(context),

              /// 订阅按钮
              _buildSubscribeBtn(context),

              /// 协议
              _buildAgreement(context),
            ],
          );
        },
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
              onTap: () {
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
    final bannerBeans = context
        .select<PurchaseProvider, List<HomeBannerBean>>((p) => p.bannerBeans);

    final PurchaseProvider provider = context.read<PurchaseProvider>();
    final beans = provider.functionBeans;
    const int crossItemCount = 4;
    final double marginH = 12.w;
    final double itemW = (context.byScreenWidth - marginH * 2) / crossItemCount;
    final double itemH = 78.h;

    return bannerBeans.isEmpty
        ? Container()
        : Stack(
            children: [
              SizedBox(
                height: 220.h,
                child: BannerView(
                  urls: bannerBeans.map((e) => e.imgUrl).toList(),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 220.h,
                  left: marginH,
                  right: marginH,
                  bottom: 10.h,
                ),
                padding: EdgeInsets.only(
                  left: 10.w,
                  right: 10.w,
                  top: 40.h,
                  bottom: 20.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.w),
                  border: Border.all(
                    width: 0.5,
                    color: ByColorUtil.PurchaseBorderColor,
                  ),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: beans.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossItemCount,
                    mainAxisSpacing: 10.h,
                    crossAxisSpacing: 0,
                    childAspectRatio: itemW / itemH,
                  ),
                  itemBuilder: (context, index) {
                    return PurchaseFunctionView(
                      functionBean: beans[index],
                      onSelected: (PurchaseFunctionBean funtionBean) {},
                    );
                  },
                ),
              ),
              Positioned(
                top: 215.h,
                left: 0,
                right: 0,
                child: Image.asset(
                  "assets/purchase/vip_exclusive_rights.png",
                  height: 36.h,
                  width: 246.w,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ],
          );
  }

  /// VIP view
  _buildVIPView(BuildContext context) {
    final vipTypeBeans = context.select<PurchaseProvider, List<VipTypeBean>>(
      (provider) => provider.vipTypeBeans,
    );
    bool showSpecial = vipTypeBeans.length > 3;
    if (showSpecial) {
      return const VipBannerView();
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: ByWidgetsUtil.gradientBgContainer(
            borderRadius: 8.w,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            gradient: ByColorUtil.lineareGradient(
              colorStart: const Color(0xFFF64737),
              colorEnd: const Color(0xFFFBBF65),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/home/icon_purchase_notice.png",
                  width: 28.w,
                  height: 28.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: FittedBox(
                    child: ByWidgetsUtil.commonText(
                        text: "新人限时福利，仅需¥0.01/天",
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        textColor: ByColorUtil.WhiteColor),
                  ),
                ),
                SizedBox(width: 5.w),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ByWidgetsUtil.commonText(
                      text: "距离结束还剩0天",
                      textColor: ByColorUtil.WhiteColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 4.h),
                    CountDownView(
                      config: CountDownConfig(
                        dateTime: DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          DateTime.now().hour + 5,
                          DateTime.now().minute + 59,
                          DateTime.now().second + 59,
                        ),
                        timeItemWidh: 20.w,
                        timeItemBorderRadius: 4,
                        textColor: const Color(0xFFFF3B4F),
                        separatorPadding: 2.w,
                        separatorFontSize: 12.sp,
                        separatorTextColor: ByColorUtil.WhiteColor,
                        fontSize: 16,
                        timeItemBgColor: ByColorUtil.WhiteColor,
                      ),
                    )
                  ],
                )
              ],
            )),
      );
    }
  }

  /// 支付列表
  _buildVIPTypeListView(BuildContext context) {
    final vipTypeBeans = context.select<PurchaseProvider, List<VipTypeBean>>(
      (provider) => provider.vipTypeBeans,
    );
    bool showSpecial = vipTypeBeans.length > 3;

    return vipTypeBeans.isEmpty
        ? Container()
        : Container(
            margin: EdgeInsets.symmetric(
              horizontal: 10.w,
              // vertical: 10.h,
            ),
            alignment: Alignment.center,
            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount:
                  showSpecial ? vipTypeBeans.length - 1 : vipTypeBeans.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 11.w,
              ),
              itemBuilder: (context, index) {
                return VipTypeView(
                  vipTypeBean: vipTypeBeans[showSpecial ? (index + 1) : index],
                  onSelected: (VipTypeBean bean) {
                    context.read<PurchaseProvider>().changeSelectedVipTypeIndex(
                        showSpecial ? (index + 1) : index);
                  },
                );
              },
            ),
          );
  }

  /// 支付方式
  _buildPayMethods(BuildContext context) {
    final provider = context.read<PurchaseProvider>();

    return Container(
      padding: EdgeInsets.only(
        left: 65.w,
        right: 65.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: provider.payMethodBeans.map(
          (bean) {
            return PayMethodView(
              payMethodBean: bean,
              onSelected: (PayMethodBean bean) {
                provider.changeSelectedPayMethodIndex(
                    provider.payMethodBeans.indexOf(bean));
              },
            );
          },
        ).toList(),
      ),
    );
  }

  /// 订阅按钮
  _buildSubscribeBtn(BuildContext context) {
    return ScaleTransitionWidget(
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            margin: EdgeInsets.only(bottom: 10.h),
            child: ByWidgetsUtil.gradientBtn(
                title: "成为会员",
                fontSize: 18.sp,
                onClick: () {
                  final provider = context.read<PurchaseProvider>();
                  provider.createOrder(
                    onSuccess: (payOrderBean) {
                      // Navigator.pop(context);
                    },
                    context: context,
                  );
                },
                fontWeight: FontWeight.bold,
                borderRadius: 50,
                gradient: ByColorUtil.lineareGradient(
                  colorStart: const Color(0xFFF75E53),
                  colorEnd: const Color(0xFFEE2C25),
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )),
          ),
          Positioned(
            bottom: 0,
            right: 30.w,
            child: Image.asset(
              "assets/purchase/icon_pointer.png",
              width: 52.w,
              height: 45.h,
              fit: BoxFit.contain,
            ),
          )
        ],
      ),
    );
  }

  /// 协议
  _buildAgreement(BuildContext context) {
    final provider = context.read<PurchaseProvider>();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          const Spacer(),
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
                        "open Url:${provider.vipPageBean?.user.protocolUrl}");
                    if (provider.vipPageBean!.user.protocolUrl.isEmpty) return;
                    ByNavRouterUtils.jumpWebViewPage(context, "",
                        provider.vipPageBean?.user.protocolUrl ?? "");
                  },
              ),
            ],
            fontSize: 12.sp,
            textColor: ByColorUtil.LoginTextfieldTextColor.withOpacity(0.6),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  _showExitConfirmationDialog(BuildContext context) async {
    // UserInfoProvider provider = context.read<UserInfoProvider>();
    LaunchProvider provider = context.read<LaunchProvider>();

    if (provider.launchInfo?.isVip == 1) {
      if (Navigator.canPop(context)) {
        ByNavRouterUtils.goBack(context);
      } else {
        Get.find<MainController>().backToMain();
      }
    } else {
      return await showDialog(
              context: context,
              builder: (context) {
                return ChangeNotifierProvider.value(
                    value: context.read<PurchaseProvider>(),
                    child: const DailogBonusGivnup());
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
              contents: showKfGuide ? "微信添加助教老师，一对一变现服务" : null,
              btnTtle: showKfGuide ? '立即添加老师' : null,
              webUrl: showKfGuide ? bean.kfUrl : null,
            );
          },
        );

        if (popWhenSuccess == true) {
          if (Navigator.canPop(context)) {
            ByNavRouterUtils.goBack(context);
          } else {
            Get.find<MainController>().backToMain();
          }
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
    // await showDialog(
    //   context: navigatorKey.currentState!.context,
    //   builder: (context) {
    //     return const PurchaseSuccessDialog();
    //   },
    // );

    // if (popWhenSuccess == true) {
    //   if (Navigator.canPop(context)) {
    //     ByNavRouterUtils.goBack(context);
    //   } else {
    // Get.find<MainController>().backToMain();
    //   }
    // }
  }
}
