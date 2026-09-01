import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/modules/login/widgets/login_agreement_view.dart';
import 'package:video_clip_edit/modules/main/beans/launch_info_bean.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/modules/purchase/widgets/pay_success_dialog.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/providers/integral_pay_provider.dart';
import 'package:video_clip_edit/utils/pay/ios_buy_engine.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:video_clip_edit/v2/integral/integral_controller.dart';

class IntegralPayDialog extends StatefulWidget {
  const IntegralPayDialog({super.key});

  @override
  State<IntegralPayDialog> createState() => _IntegralPayDialogState();
}

class _IntegralPayDialogState extends State<IntegralPayDialog>
    with WidgetsBindingObserver {
  late IntegralPayProvider _provider;
  DateTime? _lastTapTime;

  ///苹果支付成功后查询订单状态的监听
  late StreamSubscription _iosPaySuccessSubscription;

  bool popWhenSuccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.microtask(() {
      final bool? shouldPop =
          ModalRoute.of(context)?.settings.arguments as bool?;
      popWhenSuccess = shouldPop ?? false;
    });
    _provider = IntegralPayProvider();

    // 微信支付通知
    _provider.subscribeWXPayResp(
      context,
      onSuccess: () {
        _provider.needShowDialog = false;
        _provider.integralQueryOrder(
          onSuccess: () {
            showSuccessDialog();
          },
          onFailed: () {},
        );
      },
    );

    // 支付宝支付通知
    _provider.subscribeAliPayResp(
      context,
      onSuccess: () {
        _provider.integralQueryOrder(
          onSuccess: () {
            showSuccessDialog();
          },
          onFailed: () {},
        );
      },
    );
    if (Platform.isIOS) {
      _provider.iosBuyEngin.initializeInAppPurchase();
      iniIosPaySuccessSubscription();
    }
    _provider.integralinit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // _provider.cancelSubscribeWXPayResp();
    // _provider.cancelSubscribeAliPayResp();
    EasyLoading.dismiss();
    super.dispose();
  }

  //标题
  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Padding(
        padding: EdgeInsets.only(top: 20.h, bottom: 30.h),
        child: Row(
          children: [
            SizedBox(width: 18.w, height: 14.h),
            const Spacer(),
            ByWidgetsUtil.commonText(
              text: "购买积分",
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pop(context);
              },
              child: SizedBox(
                width: 18.w,
                height: 14.h,
                child: Image.asset(
                  "assets/home/icon_close_dark.png",
                  width: 14.w,
                  height: 14.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 剩余积分
  Widget _buildRemainIntegral() {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.h),
      child: Row(
        children: [
          Text(
            "当前剩余积分：",
            style: TextStyle(
              color: const Color(0xFF0B1843),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          Obx(
            () => Text(
              IntegralController.getOrPut().currentIntegral.value.toString(),
              style: TextStyle(
                color: const Color(0xFFF9A200),
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //积分套餐列表
  Widget _buildIntegralList(BuildContext context) {
    return Consumer<IntegralPayProvider>(
      builder: (context, provider, child) {
        if (provider.integralRecords.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Text(
                "暂无可用的积分套餐",
                style: TextStyle(
                  color: const Color(0xFF999999),
                  fontSize: 14.sp,
                ),
              ),
            ),
          );
        }
        final sw = MediaQuery.sizeOf(context).width;
        final cardW = (sw - 24.w - 24.w) / 3;
        final cardH = math
            .max(138.h, MediaQuery.sizeOf(context).shortestSide * 0.19)
            .clamp(138.h, 220.h);
        return Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: provider.integralRecords.map((item) {
            final isSelected =
                provider.selectedIndex ==
                provider.integralRecords.indexOf(item);
            return Container(
              width: cardW,
              height: cardH,
              child: GestureDetector(
                onTap: () {
                  provider.integralItemClick(item);
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 背景层
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFEAF1)
                              : const Color(0xFFF3F5F9),
                          borderRadius: BorderRadius.circular(12.w),
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xFFFF387A),
                                  width: 2.w,
                                )
                              : null,
                        ),
                      ),
                    ),
                    // 内容层
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.only(top: 16.h, bottom: 12.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${item.integral}",
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFFFF387A)
                                    : const Color(0xFF0B1843),
                                fontSize: 30.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "¥${item.money}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFFFF387A)
                                    : const Color(0xFF0B1843),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "原价¥${item.crossedMoney}",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFFFF387A).withOpacity(0.5)
                                    : const Color.fromRGBO(11, 24, 67, 0.5),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 标签层
                    if (item.isDefault == 1)
                      Positioned(
                        left: 0,
                        top: -18.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 13.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF731FE), Color(0xFFA531FE)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                          child: Text(
                            item.mark.isEmpty ? "最划算" : item.mark,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  //选中项文案提示
  Widget _buildSelectedText(BuildContext context) {
    return Consumer<IntegralPayProvider>(
      builder: (context, provider, child) {
        if (provider.integralRecords.isEmpty) return const SizedBox();
        final desc = provider.integralRecords[provider.selectedIndex].desc;
        return desc.isNotEmpty == true
            ? Padding(
                padding: EdgeInsets.only(top: 14.h, bottom: 14.h),
                child: Center(
                  child: Text(
                    desc,
                    style: TextStyle(
                      color: const Color.fromRGBO(11, 24, 67, 0.5),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              )
            : SizedBox(height: 14.h);
      },
    );
  }

  //支付方式
  Widget _buildPaymentMethod(BuildContext context) {
    return (Platform.isAndroid || ByPackageUtils.isOhos)
        ? Consumer<IntegralPayProvider>(
            builder: (context, provider, child) {
              return GestureDetector(
                onTap: () {
                  provider.switchPayMethod();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0XFFF3F5F9),
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 13.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              provider.currentPayMethod == "wxpay" ||
                                      provider.currentPayMethod == "yeepay"
                                  ? "assets/mine/score_icon_pay_wechat.png"
                                  : "assets/mine/score_icon_pay_zfb.png",
                              width: 18.w,
                              height: 18.h,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              provider.currentPayMethod == "wxpay" ||
                                      provider.currentPayMethod == "yeepay"
                                  ? "微信支付"
                                  : "支付宝支付",
                              style: TextStyle(
                                color: const Color(0xFF999999),
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        provider.availablePayMethods.length <= 1
                            ? Container()
                            : Image.asset(
                                "assets/mine/mine-pay-switch.png",
                                width: 18.w,
                                height: 16.h,
                                fit: BoxFit.contain,
                              ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        : GestureDetector(
            onTap: () {
              _provider.iosRepair(
                onSuccess: () {
                  context.read<LaunchProvider>().launch(
                    Get.context!,
                    onSuccess: (LaunchInfoBean bean) {
                      /// 更新个人信息
                      Get.find<UserController>().reloadUserInfo(
                        successAction: (userInfo) {
                          debugPrint(
                            "isBindPhone:${userInfo?.isBindPhone == 1}",
                          );

                          showSuccessDialog();
                        },
                      );
                    },
                  );
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.only(top: 15.h, bottom: 4.h),
              child: Center(
                child: Text(
                  "恢复购买",
                  style: TextStyle(
                    color: const Color(0xFF999999),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          );
  }

  //购买按钮
  Widget _buildpayBtn(BuildContext context) {
    return Consumer<IntegralPayProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.only(top: 15.h),
          child: ScaleTransitionWidget(
            child: GestureDetector(
              onTap: () {
                final now = DateTime.now();
                if (_lastTapTime != null &&
                    now.difference(_lastTapTime!).inSeconds < 1) {
                  return;
                }
                _lastTapTime = now;

                // 如果没有套餐，显示提示文本
                if (provider.integralRecords.isEmpty) {
                  BotToast.showText(text: "暂无可用套餐！");
                  return;
                }

                if (!provider.isAgreementChecked) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ChangeNotifierProvider<IntegralPayProvider>.value(
                        value: provider,
                        child: LoginAgreementView(
                          btnTitle: "阅读并同意",
                          registerMember: true,
                          isIntegral: true,
                          callback: () {
                            provider.agreementCheckedStatusChanged(true);
                            provider.createPayOrderV2();
                          },
                        ),
                      );
                    },
                  );
                } else {
                  provider.createPayOrderV2();
                }
              },
              child: Container(
                width: 320.w,
                height: 70.h,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/mine/integral-btn.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        provider.memberBtnTxt,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //积分购买协议
  Widget _buildAgreement(BuildContext context) {
    return Consumer<IntegralPayProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            provider.agreementCheckedStatusChanged(
              !provider.isAgreementChecked,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              provider.agreementNum
                  ? SizedBox(height: 15.h)
                  : Image.asset(
                      provider.isAgreementChecked
                          ? "assets/purchase/dark/checked_dark.png"
                          : "assets/purchase/dark/uncheck_dark.png",
                      height: 15.h,
                      color: const Color(0xFFFF3564),
                      fit: BoxFit.fitHeight,
                    ),
              SizedBox(width: 5.w),
              ByWidgetsUtil.commonRichText(
                texts: [
                  const TextSpan(
                    text: "已阅读并同意",
                    style: TextStyle(color: Color(0xFF0E101F)),
                  ),
                  TextSpan(
                    text: "《积分服务协议》",
                    style: const TextStyle(color: Color(0xFFFF3564)),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // 跳转到积分服务协议页面
                        if (provider.integralIllustrate!.isEmpty) return;
                        ByNavRouterUtils.jumpWebViewPage(
                          context,
                          "",
                          provider.integralIllustrate ?? "",
                        );
                      },
                  ),
                ],
                fontSize: 12.sp,
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }

  void showSuccessDialog() {
    // 安全获取 IntegralController 实例，避免未注册报错
    final integralController = IntegralController.getOrPut();

    // 刷新积分记录
    integralController.onRefresh();

    // 显示成功对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const PaySuccessDialog(title: '支付成功！', isFromIntegral: true),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_provider.needShowDialog && !(Get.isDialogOpen ?? false)) {
        // 添加500毫秒延时
        Future.delayed(const Duration(milliseconds: 800), () {
          // 检查是否有 showDialog 正在显示
          if (Navigator.of(context).canPop()) {
            _provider.needShowDialog = false;
            _provider.integralQueryOrder(
              onSuccess: () {
                EasyLoading.dismiss();
                showSuccessDialog();
              },
              onFailed: () {
                EasyLoading.dismiss();
              },
            );
            // Get.normalDialog(
            //   width: Get.width * 0.85,
            //   title: '支付确认',
            //   content: '支付成功，请点击【已支付】\n如未支付成功，请点击【取消】',
            //   confirmText: '已支付',
            //   cancelAction: () {
            //     _provider.needShowDialog = false;
            //   },
            //   confirmAction: () {
            //     _provider.needShowDialog = false;
            //     _provider.integralQueryOrder(
            //       onSuccess: () {
            //         EasyLoading.dismiss();
            //         showSuccessDialog();
            //       },
            //       onFailed: () {
            //         EasyLoading.dismiss();
            //         Get.normalDialog(
            //           width: Get.width * 0.85,
            //           title: '确认失败',
            //           showCancelBtn: false,
            //           content: '获取订单失败，如果已支付请联系客服解决问题',
            //           confirmText: '我知道了',
            //           confirmAction: () {
            //             Get.back();
            //           },
            //         );
            //       },
            //     );
            //   },
            // );
          }
        });
      }
    }
  }

  ///监听苹果支付成功状态
  iniIosPaySuccessSubscription() {
    // print("监听苹果支付成功状态");
    _iosPaySuccessSubscription = eventBus.on<QueryIosOrderEvent>().listen((
      event,
    ) {
      // print("票据-${event.serverVerificationData}");

      _provider.integralQueryOrder(
        receiptData: event.serverVerificationData,
        onSuccess: () {
          EasyLoading.dismiss();
          showSuccessDialog();
        },
        onFailed: () {
          EasyLoading.dismiss();
        },
      );
    });
    //成功回调
    _iosPaySuccessSubscription = eventBus
        .on<IosProductBuySuccessEvent>()
        .listen((e) {
          /// 充值成功
        });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Container(
        padding: EdgeInsets.only(bottom: 20.h),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitle(context),
              _buildRemainIntegral(),
              _buildIntegralList(context),
              _buildSelectedText(context),
              _buildPaymentMethod(context),
              _buildpayBtn(context),
              _buildAgreement(context),
            ],
          ),
        ),
      ),
    );
  }
}
