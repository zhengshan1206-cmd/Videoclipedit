import 'dart:async';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/modules/main/beans/launch_info_bean.dart';
import 'package:video_clip_edit/modules/main/controllers/new_user_benefits_controller.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_type_bean.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/modules/purchase/widgets/pay_success_dialog.dart';
import 'package:video_clip_edit/modules/purchase/widgets/pay_success_new_dialog.dart';
import 'package:video_clip_edit/modules/purchase/widgets/retention_vip_dailog.dart';
import 'package:video_clip_edit/modules/purchase/widgets/ios_purchase_agreement_view.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/providers/ios_purchase_provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_package_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/login/widgets/login_agreement_view.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:video_clip_edit/utils/pay/ios_buy_engine.dart';
import 'package:video_clip_edit/modules/purchase/mixins/purchase_page_back_mixin.dart';

class PurchasePageFour extends StatefulWidget {
  final bool? closePay;

  const PurchasePageFour({super.key, this.closePay});

  @override
  State<PurchasePageFour> createState() => _PurchasePageFourState();
}

class _PurchasePageFourState extends State<PurchasePageFour>
    with WidgetsBindingObserver, PurchasePageBackMixin {
  PurchaseProvider? provider;
  IosPurchaseProvider? iosPurchaseProvider;
  bool popWhenSuccess = false;
  bool _hasReportedExposure = false;

  /// iOS 支付相关监听
  StreamSubscription? _iosPaySuccessSubscription;
  StreamSubscription? _iosBuyStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      final bool? shouldPop =
          ModalRoute.of(context)?.settings.arguments as bool?;
      popWhenSuccess = shouldPop ?? false;
    });

    final isAudit = context.read<LaunchProvider>().launchInfo!.isAudit;

    if (Platform.isIOS) {
      // iOS 平台初始化
      _initIosPurchase(isAudit);
    } else {
      // Android 平台初始化
      _initAndroidPurchase(isAudit);
    }
  }

  /// 初始化 Android 支付
  void _initAndroidPurchase(int isAudit) {
    provider = context.read<PurchaseProvider>();
    provider?.resetFirstLayerRetentionForSession();
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

  /// 初始化 iOS 支付
  void _initIosPurchase(int isAudit) {
    iosPurchaseProvider = context.read<IosPurchaseProvider>();
    iosPurchaseProvider?.resetFirstLayerRetentionForSession();
    iosPurchaseProvider?.iosBuyEngin.initializeInAppPurchase();

    if (isAudit == 1) {
      Future.microtask(() {
        iosPurchaseProvider?.agreementCheckedStatusChanged(false);
      });
    }

    /// 加载VIP权益
    iosPurchaseProvider?.loadVipData();
    iosPurchaseProvider?.preLoginConfig();

    /// 获取支付挽留配置信息（用于左上角关闭按钮触发挽留弹窗）
    iosPurchaseProvider?.getPopConfig();

    /// 监听 iOS 支付成功
    _iniIosPaySuccessSubscription();
  }

  /// 监听苹果支付成功状态
  void _iniIosPaySuccessSubscription() {
    _iosPaySuccessSubscription = eventBus.on<QueryIosOrderEvent>().listen((
      event,
    ) {
      _queryIosOrderStatus(receiptData: event.serverVerificationData);
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    if (Platform.isIOS) {
      /// 取消 iOS 支付监听
      _iosPaySuccessSubscription?.cancel();
      _iosBuyStreamSubscription?.cancel();
    } else {
      /// 取消支付通知订阅
      provider?.cancelSubscribeWXPayResp();
      provider?.cancelSubscribeAliPayResp();
    }

    EasyLoading.dismiss();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Android / 鸿蒙：监听应用生命周期，从微信/支付宝返回时进行支付确认
    if (Platform.isAndroid || ByPackageUtils.isOhos) {
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
  }

  ///导航模块
  Widget _buildNavBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: ByScreenUtils.topSafeHeight,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            child: Image.asset(
              "assets/purchase/four/four-13.png",
              width: 20.w,
              height: 20.h,
            ),
          ),
          ByWidgetsUtil.commonText(
            text: "会员中心",
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),

          /// iOS 恢复购买按钮
          if (Platform.isIOS)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _iosRestorePurchase();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF502609).withOpacity(0.8),
                      width: 1,
                    ),
                  ),
                ),
                child: ByWidgetsUtil.commonText(
                  text: "恢复购买",
                  fontSize: 12.sp,
                  textColor: const Color(0xFF502609).withOpacity(0.8),
                ),
              ),
            )
          else
            SizedBox(width: 24.w),
        ],
      ),
    );
  }

  /// iOS 恢复购买
  void _iosRestorePurchase() {
    iosPurchaseProvider?.iosRepair(
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

  _showExitConfirmationDialog(BuildContext context) async {
    LaunchProvider launchProvider = context.read<LaunchProvider>();

    if (launchProvider.launchInfo?.isVip == 1) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        Get.offNamed(Routes.main);
      }
    } else {
      // 根据平台获取 isPreBack 状态
      final isPreBack = Platform.isIOS
          ? (iosPurchaseProvider?.isPreBack ?? false)
          : (provider?.isPreBack ?? false);

      if (isPreBack) {
        final pop =
            await showDialog(
              context: context,
              builder: (ctx) {
                if (Platform.isIOS) {
                  return ChangeNotifierProvider.value(
                    value: iosPurchaseProvider!,
                    child: RetentionVipDailog(
                      markUrl:
                          iosPurchaseProvider?.vipPageBean?.retainWindowUrl ??
                          '',
                    ),
                  );
                } else {
                  return ChangeNotifierProvider.value(
                    value: provider!,
                    child: RetentionVipDailog(
                      markUrl: provider?.vipPageBean?.retainWindowUrl ?? '',
                    ),
                  );
                }
              },
            ) ??
            false;
        if (pop) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context, true);
          } else {
            Get.offNamed(Routes.main);
          }
        }
      } else {
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        } else {
          Get.offNamed(Routes.main);
        }
      }
    }
  }

  ///营销模块
  Widget _buildMarketing() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 17.h),
      child: Column(
        children: [
          Image.asset(
            "assets/purchase/four/four-2.png",
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildMarketingItem(7, '短剧AI混剪')),
              Expanded(child: _buildMarketingItem(8, '爆款小说推文')),
              Expanded(child: _buildMarketingItem(9, '民间故事生成')),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildMarketingItem(10, 'AI动态视频')),
              Expanded(child: _buildMarketingItem(11, 'AI数字人')),
              Expanded(child: _buildMarketingItem(12, 'AI绘图')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketingItem(int num, String desc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          "assets/purchase/four/four-$num.png",
          width: 44.w,
          height: 44.h,
        ),
        SizedBox(height: 6.h),
        ByWidgetsUtil.commonText(
          text: desc,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          textColor: const Color(0xFF502609),
        ),
      ],
    );
  }

  ///标题
  Widget _buildTitle() {
    return Container(
      alignment: Alignment.center,
      child: ByWidgetsUtil.commonText(
        text: "选择套餐 得赚钱机会",
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        textColor: const Color(0xFF111111),
      ),
    );
  }

  ///套餐列表
  Widget _buildPackageList(
    List<VipTypeBean> vipTypeBeans,
    int selectedVIPTypeIndex,
  ) {
    if (vipTypeBeans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: vipTypeBeans.asMap().entries.map((entry) {
        final index = entry.key;
        final bean = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _buildPackageItem(bean, index, selectedVIPTypeIndex),
          ),
        );
      }).toList(),
    );
  }

  ///套餐Item
  Widget _buildPackageItem(
    VipTypeBean vipTypeBean,
    int index,
    int selectedVIPTypeIndex,
  ) {
    // 根据平台获取对应的 provider
    final vipTypeBeansList = Platform.isIOS
        ? iosPurchaseProvider?.vipTypeBeans ?? []
        : provider?.vipTypeBeans ?? [];

    final selected =
        selectedVIPTypeIndex < vipTypeBeansList.length &&
        vipTypeBeansList[selectedVIPTypeIndex].id == vipTypeBean.id;

    return GestureDetector(
      onTap: () {
        if (Platform.isIOS) {
          iosPurchaseProvider?.changeSelectedVipTypeIndex(
            index,
            vipTypeBean.appleVipId,
            vipTypeBean.id,
            vipTypeBean.des,
          );
        } else {
          provider?.changeSelectedVipTypeIndex(index);
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 140.h,
            margin: EdgeInsets.only(top: 5.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.w),
                topRight: Radius.circular(28.w),
                bottomLeft: Radius.circular(18.w),
                bottomRight: Radius.circular(18.w),
              ),
              image: DecorationImage(
                image: AssetImage(
                  selected
                      ? "assets/purchase/four/four-3.png"
                      : "assets/purchase/four/four-4.png",
                ),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                ByWidgetsUtil.commonText(
                  text: vipTypeBean.title,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  textColor: selected
                      ? const Color(0xFF804E13)
                      : const Color(0xFF444444),
                ),
                SizedBox(height: 6.h),
                // 价格显示区域 - 根据 vipListStyle 控制
                _buildPriceSection(vipTypeBean, selected),
                const Spacer(),
                // 底部价格/单位价格显示
                Container(
                  height: 24.h,
                  alignment: Alignment.center,
                  child: ByWidgetsUtil.commonText(
                    text: _getBottomPriceText(vipTypeBean),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    textColor: selected
                        ? ByColorUtil.WhiteColor
                        : const Color(0xFF804E13).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (vipTypeBean.mark.isNotEmpty && vipTypeBean.isDefault == 1)
            Positioned(
              top: 0.h,
              left: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.w),
                    topRight: Radius.circular(10.w),
                    bottomLeft: Radius.circular(0.w),
                    bottomRight: Radius.circular(10.w),
                  ),
                  gradient: LinearGradient(
                    colors: selected
                        ? [const Color(0xFFFF6B6B), const Color(0xFFFF387A)]
                        : [const Color(0xFFF5D990), const Color(0xFFF5D990)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ByWidgetsUtil.commonText(
                  text: vipTypeBean.mark,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  textColor: selected ? Colors.white : const Color(0xFF804E13),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建价格显示区域（根据 vipListStyle 控制）
  Widget _buildPriceSection(VipTypeBean vipTypeBean, bool selected) {
    // vipListStyle: 1-显示总价格, 2-显示每天价格, 3-显示月度价格
    final priceColor = selected
        ? const Color(0xFFFF4016)
        : const Color(0xFF222222);

    if (vipTypeBean.vipListStyle == 1) {
      // 样式1: 显示总价格
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ByWidgetsUtil.richText(
            unit: "¥",
            textColorUnit: priceColor,
            fontSizeUnit: 15.sp,
            partIntegral: vipTypeBean.money,
            textColorIntegral: priceColor,
            fontSizeIntegral: 32.sp,
          ),
        ],
      );
    } else if (vipTypeBean.vipListStyle == 2) {
      // 样式2: 显示每天价格
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ByWidgetsUtil.richText(
            unit: "≈",
            textColorUnit: priceColor,
            fontSizeUnit: 12.sp,
            partIntegral: vipTypeBean.dayMoney,
            textColorIntegral: priceColor,
            fontSizeIntegral: 28.sp,
          ),
          ByWidgetsUtil.commonText(
            text: "元/天",
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            textColor: priceColor,
          ),
        ],
      );
    } else {
      // 样式3: 显示月度价格或总价格
      final isMonthly = vipTypeBean.level == VIPLevel.monthy;
      final displayPrice = isMonthly
          ? vipTypeBean.money
          : vipTypeBean.monthMoney;
      final unit = isMonthly ? "¥" : "≈";
      final suffix = isMonthly ? "" : "元/月";

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ByWidgetsUtil.richText(
            unit: unit,
            textColorUnit: priceColor,
            fontSizeUnit: 12.sp,
            partIntegral: displayPrice,
            textColorIntegral: priceColor,
            fontSizeIntegral: 28.sp,
          ),
          if (suffix.isNotEmpty)
            ByWidgetsUtil.commonText(
              text: suffix,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              textColor: priceColor,
            ),
        ],
      );
    }
  }

  /// 获取底部价格文本
  String _getBottomPriceText(VipTypeBean vipTypeBean) {
    // vipListStyle == 1: 底部显示每天价格
    // 其他: 底部显示总价格
    if (vipTypeBean.vipListStyle == 1) {
      return "≈¥${vipTypeBean.dayMoney}/天";
    }
    return "¥${vipTypeBean.money}";
  }

  /// 构建套餐描述语
  Widget _buildPackageDescription(String description) {
    if (description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      padding: EdgeInsets.only(top: 12.h),
      child: ByWidgetsUtil.commonText(
        text: description,
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        textColor: const Color(0xFF999999).withOpacity(0.8),
        textAlign: TextAlign.center,
      ),
    );
  }

  ///支付方式（仅 Android 显示）
  Widget _buildPaymentMethod(int selectedPayMethodIndex) {
    // iOS 平台不显示支付方式选择
    if (Platform.isIOS) {
      return const SizedBox.shrink();
    }

    final currentProvider = provider;
    if (currentProvider == null) {
      return const SizedBox.shrink();
    }

    final payMethodBeans = currentProvider.payMethodBeans;

    if (payMethodBeans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(
          color: const Color(0xFFEBEBEB).withOpacity(0.6),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (selectedPayMethodIndex < payMethodBeans.length)
                Image.asset(
                  payMethodBeans[selectedPayMethodIndex].icon,
                  width: 22.w,
                  height: 22.w,
                ),
              SizedBox(width: 8.w),
              ByWidgetsUtil.commonText(
                text: selectedPayMethodIndex < payMethodBeans.length
                    ? payMethodBeans[selectedPayMethodIndex].payName
                    : '',
                fontSize: 14.sp,
                textColor: const Color(0xFF333333),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              // 切换支付方式
              if (payMethodBeans.length > 1) {
                final nextIndex =
                    (selectedPayMethodIndex + 1) % payMethodBeans.length;
                currentProvider.changeSelectedPayMethodIndex(nextIndex);
              }
            },
            child: Row(
              children: [
                if (payMethodBeans.length > 1)
                  ByWidgetsUtil.commonText(
                    text:
                        "(更换${payMethodBeans[(selectedPayMethodIndex + 1) % payMethodBeans.length].payName})",
                    fontSize: 12.sp,
                    textColor: const Color(0xFF4A4A4A).withOpacity(0.65),
                  ),
                SizedBox(width: 4.w),
                Image.asset(
                  "assets/purchase/four/four-14.png",
                  width: 20.w,
                  height: 20.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///底部按钮
  Widget _buildBottomButton() {
    final btnText = Platform.isIOS
        ? (iosPurchaseProvider?.memberBtnTxt.isNotEmpty == true
              ? iosPurchaseProvider!.memberBtnTxt
              : '立即解锁')
        : (provider?.memberBtnTxt.isNotEmpty == true
              ? provider!.memberBtnTxt
              : '立即解锁');

    return ScaleTransitionWidget(
      child: GestureDetector(
        onTap: () {
          toPay();
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/purchase/four/four-5.png"),
              fit: BoxFit.fill,
            ),
          ),
          width: 1.sw,
          height: 56.h,
          child: Center(
            child: ByWidgetsUtil.commonText(
              text: btnText,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              textColor: const Color(0xFF804E13),
            ),
          ),
        ),
      ),
    );
  }

  /// 协议
  Widget _buildAgreement() {
    if (Platform.isIOS) {
      return _buildIosAgreement();
    } else {
      return _buildAndroidAgreement();
    }
  }

  /// Android 协议
  Widget _buildAndroidAgreement() {
    final currentProvider = provider;
    if (currentProvider == null) return const SizedBox.shrink();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 如果没有展示选择按钮且是默认同意状态，点击协议文字不应取消同意
        if (currentProvider.agreementNum && currentProvider.isAgreementChecked) return;
        currentProvider.agreementCheckedStatusChanged(
          !currentProvider.isAgreementChecked,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!currentProvider.agreementNum)
                Image.asset(
                  currentProvider.isAgreementChecked
                      ? "assets/purchase/dark/checked_dark.png"
                      : "assets/purchase/dark/uncheck_dark.png",
                  height: 15.h,
                  color: const Color(0xFFFF3564),
                  fit: BoxFit.fitHeight,
                ),
              if (!currentProvider.agreementNum) SizedBox(width: 5.w),
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    ByWidgetsUtil.commonRichText(
                      texts: [
                        const TextSpan(text: "我已阅读并同意"),
                        TextSpan(
                          text: "《会员服务协议》",
                          style: const TextStyle(color: Color(0xFF000000)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              final url =
                                  currentProvider.vipPageBean?.user.protocolUrl;
                              debugPrint("open Url:$url");
                              if (url == null || url.isEmpty) return;
                              ByNavRouterUtils.jumpWebViewPage(
                                context,
                                "",
                                url,
                              );
                            },
                        ),
                        if (currentProvider.isShowIntegralAgreement)
                          TextSpan(
                            text: "《积分服务协议》",
                            style: const TextStyle(color: Color(0xFF000000)),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                final url = currentProvider
                                    .vipPageBean
                                    ?.user
                                    .integralRule;
                                debugPrint("open Url:$url");
                                if (url == null || url.isEmpty) return;
                                ByNavRouterUtils.jumpWebViewPage(
                                  context,
                                  "",
                                  url,
                                );
                              },
                          ),
                      ],
                      fontSize: 12.sp,
                      textColor: const Color(0xFF999999),
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

  /// iOS 协议
  Widget _buildIosAgreement() {
    final currentProvider = iosPurchaseProvider;
    if (currentProvider == null) return const SizedBox.shrink();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        currentProvider.agreementCheckedStatusChanged(
          !currentProvider.agreementChecked,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                currentProvider.agreementChecked
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
                          style: const TextStyle(color: Color(0xFF000000)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              final url =
                                  currentProvider.vipPageBean?.user.protocolUrl;
                              debugPrint("open Url:$url");
                              if (url == null || url.isEmpty) return;
                              ByNavRouterUtils.jumpWebViewPage(
                                context,
                                "",
                                url,
                              );
                            },
                        ),
                        const TextSpan(text: "和"),
                        TextSpan(
                          text: "《自动续费服务协议》",
                          style: const TextStyle(color: Color(0xFF000000)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              final url = currentProvider
                                  .vipPageBean
                                  ?.user
                                  .subScribeProtocolUrl;
                              debugPrint("open Url:$url");
                              if (url == null || url.isEmpty) return;
                              ByNavRouterUtils.jumpWebViewPage(
                                context,
                                "",
                                url,
                              );
                            },
                        ),
                        if (currentProvider.isShowIntegralAgreement)
                          TextSpan(
                            children: [
                              const TextSpan(text: "和"),
                              TextSpan(
                                text: "《积分服务协议》",
                                style: const TextStyle(
                                  color: Color(0xFF000000),
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    final url = currentProvider
                                        .vipPageBean
                                        ?.user
                                        .integralRule;
                                    debugPrint("open Url:$url");
                                    if (url == null || url.isEmpty) return;
                                    ByNavRouterUtils.jumpWebViewPage(
                                      context,
                                      "",
                                      url,
                                    );
                                  },
                              ),
                            ],
                          ),
                      ],
                      fontSize: 12.sp,
                      textColor: const Color(0xFF999999),
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

  ///调起支付方法
  void toPay({bool popPay = false, bool retentionPop = false}) {
    // 上报开通按钮点击
    if (Platform.isIOS) {
      final iosProvider = iosPurchaseProvider;
      if (iosProvider != null) {
        iosProvider.reportPayPageTopInfo(
          "member_page_open_btn",
          null,
          "click",
          vipId:
              iosProvider.vipTypeBeans.isNotEmpty &&
                  iosProvider.selectedVIPTypeIndex <
                      iosProvider.vipTypeBeans.length
              ? iosProvider.vipTypeBeans[iosProvider.selectedVIPTypeIndex].id
                    .toString()
              : null,
        );
      }
    } else {
      final androidProvider = provider;
      if (androidProvider != null) {
        androidProvider.reportPayPageTopInfo(
          "member_page_open_btn",
          null,
          "click",
          vipId:
              androidProvider.vipTypeBeans.isNotEmpty &&
                  androidProvider.selectedVIPTypeIndex <
                      androidProvider.vipTypeBeans.length
              ? androidProvider
                    .vipTypeBeans[androidProvider.selectedVIPTypeIndex]
                    .id
                    .toString()
              : null,
        );
      }
    }

    if (Platform.isIOS) {
      _toPayIos(popPay: popPay, retentionPop: retentionPop);
    } else {
      _toPayAndroid(popPay: popPay, retentionPop: retentionPop);
    }
  }

  /// Android 支付
  void _toPayAndroid({bool popPay = false, bool retentionPop = false}) {
    final currentProvider = provider;
    if (currentProvider == null) return;

    if (!currentProvider.isAgreementChecked) {
      // 上报协议弹窗显示
      currentProvider.reportPayPageTopInfo(
        "member_page_renew_protocol_dialog",
        null,
        "view",
        vipId:
            currentProvider.vipTypeBeans.isNotEmpty &&
                currentProvider.selectedVIPTypeIndex <
                    currentProvider.vipTypeBeans.length
            ? currentProvider
                  .vipTypeBeans[currentProvider.selectedVIPTypeIndex]
                  .id
                  .toString()
            : null,
      );

      showDialog(
        context: context,
        builder: (context) {
          return LoginAgreementView(
            btnTitle: "成为会员",
            registerMember: true,
            callback: () {
              // 上报协议弹窗开通按钮点击
              currentProvider.reportPayPageTopInfo(
                "member_page_renew_protocol_open_btn",
                null,
                "click",
                vipId:
                    currentProvider.vipTypeBeans.isNotEmpty &&
                        currentProvider.selectedVIPTypeIndex <
                            currentProvider.vipTypeBeans.length
                    ? currentProvider
                          .vipTypeBeans[currentProvider.selectedVIPTypeIndex]
                          .id
                          .toString()
                    : null,
              );

              currentProvider.agreementCheckedStatusChanged(true);

              /// 显示弹窗并写入plist
              currentProvider.createOrder(
                onSuccess: (payOrderBean) {},
                context: context,
                popPay: popPay,
                retentionPop: retentionPop,
              );
            },
            onClose: () {
              // 上报协议弹窗关闭按钮点击
              currentProvider.reportPayPageTopInfo(
                "member_page_renew_protocol_close_btn",
                null,
                "click",
                vipId:
                    currentProvider.vipTypeBeans.isNotEmpty &&
                        currentProvider.selectedVIPTypeIndex <
                            currentProvider.vipTypeBeans.length
                    ? currentProvider
                          .vipTypeBeans[currentProvider.selectedVIPTypeIndex]
                          .id
                          .toString()
                    : null,
              );
            },
          );
        },
      );
      return;
    }
    currentProvider.createOrder(
      onSuccess: (payOrderBean) {},
      context: context,
      popPay: popPay,
      retentionPop: retentionPop,
    );
  }

  /// iOS 支付
  void _toPayIos({bool popPay = false, bool retentionPop = false}) {
    final provider = iosPurchaseProvider;
    if (provider == null) return;

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
            iosPurchaseProvider: provider,
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
      onSuccess: (payOrderBean) {},
      context: context,
      popPay: popPay,
      retentionPop: retentionPop,
    );
  }

  /// 查询订单状态（Android）
  void _queryOrderStatus({String? loaddingText}) {
    final currentProvider = provider;
    if (currentProvider == null) return;

    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..maskType = EasyLoadingMaskType.custom
      ..indicatorType = EasyLoadingIndicatorType.cubeGrid
      ..indicatorColor = ByColorUtil.PurchasePriceTextColor
      ..loadingStyle = EasyLoadingStyle.light;
    EasyLoading.show(status: loaddingText, dismissOnTap: false);
    currentProvider.querryOrderStatus(
      onSuccess: () async {
        EasyLoading.dismiss();

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

        // Get.normalDialog(
        //   width: Get.width * 0.85,
        //   title: '确认失败',
        //   showCancelBtn: false,
        //   content: '获取订单失败，如果已支付请点击联系客服解决问题',
        //   confirmText: '联系客服',
        //   confirmAction: () {
        //     ByNavRouterUtils.jumpWebViewPage(
        //         context, '在线客服', currentProvider.vipPageBean?.kfUrl ?? "");
        //   },
        // );
      },
    );
  }

  /// 查询 iOS 订单状态
  void _queryIosOrderStatus({required String receiptData}) {
    iosPurchaseProvider?.queryOrderStatus(
      receiptData: receiptData,
      onSuccess: () async {},
    );
  }

  ///处理返回逻辑
  Future<void> _handleBack() async {
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

  void _reportBecomeMemberAddBtn() {
    if (Platform.isIOS) {
      final p = iosPurchaseProvider;
      if (p != null) {
        p.reportPayPageTopInfo(
          "member_page_become_member_add_btn",
          p.vipPageTopDataList.isNotEmpty ? p.vipPageTopDataList.first : null,
          "click",
          vipId: p.vipTypeBeans.isNotEmpty &&
                  p.selectedVIPTypeIndex < p.vipTypeBeans.length
              ? p.vipTypeBeans[p.selectedVIPTypeIndex].id.toString()
              : null,
        );
      }
    } else {
      final p = provider;
      if (p != null) {
        p.reportPayPageTopInfo(
          "member_page_become_member_add_btn",
          p.vipPageTopDataList.isNotEmpty ? p.vipPageTopDataList.first : null,
          "click",
          vipId: p.vipTypeBeans.isNotEmpty &&
                  p.selectedVIPTypeIndex < p.vipTypeBeans.length
              ? p.vipTypeBeans[p.selectedVIPTypeIndex].id.toString()
              : null,
        );
      }
    }
  }

  void _reportBecomeMemberCloseBtn() {
    if (Platform.isIOS) {
      final p = iosPurchaseProvider;
      if (p != null) {
        p.reportPayPageTopInfo(
          "member_page_become_member_close_btn",
          p.vipPageTopDataList.isNotEmpty ? p.vipPageTopDataList.first : null,
          "click",
          vipId: p.vipTypeBeans.isNotEmpty &&
                  p.selectedVIPTypeIndex < p.vipTypeBeans.length
              ? p.vipTypeBeans[p.selectedVIPTypeIndex].id.toString()
              : null,
        );
      }
    } else {
      final p = provider;
      if (p != null) {
        p.reportPayPageTopInfo(
          "member_page_become_member_close_btn",
          p.vipPageTopDataList.isNotEmpty ? p.vipPageTopDataList.first : null,
          "click",
          vipId: p.vipTypeBeans.isNotEmpty &&
                  p.selectedVIPTypeIndex < p.vipTypeBeans.length
              ? p.vipTypeBeans[p.selectedVIPTypeIndex].id.toString()
              : null,
        );
      }
    }
  }

  showSuccessDialog({String? title}) async {
    // 上报成为会员弹框显示
    if (Platform.isIOS) {
      final p = iosPurchaseProvider;
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
    } else {
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
    }
    Get.customDialog(
      barrierDismissible: false,
      widget:
          userController.payJumpImage.isNotEmpty &&
              userController.payJumpUrl.isNotEmpty
          ? PaySuccessNewDialog(
              onAddBtnTap: _reportBecomeMemberAddBtn,
              onCloseBtnTap: _reportBecomeMemberCloseBtn,
            )
          : PaySuccessDialog(
              title: title,
              onAddBtnTap: _reportBecomeMemberAddBtn,
              onCloseBtnTap: _reportBecomeMemberCloseBtn,
            ),
    ).then((_) {
      if (Navigator.canPop(context)) {
        ByNavRouterUtils.goBack(context);
      } else {
        Get.offNamed(Routes.main);
      }
    });
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
        backgroundColor: Colors.white,
        body: Platform.isIOS
            ? Consumer<IosPurchaseProvider>(
                builder:
                    (
                      BuildContext context,
                      IosPurchaseProvider iosPurchaseProvider,
                      Widget? child,
                    ) {
                      return _buildBody(context);
                    },
              )
            : Consumer<PurchaseProvider>(
                builder:
                    (
                      BuildContext context,
                      PurchaseProvider purchaseProvider,
                      Widget? child,
                    ) {
                      return _buildBody(context);
                    },
              ),
      ),
    );
  }

  /// 会员页曝光上报（PAGE_P_MEMBER_PAGE）
  void _reportPageExposure() {
    if (_hasReportedExposure) return;
    _hasReportedExposure = true;
    try {
      if (Platform.isIOS) {
        final p = iosPurchaseProvider;
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
      } else {
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
      }
    } catch (e) {
      debugPrint("_reportPageExposure error: $e");
    }
  }

  /// 构建页面主体
  Widget _buildBody(BuildContext context) {
    if (!_hasReportedExposure) {
      final hasData = Platform.isIOS
          ? (iosPurchaseProvider?.vipTypeBeans.isNotEmpty ?? false)
          : (provider?.vipTypeBeans.isNotEmpty ?? false);
      if (hasData) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _reportPageExposure();
        });
      }
    }
    // 在 _buildBody 中再次获取数据，确保在正确的 Consumer 上下文中
    final vipTypeBeans = Platform.isIOS
        ? context.select<IosPurchaseProvider, List<VipTypeBean>>(
            (provider) => provider.vipTypeBeans,
          )
        : context.select<PurchaseProvider, List<VipTypeBean>>(
            (provider) => provider.vipTypeBeans,
          );

    final selectedVIPTypeIndex = Platform.isIOS
        ? context.select<IosPurchaseProvider, int>(
            (val) => val.selectedVIPTypeIndex,
          )
        : context.select<PurchaseProvider, int>(
            (val) => val.selectedVIPTypeIndex,
          );

    final selectedPayMethodIndex = Platform.isIOS
        ? 0
        : context.select<PurchaseProvider, int>(
            (val) => val.selectedPayMethodIndex,
          );

    final packageDescription = Platform.isIOS
        ? context.select<IosPurchaseProvider, String>(
            (provider) => provider.showHintText,
          )
        : context.select<PurchaseProvider, String>(
            (provider) => provider.premiumTips,
          );

    return Stack(
      children: [
        // 背景图
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            "assets/purchase/four/four-1.png",
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        // 顶部内容
        Column(
          children: [
            _buildNavBar(),
            SizedBox(height: 20.h),
            _buildMarketing(),
          ],
        ),
        // 底部白色卡片
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              top: 16.h,
              bottom: context.byBottomSafeHeight + 6.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.w),
                topRight: Radius.circular(20.w),
              ),
              image: const DecorationImage(
                image: AssetImage("assets/purchase/four/four-6.png"),
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitle(),
                SizedBox(height: 16.h),
                _buildPackageList(vipTypeBeans, selectedVIPTypeIndex),
                _buildPackageDescription(packageDescription),
                _buildPaymentMethod(selectedPayMethodIndex),
                _buildBottomButton(),
                _buildAgreement(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
