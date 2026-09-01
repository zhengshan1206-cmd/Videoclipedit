import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_type_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/pay_method_bean.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/modules/login/widgets/login_agreement_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/ios_purchase_agreement_view.dart';
import 'package:video_clip_edit/modules/purchase/widgets/pay_success_dialog.dart';
import 'package:video_clip_edit/modules/purchase/widgets/pay_success_new_dialog.dart';
import 'package:video_clip_edit/modules/main/controllers/new_user_benefits_controller.dart';
import 'package:video_clip_edit/modules/main/beans/launch_info_bean.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/providers/ios_purchase_provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/pay/ios_buy_engine.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/modules/purchase/mixins/purchase_page_back_mixin.dart';

class PurchasePageFive extends StatefulWidget {
  const PurchasePageFive({super.key});

  @override
  State<PurchasePageFive> createState() => _PurchasePageFiveState();
}

class _PurchasePageFiveState extends State<PurchasePageFive>
    with WidgetsBindingObserver, PurchasePageBackMixin {
  PurchaseProvider? provider;
  IosPurchaseProvider? iosPurchaseProvider;

  /// iOS 支付相关监听
  StreamSubscription? _iosPaySuccessSubscription;
  StreamSubscription? _iosBuyStreamSubscription;
  bool _hasReportedExposure = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 使用 Future.microtask 确保 context 已经准备好
    Future.microtask(() {
      if (!mounted) return;

      final isAudit = context.read<LaunchProvider>().launchInfo!.isAudit;

      if (Platform.isIOS) {
        // iOS 平台初始化
        _initIosPurchase(isAudit);
      } else {
        // Android 平台初始化
        _initAndroidPurchase(isAudit);
      }
    });
  }

  /// 初始化 Android 支付
  void _initAndroidPurchase(int isAudit) {
    provider = context.read<PurchaseProvider>();
    // 每次进入付费页重置第一层挽留弹窗的「当次已展示」标记
    provider?.resetFirstLayerRetentionForSession();
    // 根据审核状态和归因用户状态初始化协议勾选状态
    Future.microtask(() {
      provider?.initAgreementStatus();
    });

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

    /// 加载付费页顶部运营素材信息
    provider?.loadPayPageTopInfo();

    /// 获取支付挽留配置信息
    provider?.getPopConfig();
  }

  /// 初始化 iOS 支付
  void _initIosPurchase(int isAudit) {
    iosPurchaseProvider = context.read<IosPurchaseProvider>();
    // 每次进入付费页重置第一层挽留弹窗的「当次已展示」标记
    iosPurchaseProvider?.resetFirstLayerRetentionForSession();
    iosPurchaseProvider?.iosBuyEngin.initializeInAppPurchase();

    // 根据审核状态初始化协议勾选状态（非审核状态下也不勾选）
    Future.microtask(() {
      iosPurchaseProvider?.initAgreementStatus();
    });

    /// 加载VIP权益
    iosPurchaseProvider?.loadVipData();
    iosPurchaseProvider?.preLoginConfig();

    /// 加载付费页顶部运营素材信息
    iosPurchaseProvider?.loadPayPageTopInfo();

    /// 获取支付挽留配置信息
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
    // 只有 Android 平台需要监听应用生命周期进行支付确认
    if (Platform.isAndroid) {
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
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

  /// 构建页面主体 - 参考 purchase_page_four.dart 的方式，使用 context.select 获取数据
  Widget _buildBody(BuildContext context) {
    // 使用 context.select 直接从 provider 获取数据，确保数据是最新的
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

    final payMethodBeans = Platform.isIOS
        ? null
        : context.select<PurchaseProvider, List<PayMethodBean>>(
            (provider) => provider.payMethodBeans,
          );

    final selectedPayMethodIndex = Platform.isIOS
        ? null
        : context.select<PurchaseProvider, int>(
            (val) => val.selectedPayMethodIndex,
          );

    final isAgreementChecked = Platform.isIOS
        ? context.select<IosPurchaseProvider, bool>(
            (val) => val.agreementChecked,
          )
        : context.select<PurchaseProvider, bool>(
            (val) => val.isAgreementChecked,
          );

    final memberBtnTxt = Platform.isIOS
        ? context.select<IosPurchaseProvider, String>((val) => val.memberBtnTxt)
        : context.select<PurchaseProvider, String>((val) => val.memberBtnTxt);

    final imageList = Platform.isIOS
        ? context.select<IosPurchaseProvider, List<String>>(
            (val) => val.vipPageTopDataList,
          )
        : context.select<PurchaseProvider, List<String>>(
            (val) => val.vipPageTopDataList,
          );

    // 数据加载完成后进行曝光上报（只上报一次）
    if (vipTypeBeans.isNotEmpty && !_hasReportedExposure) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _reportPageExposure();
        }
      });
    }

    return Stack(
      children: [
        _buildMemberCenterBody(
          vipTypeBeans,
          selectedVIPTypeIndex,
          payMethodBeans,
          selectedPayMethodIndex,
          isAgreementChecked,
          memberBtnTxt,
          imageList,
        ),
      ],
    );
  }

  /// 页面曝光上报
  void _reportPageExposure() {
    // 确保只上报一次
    if (_hasReportedExposure) return;
    _hasReportedExposure = true;

    try {
      if (Platform.isIOS) {
        final iosProvider = iosPurchaseProvider;
        if (iosProvider != null &&
            iosProvider.vipTypeBeans.isNotEmpty &&
            iosProvider.selectedVIPTypeIndex <
                iosProvider.vipTypeBeans.length) {
          iosProvider.reportPayPageTopInfo(
            "member_page",
            iosProvider.vipPageTopDataList.isNotEmpty
                ? iosProvider.vipPageTopDataList.first
                : null,
            "view",
            vipId: iosProvider.vipTypeBeans[iosProvider.selectedVIPTypeIndex].id
                .toString(),
          );
        }
      } else {
        final androidProvider = provider;
        if (androidProvider != null &&
            androidProvider.vipTypeBeans.isNotEmpty &&
            androidProvider.selectedVIPTypeIndex <
                androidProvider.vipTypeBeans.length) {
          androidProvider.reportPayPageTopInfo(
            "member_page",
            androidProvider.vipPageTopDataList.isNotEmpty
                ? androidProvider.vipPageTopDataList.first
                : null,
            "view",
            vipId: androidProvider
                .vipTypeBeans[androidProvider.selectedVIPTypeIndex]
                .id
                .toString(),
          );
        }
      }
    } catch (e) {
      debugPrint("_reportPageExposure error: $e");
    }
  }

  ///关闭按钮
  Widget _buildCloseButton() {
    return Positioned(
      top: ByScreenUtils.topSafeHeight,
      left: 4.w,
      child: GestureDetector(
        onTap: () async {
          await _handleBack();
        },
        child: Container(
          width: 48.w,
          height: 48.w,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/v2/promote/promote-9.png',
            width: 32.w,
            height: 32.w,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  ///处理返回逻辑
  Future<void> _handleBack() async {
    await handlePurchasePageBack(
      context: context,
      onPay: () {
        if (Platform.isIOS) {
          _toPayIos(popPay: true, retentionPop: true);
        } else {
          _toPayAndroid(popPay: true, retentionPop: true);
        }
      },
      onGoBack: _goBack,
    );

    // 旧版本逻辑3.10.41以前

    // // 检查新用户福利控制器
    // if (Get.isRegistered<NewUserBenefitsController>() == true &&
    //     Get.find<NewUserBenefitsController>().showType.value == 2) {
    //   // 上报拦截弹框显示
    //   _reportPayPageTopInfo("member_page_intercept_dialog", "view");

    //   bool value = await Get.find<NewUserBenefitsController>().retentionDialog(
    //       callPay: () {
    //     // 上报拦截弹框开通按钮点击
    //     _reportPayPageTopInfo("member_page_intercept_open_btn", "click");
    //     toPay(popPay: true);
    //   });
    //   if (value == true) {
    //     // 上报拦截弹框关闭按钮点击
    //     _reportPayPageTopInfo("member_page_intercept_close_btn", "click");
    //     _goBack();
    //     return;
    //   }
    //   return;
    // }

    // // 根据平台获取 isPreBack 状态
    // final isPreBack = Platform.isIOS
    //     ? (iosPurchaseProvider?.isPreBack ?? false)
    //     : (provider?.isPreBack ?? false);

    // if (!isPreBack) {
    //   _goBack();
    //   return;
    // }

    // // 上报留存弹窗显示
    // _reportPayPageTopInfo("member_page_retention_dialog", "view");

    // // 显示留存弹窗
    // final pop = await showDialog(
    //       context: context,
    //       builder: (ctx) {
    //         if (Platform.isIOS) {
    //           return ChangeNotifierProvider.value(
    //             value: iosPurchaseProvider!,
    //             child: RetentionVipDailog(
    //               markUrl:
    //                   iosPurchaseProvider?.vipPageBean?.retainWindowUrl ?? '',
    //               onOpenBtnTap: () {
    //                 // 上报留存弹窗开通按钮点击
    //                 _reportPayPageTopInfo(
    //                     "member_page_retention_open_btn", "click");
    //               },
    //               onCloseBtnTap: () {
    //                 // 上报留存弹窗关闭按钮点击
    //                 _reportPayPageTopInfo(
    //                     "member_page_retention_close_btn", "click");
    //               },
    //             ),
    //           );
    //         } else {
    //           return ChangeNotifierProvider.value(
    //             value: provider!,
    //             child: RetentionVipDailog(
    //               markUrl: provider?.vipPageBean?.retainWindowUrl ?? '',
    //               onOpenBtnTap: () {
    //                 // 上报留存弹窗开通按钮点击
    //                 _reportPayPageTopInfo(
    //                     "member_page_retention_open_btn", "click");
    //               },
    //               onCloseBtnTap: () {
    //                 // 上报留存弹窗关闭按钮点击
    //                 _reportPayPageTopInfo(
    //                     "member_page_retention_close_btn", "click");
    //               },
    //             ),
    //           );
    //         }
    //       },
    //     ) ??
    //     false;

    // if (pop) {
    //   _goBack();
    // }
  }

  ///路由返回页面方法
  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    } else {
      Get.offNamed(Routes.main);
    }
  }

  /// 获取当前 provider 的数据用于上报
  ({
    List<VipTypeBean> vipTypeBeans,
    int selectedVIPTypeIndex,
    List<String> vipPageTopDataList,
  })
  _getProviderDataForReport() {
    final vipTypeBeans = Platform.isIOS
        ? iosPurchaseProvider?.vipTypeBeans ?? []
        : provider?.vipTypeBeans ?? [];
    final selectedVIPTypeIndex = Platform.isIOS
        ? (iosPurchaseProvider?.selectedVIPTypeIndex ?? 0)
        : (provider?.selectedVIPTypeIndex ?? 0);
    final vipPageTopDataList = Platform.isIOS
        ? (iosPurchaseProvider?.vipPageTopDataList ?? [])
        : (provider?.vipPageTopDataList ?? []);
    return (
      vipTypeBeans: vipTypeBeans,
      selectedVIPTypeIndex: selectedVIPTypeIndex,
      vipPageTopDataList: vipPageTopDataList,
    );
  }

  /// 获取当前选中的套餐ID
  String? _getCurrentVipId({
    required List<VipTypeBean> vipTypeBeans,
    required int selectedVIPTypeIndex,
  }) {
    if (vipTypeBeans.isNotEmpty && selectedVIPTypeIndex < vipTypeBeans.length) {
      return vipTypeBeans[selectedVIPTypeIndex].id.toString();
    }
    return null;
  }

  /// 统一上报方法
  void _reportPayPageTopInfo(
    String pageTag,
    String operateType, {
    String? vipId,
    int payType = 0,
  }) {
    final data = _getProviderDataForReport();
    final currentVipId =
        vipId ??
        _getCurrentVipId(
          vipTypeBeans: data.vipTypeBeans,
          selectedVIPTypeIndex: data.selectedVIPTypeIndex,
        );
    final funcDetailImg = data.vipPageTopDataList.isNotEmpty
        ? data.vipPageTopDataList.first
        : null;

    if (Platform.isIOS) {
      iosPurchaseProvider?.reportPayPageTopInfo(
        pageTag,
        funcDetailImg,
        operateType,
        vipId: currentVipId,
        payType: payType,
      );
    } else {
      provider?.reportPayPageTopInfo(
        pageTag,
        funcDetailImg,
        operateType,
        vipId: currentVipId,
        payType: payType,
      );
    }
  }

  ///会员中心主体
  Widget _buildMemberCenterBody(
    List<VipTypeBean> vipTypeBeans,
    int selectedVIPTypeIndex, [
    List<PayMethodBean>? payMethodBeans,
    int? selectedPayMethodIndex,
    bool? isAgreementChecked,
    String? memberBtnTxt,
    List<String> imageList = const [],
  ]) {
    return Stack(
      children: [
        // 可滚动内容区域
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: ByScreenUtils.bottomSafeHeight + 20.h, // 为底部按钮和协议预留空间
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildBannerView(imageList),
              _buildVipPackageListView(vipTypeBeans, selectedVIPTypeIndex),
              SizedBox(height: 10.h),
              _buildPayMethodView(payMethodBeans, selectedPayMethodIndex),
              SizedBox(height: 120.h), // 底部间距，避免内容被遮挡
            ],
          ),
        ),
        // 固定在底部的按钮和协议
        Positioned(
          bottom: ByScreenUtils.bottomSafeHeight,
          left: 0,
          right: 0,
          child: Container(
            color: const Color(0xFFF6F6F6), // 背景色，避免内容透过
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBottomButton(memberBtnTxt),
                _buildAgreement(isAgreementChecked),
              ],
            ),
          ),
        ),

        _buildCloseButton(),
      ],
    );
  }

  /// 验证URL是否有效
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    try {
      final uri = Uri.parse(url);
      // 检查是否有scheme和host
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority &&
          uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  ///顶部内容banner区域
  Widget _buildBannerView(List<String> imageList) {
    // 如果列表有数据，显示轮播图
    if (imageList.isNotEmpty) {
      // 过滤掉空字符串或无效的URL
      final validImageList = imageList
          .where((url) => _isValidImageUrl(url))
          .toList();

      if (validImageList.isEmpty) {
        // 如果没有有效的图片URL，显示默认图片
        return SizedBox(
          width: 1.sw,
          height: 420.h,
          child: Image.asset(
            'assets/v2/promote/promote-13.png',
            width: 1.sw,
            height: 420.h,
            fit: BoxFit.fill,
          ),
        );
      }

      return SizedBox(
        width: 1.sw,
        height: 420.h,
        child: Swiper(
          autoplay: true,
          itemCount: validImageList.length,
          itemBuilder: (context, index) {
            final imageUrl = validImageList[index];
            if (!_isValidImageUrl(imageUrl)) {
              return Image.asset(
                'assets/v2/promote/promote-13.png',
                width: 1.sw,
                height: 420.h,
                fit: BoxFit.fill,
              );
            }
            return CachedNetworkImage(
              imageUrl: imageUrl,
              width: 1.sw,
              height: 420.h,
              fit: BoxFit.fill,
              errorWidget: (context, url, error) {
                return Image.asset(
                  'assets/v2/promote/promote-13.png',
                  width: 1.sw,
                  height: 420.h,
                  fit: BoxFit.fill,
                );
              },
            );
          },
        ),
      );
    }

    // 如果列表没有数据，显示默认图片
    return SizedBox(
      width: 1.sw,
      height: 420.h,
      child: Image.asset(
        'assets/v2/promote/promote-13.png',
        width: 1.sw,
        height: 420.h,
        fit: BoxFit.fill,
      ),
    );
  }

  ///vip套餐列表
  Widget _buildVipPackageListView(
    List<VipTypeBean> vipTypeBeans,
    int selectedVIPTypeIndex,
  ) {
    if (vipTypeBeans.isEmpty) {
      // 数据为空时显示加载提示
      return Container(
        padding: EdgeInsets.all(20.w),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 12.h),
              ByWidgetsUtil.commonText(
                text: "加载中...",
                fontSize: 14.sp,
                textColor: const Color(0xFF999999),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: vipTypeBeans.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        // 使用 Selector 监听 selectedVIPTypeIndex 的变化，确保选中状态更新
        if (Platform.isIOS) {
          return Selector<IosPurchaseProvider, int>(
            selector: (_, provider) => provider.selectedVIPTypeIndex,
            builder: (context, selectedIndex, child) {
              return _buildCaseView(vipTypeBeans[index], index, selectedIndex);
            },
          );
        } else {
          return Selector<PurchaseProvider, int>(
            selector: (_, provider) => provider.selectedVIPTypeIndex,
            builder: (context, selectedIndex, child) {
              return _buildCaseView(vipTypeBeans[index], index, selectedIndex);
            },
          );
        }
      },
    );
  }

  ///套餐Item
  Widget _buildCaseView(
    VipTypeBean vipTypeBean,
    int index,
    int selectedVIPTypeIndex,
  ) {
    // 根据 vipListStyle 和 level 确定价格显示方式
    final priceText = _getPriceText(vipTypeBean);
    final priceUnit = _getPriceUnit(vipTypeBean);

    // 判断是否选中 - 直接比较索引，更简单直接
    final isSelected = index == selectedVIPTypeIndex;

    return GestureDetector(
      onTap: () {
        // 切换选中状态
        if (Platform.isIOS) {
          final provider = context.read<IosPurchaseProvider>();
          provider.changeSelectedVipTypeIndex(
            index,
            vipTypeBean.appleVipId,
            vipTypeBean.id,
            vipTypeBean.des,
          );
        } else {
          final provider = context.read<PurchaseProvider>();
          provider.changeSelectedVipTypeIndex(index);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.w),
        margin: EdgeInsets.only(bottom: 5.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              height: 69.h,
              padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                top: 12.w,
                bottom: 10.w,
              ),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF0EC) : Colors.white,
                borderRadius: BorderRadius.circular(10.w),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFD7A54).withOpacity(0.8)
                      : Colors.transparent,
                  width: 1.5.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10.w,
                    offset: Offset(0, 10.w),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ByWidgetsUtil.commonText(
                          text: vipTypeBean.title,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          textColor: const Color(0xFF111111),
                        ),
                        SizedBox(height: 2.h),
                        if (vipTypeBean.des.isNotEmpty) ...[
                          ByWidgetsUtil.commonText(
                            text: vipTypeBean.des,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            textColor: const Color(0xFF797A78),
                            maxLines: 1,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: priceUnit,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFFFF1151)
                                : const Color(0xFF797A78),
                          ),
                        ),
                        TextSpan(
                          text: priceText,
                          style: TextStyle(
                            fontSize: 29.sp,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFFFF1151)
                                : const Color(0xFF797A78),
                          ),
                        ),
                        TextSpan(
                          text: _getPriceSuffix(vipTypeBean),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFFFF1151)
                                : const Color(0xFF797A78),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
            // 标记显示
            if (vipTypeBean.mark.isNotEmpty && vipTypeBean.isDefault == 1)
              Positioned(
                top: -10.h,
                right: 0.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.w),
                      topRight: Radius.circular(8.w),
                      bottomRight: Radius.circular(0.w),
                      bottomLeft: Radius.circular(12.w),
                    ),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFC3E28), Color(0xFFFC7F45)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/v2/promote/promote-16.png',
                        width: 10.w,
                        height: 10.w,
                      ),
                      SizedBox(width: 4.w),
                      ByWidgetsUtil.commonText(
                        text: vipTypeBean.mark,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 获取价格文本
  String _getPriceText(VipTypeBean vipTypeBean) {
    if (vipTypeBean.vipListStyle == 1) {
      // 样式1: 显示总价格
      return vipTypeBean.money;
    } else if (vipTypeBean.vipListStyle == 2) {
      // 样式2: 显示每天价格
      return vipTypeBean.dayMoney;
    } else {
      // 样式3: 根据 level 显示月度价格或总价格
      final isMonthly = vipTypeBean.level == VIPLevel.monthy;
      return isMonthly ? vipTypeBean.money : vipTypeBean.monthMoney;
    }
  }

  /// 获取价格单位
  String _getPriceUnit(VipTypeBean vipTypeBean) {
    if (vipTypeBean.vipListStyle == 2) {
      // 样式2: 每天价格，使用 ≈
      return "¥";
    } else if (vipTypeBean.vipListStyle == 3 &&
        vipTypeBean.level != VIPLevel.monthy) {
      // 样式3: 非月度会员，使用 ≈
      return "¥";
    } else {
      // 其他情况使用 ¥
      return "¥";
    }
  }

  /// 获取价格后缀
  String _getPriceSuffix(VipTypeBean vipTypeBean) {
    if (vipTypeBean.vipListStyle == 1) {
      // 样式1: 显示总价格，根据 level 显示后缀
      // return _getLevelSuffix(vipTypeBean.level);
      return "/元";
    } else if (vipTypeBean.vipListStyle == 2) {
      // 样式2: 显示每天价格
      return "/日均";
    } else {
      // 样式3: 根据 level 显示后缀
      final isMonthly = vipTypeBean.level == VIPLevel.monthy;
      return isMonthly ? "/月均" : "/月均";
    }
  }

  /// 根据 VIP 级别获取后缀
  String _getLevelSuffix(VIPLevel level) {
    switch (level) {
      case VIPLevel.monthy:
        return "/月均";
      case VIPLevel.quarterly:
        return "/季均";
      case VIPLevel.yearly:
        return "/年均";
      case VIPLevel.lifeTime:
      case VIPLevel.exclusive:
        return "/元";
      default:
        return "";
    }
  }

  ///支付方式选择
  Widget _buildPayMethodView(
    List<PayMethodBean>? payMethodBeans,
    int? selectedPayMethodIndex,
  ) {
    // iOS 平台不显示支付方式选择
    if (Platform.isIOS) {
      return const SizedBox.shrink();
    }

    if (payMethodBeans == null || payMethodBeans.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentSelectedIndex = selectedPayMethodIndex ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      margin: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: payMethodBeans.asMap().entries.map((entry) {
          final index = entry.key;
          final payMethod = entry.value;
          final isSelected = index == currentSelectedIndex;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: _buildPayMethodItem(payMethod, index, isSelected),
            ),
          );
        }).toList(),
      ),
    );
  }

  ///支付方式Item
  Widget _buildPayMethodItem(
    PayMethodBean payMethod,
    int index,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        final provider = context.read<PurchaseProvider>();
        provider.changeSelectedPayMethodIndex(index);
      },
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10.w,
              offset: Offset(0, 2.w),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(payMethod.icon, width: 18.w, height: 18.w),
                SizedBox(width: 4.w),
                ByWidgetsUtil.commonText(
                  text: payMethod.payName,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  textColor: const Color(0xFF212121).withOpacity(0.5),
                ),
              ],
            ),
            // 选中状态指示器
            Image.asset(
              isSelected
                  ? 'assets/v2/promote/promote-15.png'
                  : 'assets/v2/promote/promote-14.png',
              width: 20.w,
              height: 20.w,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  ///底部按钮
  Widget _buildBottomButton(String? memberBtnTxt) {
    final btnText = memberBtnTxt?.isNotEmpty == true ? memberBtnTxt! : '立即解锁';

    return ScaleTransitionWidget(
      child: GestureDetector(
        onTap: () {
          // 根据平台使用对应的 provider 上报事件
          if (Platform.isIOS) {
            final iosProvider = context.read<IosPurchaseProvider>();
            iosProvider.reportPayPageTopInfo(
              "member_page_open_btn",
              iosProvider.vipPageTopDataList.isNotEmpty
                  ? iosProvider.vipPageTopDataList.first
                  : null,
              "click",
              vipId:
                  iosProvider.vipTypeBeans.isNotEmpty &&
                      iosProvider.selectedVIPTypeIndex <
                          iosProvider.vipTypeBeans.length
                  ? iosProvider
                        .vipTypeBeans[iosProvider.selectedVIPTypeIndex]
                        .id
                        .toString()
                  : null,
            );
          } else {
            final androidProvider = context.read<PurchaseProvider>();
            androidProvider.reportPayPageTopInfo(
              "member_page_open_btn",
              androidProvider.vipPageTopDataList.isNotEmpty
                  ? androidProvider.vipPageTopDataList.first
                  : null,
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
          toPay();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30.w)),
            gradient: const LinearGradient(
              colors: [Color(0xFFFC3E28), Color(0xFFFC7F45)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          width: 1.sw,
          height: 56.h,
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          child: Center(
            child: ByWidgetsUtil.commonText(
              text: btnText,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              textColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// 协议
  Widget _buildAgreement(bool? isAgreementChecked) {
    if (Platform.isIOS) {
      return _buildIosAgreement(isAgreementChecked ?? false);
    } else {
      return _buildAndroidAgreement(isAgreementChecked ?? false);
    }
  }

  /// Android 协议
  Widget _buildAndroidAgreement(bool isAgreementChecked) {
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
  Widget _buildIosAgreement(bool isAgreementChecked) {
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
      final provider = context.read<PurchaseProvider>();
      provider.reportPayPageTopInfo(
        "member_page_renew_protocol_dialog",
        provider.vipPageTopDataList.isNotEmpty
            ? provider.vipPageTopDataList.first
            : null,
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
            btnTitle: "成为会员",
            registerMember: true,
            callback: () {
              final provider = context.read<PurchaseProvider>();
              provider.reportPayPageTopInfo(
                "member_page_renew_protocol_open_btn",
                provider.vipPageTopDataList.isNotEmpty
                    ? provider.vipPageTopDataList.first
                    : null,
                "click",
                vipId:
                    provider.vipTypeBeans.isNotEmpty &&
                        provider.selectedVIPTypeIndex <
                            provider.vipTypeBeans.length
                    ? provider.vipTypeBeans[provider.selectedVIPTypeIndex].id
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
              final provider = context.read<PurchaseProvider>();
              provider.reportPayPageTopInfo(
                "member_page_renew_protocol_close_btn",
                provider.vipPageTopDataList.isNotEmpty
                    ? provider.vipPageTopDataList.first
                    : null,
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
    currentProvider.createOrder(
      onSuccess: (payOrderBean) {},
      context: context,
      popPay: popPay,
      retentionPop: retentionPop,
    );
  }

  /// iOS 支付
  void _toPayIos({bool popPay = false, bool retentionPop = false}) {
    final currentProvider = iosPurchaseProvider;
    if (currentProvider == null) return;

    if (!currentProvider.agreementChecked) {
      // 上报协议弹窗显示
      currentProvider.reportPayPageTopInfo(
        "member_page_renew_protocol_dialog",
        currentProvider.vipPageTopDataList.isNotEmpty
            ? currentProvider.vipPageTopDataList.first
            : null,
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

      bool hasClickedConfirm = false;
      showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) {
          return IosPurchaseAgreementView(
            iosPurchaseProvider: currentProvider,
            btnTitle: "成为会员",
            registerMember: true,
            callback: () {
              hasClickedConfirm = true;
              // 上报协议弹窗开通按钮点击
              currentProvider.reportPayPageTopInfo(
                "member_page_renew_protocol_open_btn",
                currentProvider.vipPageTopDataList.isNotEmpty
                    ? currentProvider.vipPageTopDataList.first
                    : null,
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

              /// 创建 iOS 订单
              currentProvider.createIosOrder(
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
          currentProvider.reportPayPageTopInfo(
            "member_page_renew_protocol_close_btn",
            currentProvider.vipPageTopDataList.isNotEmpty
                ? currentProvider.vipPageTopDataList.first
                : null,
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
        }
      });
      return;
    }
    currentProvider.createIosOrder(
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
        //       context,
        //       '在线客服',
        //       currentProvider.vipPageBean?.kfUrl ?? "",
        //     );
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
}
