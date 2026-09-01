import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/core/util/common_ui.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/routes/route_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/minorMode/controllers/minor_mode_controller.dart';
import 'package:video_clip_edit/v2/profile/controllers/home_mine_controller.dart';
import 'package:video_clip_edit/core/base/base_view.dart';
import 'package:video_clip_edit/v2/profile/widget/bubble_view.dart';
import 'package:video_clip_edit/v2/profile/widget/profile_member_card.dart';
import 'package:video_clip_edit/widgets/common_button.dart';
import 'package:video_clip_edit/widgets/form/custom_text_form_field.dart';
import 'package:video_clip_edit/widgets/image/by_image_view.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../modules/home/widgets/sub_funcs_view.dart';
import '../../../utils/comon/by_common_utils.dart';
import '../../../utils/pay/ios_buy_engine.dart';
import '../../aiSquare/widgets/ai_video_player.dart';

class HomeMinePage extends StatefulWidget {
  const HomeMinePage({super.key});

  @override
  State<HomeMinePage> createState() => _HomeMinePageState();
}

class _HomeMinePageState extends State<HomeMinePage> {
  final controller = Get.find<HomeMineController>();

  final GlobalKey _customerServiceKey = GlobalKey();

  late StreamSubscription _buySuccessStreamSubscription;
  bool _hasReportedBannerView = false; // 标记是否已上报banner view事件
  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    // 在布局完成后计算气泡位置
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.calculatePosition(_customerServiceKey),
    );

    // 每次进入页面时更新用户信息
    // controller.userController.reloadUserInfo();
    _buySuccessStreamSubscription = eventBus.on<BuySuccessEvent>().listen((e) {
      controller.isShowBanner = true;
      controller.loadMenuData();
    });

    // 注意：banner view上报在 VisibilityDetector 的 onVisibilityChanged 中处理
    // 确保只在页面可见时上报，而不是在接口请求成功后上报
  }

  /// 上报banner view事件（如果有数据且未上报过）
  void _reportBannerViewIfNeeded() {
    // if (_hasReportedBannerView) return;

    final menuItemBeans = controller.menuItemBeans;
    if (menuItemBeans != null &&
        menuItemBeans.isNotEmpty &&
        controller.isShowBanner) {
      _hasReportedBannerView = true;
      ByNavigatorUtil.reportDataPoint(
        pageTag: "banner",
        operateType: "view",
        funcDetailTag: menuItemBeans.first.id.toString(),
        funcDetailImg: menuItemBeans.first.imgUrl,
        extra: {"position": "mine"},
      );
    }
  }

  @override
  void dispose() {
    _buySuccessStreamSubscription.cancel;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeMineController>(
      builder: (controller) {
        return VisibilityDetector(
          key: const Key('home_mine_page'),
          onVisibilityChanged: (info) async {
            if (info.visibleFraction > 0.0) {
              controller.getDataFromServer();
              // 页面可见时，延迟检查banner数据并上报（给接口请求一些时间）
              Future.delayed(const Duration(milliseconds: 500), () {
                _reportBannerViewIfNeeded();
              });
            }
          },
          child: BaseView(
            hasAppBar: false,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Obx(() {
                    return Container(
                      height: 120.h,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            userController.isShowSpringStyle.value
                                ? "assets/springFestival/springFestival-6.png"
                                : Assets.homeIconHomeProfileBg,
                          ),
                        ),
                      ),
                    );
                  }),
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16.h, bottom: 32.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserInfoView(),
                          _buildVIPView(),
                          _buildWorkCountsView(),
                          _buildBannerView(),
                          _buildSettingView(),
                        ],
                      ),
                    ),
                  ),
                  Obx(() {
                    return controller.bubblePosition.value != null &&
                            controller.userInfo?.isVip == 1
                        ? Positioned(
                            top: controller.bubblePosition.value!.dy,
                            right: controller.bubblePosition.value!.dx,
                            child: const BubbleView(tips: "有问题找在线客服哦~"),
                          )
                        : Container();
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ///用户信息
  _buildUserInfoView() {
    return Container(
      padding: EdgeInsets.only(left: 12.w, right: 16.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                ByNavigatorUtil.checkLogin(
                  context: context,
                  needDirectLogin: true,
                  nextStepEvent: () {},
                );
              },
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BYImageView.avatar(
                      imageUrl: controller.userInfo?.avatar,
                      width: 50.w,
                      height: 50.h,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: BYText.instance(
                                (controller.userInfo?.isFormal ?? 0) == 0
                                    ? (controller.userInfo?.isVip ?? 0) == 1
                                          ? '游客'
                                          : '点击登录'
                                    : controller.userController.nickName.value,
                                18.sp,
                              ),
                            ),
                            (controller.userInfo?.isFormal ?? 0) == 0 &&
                                    (controller.userInfo?.isVip ?? 0) == 1
                                ? SizedBox(width: 10.w)
                                : Container(),
                            (controller.userInfo?.isFormal ?? 0) == 0 &&
                                    (controller.userInfo?.isVip ?? 0) == 1
                                ? CommonButton(
                                    minSize: 18.h,
                                    padding: EdgeInsets.zero,
                                    borderRadius: BorderRadius.zero,
                                    onPressed: controller.bindPhone,
                                    child: Container(
                                      height: 18.h,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          9.h,
                                        ),
                                        border: Border.all(
                                          width: 1,
                                          color: ByColorUtil.LoginBtnBgColor,
                                        ),
                                      ),
                                      child: BYText.instance(
                                        '绑定手机号',
                                        12.sp,
                                        color: ByColorUtil.LoginBtnBgColor,
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        IntrinsicWidth(
                          child: CommonButton(
                            minSize: 0,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              controller.operateCopy(
                                '${controller.userInfo?.userId ?? ""}',
                              );
                            },
                            spacing: 4.w,
                            suffixDirectional: SuffixDirectional.right,
                            suffixWidget: Image.asset(
                              Assets.commonIconCopy,
                              width: 12.w,
                              height: 12.h,
                            ),
                            child: BYText.instance(
                              'ID: ${controller.userInfo?.userId ?? ""}',
                              color: ByColorUtil.CommonTextColor.withOpacity(
                                0.8,
                              ),
                              12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          CommonButton(
            key: _customerServiceKey,
            padding: EdgeInsets.zero,
            minSize: 36,
            borderRadius: BorderRadius.circular(8),
            color: ByColorUtil.CommonTextColor.withOpacity(0.05),
            child: Image.asset(
              Assets.commonIconCustomerService,
              width: 24.w,
              height: 24.h,
            ),
            onPressed: () async {
              ///一些调试api方法 如果有测试需要可以自测
              // int systemBootTime = await  BdaSignal.systemBootTime();
              // double appInstallTime = await  BdaSignal.appInstallTime();
              // log("===获取手机系统启动时间===  $systemBootTime");
              //  String userAgent = await IosUserAgentUtil.getDefaultUserAgent();
              // log("===userAgent===  ${userAgent}");
              final purchaseProvider = context.read<PurchaseProvider>();
              if (purchaseProvider.preLoginCheck(context) == false) return;
              const wechatUrl = 'weixin://';
              if (await canLaunchUrl(Uri.parse(wechatUrl))) {
                ByNavRouterUtils.jumpWebViewPage(
                  Get.context!,
                  "在线客服",
                  controller.userInfo?.kfUrl ?? "",
                );
              } else {
                EasyLoading.showToast("由于您未安装微信，无法直接跳转客服。");
              }
            },
          ),
          // Padding(
          //   padding: EdgeInsets.only(left: 6.w),
          //   child: CommonButton(
          //     padding: EdgeInsets.zero,
          //     minSize: 36,
          //     borderRadius: BorderRadius.circular(8),
          //     color: ByColorUtil.CommonTextColor.withOpacity(0.05),
          //     child: Image.asset(
          //       Assets.homeIconSetting,
          //       width: 24.w,
          //       height: 24.h,
          //     ),
          //     onPressed: (){
          //       EasyLoading.showToast("点击设置");
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  _buildVIPView() {
    return Container(
      margin: EdgeInsets.only(left: 12.w, top: 12.h, right: 12.w, bottom: 10.h),
      child: ProfileMemberCard(
        subscribeAction: () {
          if (controller.userInfo?.isVip == 1) return;

          ///1、不是VIP 但已登录 2、 不是VIP 未登录且后台配置可支付
          if (controller.userInfo?.isFormal == 1 ||
              (controller.userInfo?.isFormal == 0 &&
                  controller
                          .launchProvider
                          .launchInfo
                          ?.verConfig
                          .allowTouristsVip ==
                      1)) {
            Get.context!.read<LaunchProvider>().gotoPay(Get.context!);
          } else {
            ByNavigatorUtil.checkLogin(
              context: Get.context!,
              needDirectLogin: true,
              nextStepEvent: () {},
            );
          }
        },
        userInfo: controller.userInfo,
      ),
    );
  }

  ///作品信息
  _buildWorkCountsView() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage(Assets.mineIconMineWorksBg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Image.asset(
                  Assets.mineIconMineWorksTips,
                  width: 18.w,
                  height: 18.w,
                ),
                SizedBox(width: 4.w),
                BYText.instance(
                  "作品管理",
                  14.sp,
                  fontWeight: BYFontWeight.semiBold,
                ),
              ],
            ),
          ),
          Obx(() {
            return controller.userWorksList.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(top: 10.h),
                    child: Row(
                      children: controller.userWorksList.map((worksData) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: CommonButton(
                            padding: EdgeInsets.zero,
                            spacing: 6.h,
                            minSize: 0,
                            suffixDirectional: SuffixDirectional.top,
                            suffixWidget: Row(
                              children: [
                                BYText.instance(
                                  '${worksData.value ?? 0}',
                                  16.sp,
                                  color: ByColorUtil.CommonTextColor,
                                  fontWeight: BYFontWeight.semiBold,
                                ),
                                SizedBox(width: 2.5.w),
                                BYText.instance(
                                  '个',
                                  10.sp,
                                  color: ByColorUtil
                                      .CommonTextColor.withOpacity(0.8),
                                ),
                              ],
                            ),
                            onPressed: () {
                              ///针对华为用户是否需要绑定手机号码
                              ByNavigatorUtil.checkLogin(
                                context: context,
                                needDirectLogin: true,
                                nextStepEvent: () {
                                  if (worksData.jumpUrl != null &&
                                      worksData.jumpUrl?.isNotEmpty == true) {
                                    RouteUtils.gotoPage(
                                      context,
                                      '/${worksData.jumpUrl ?? ''}',
                                      params: worksData.jumpParam ?? {},
                                    );
                                  }
                                },
                              );
                            },
                            child: BYText.instance(
                              worksData.name ?? '',
                              12,
                              color: ByColorUtil.color121634.withOpacity(0.5),
                              height: 1.0,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : Container();
          }),
        ],
      ),
    );
  }

  ///相关设置
  _buildSettingView() {
    return radiusView(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      margin: EdgeInsets.only(left: 12.w, top: 10.h, right: 12.w),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == 0) {
            return buildTextFormView(
              '微信登录',
              CustomTextFieldType.choose,
              onTap: () {
                controller.checkWechatLogin();
              },
            );
          } else if (index == controller.settingConfis.length + 1) {
            return buildTextFormView(
              '个人信息',
              CustomTextFieldType.choose,
              onTap: () {
                Get.toNamed(Routes.userProfile);
              },
            );
          } else if (index == controller.settingConfis.length + 2) {
            return buildTextFormView(
              '未成年人模式',
              CustomTextFieldType.choose,
              onTap: () {
                MinorModeController.to.openMinorModeFromProfile();
              },
            );
          } else if (index == controller.settingConfis.length + 3) {
            return Obx(() {
              return buildTextFormView(
                '版本信息',
                CustomTextFieldType.edit,
                subTitle: '版本号：${controller.versionName.value}',
                enable: false,
                titleStyle: BYTextStyle.instance(
                  14.sp,
                  color: ByColorUtil.CommonTextColor,
                ),
                subTitleStyle: BYTextStyle.instance(
                  14.sp,
                  color: ByColorUtil.CommonTextColor.withOpacity(0.5),
                ),
              );
            });
          } else {
            var settingItemBean = controller.settingConfis[index - 1];
            return buildTextFormView(
              settingItemBean.title,
              settingItemBean.interactive
                  ? CustomTextFieldType.choose
                  : CustomTextFieldType.edit,
              subTitle: settingItemBean.desc,
              enable:
                  (settingItemBean.isAvatar ?? false) ||
                      (settingItemBean.canCopy ?? false)
                  ? false
                  : true,
              suffixWidget: (settingItemBean.isAvatar ?? false)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BYImageView.avatar(
                        imageUrl: null,
                        width: 40.w,
                        height: 40.h,
                      ),
                    )
                  : (settingItemBean.canCopy ?? false)
                  ? Container(
                      margin: EdgeInsets.only(left: 4.w),
                      child: Image.asset(
                        Assets.mineIconCopy,
                        width: 15.w,
                        height: 15.h,
                        fit: BoxFit.contain,
                      ),
                    )
                  : null,
              onTap: () async {
                ///todo 这里看情况是否需要针对ios平台
                if (settingItemBean.canCopy ?? false) {
                  controller.operateCopy(settingItemBean.desc ?? "");
                  return;
                }
                final url = settingItemBean.url;
                if (settingItemBean.interactive && url.isNotEmpty) {
                  if (settingItemBean.title == "联系客服" ||
                      settingItemBean.title == "在线客服") {
                    final purchaseProvider = context.read<PurchaseProvider>();
                    if (purchaseProvider.preLoginCheck(context) == false) {
                      return;
                    }
                    const wechatUrl = 'weixin://';
                    if (await canLaunchUrl(Uri.parse(wechatUrl))) {
                      ByNavRouterUtils.jumpWebViewPage(
                        context,
                        settingItemBean.title,
                        url,
                      );
                      return;
                    } else {
                      EasyLoading.showToast("由于您未安装微信，无法直接跳转客服。");
                    }
                  } else {
                    ByNavRouterUtils.jumpWebViewPage(
                      context,
                      settingItemBean.title,
                      url,
                    );
                    return;
                  }
                }
              },
            );
          }
        },
        itemCount: controller.settingConfis.length + 4,
      ),
    );
  }

  ///banner数据 由后台配置
  _buildBannerView() {
    return GetBuilder<HomeMineController>(
      builder: (controller) {
        List<SubFunction>? menuItemBeans = controller.menuItemBeans;
        if (menuItemBeans != null) {
          if (menuItemBeans.isNotEmpty && controller.isShowBanner) {
            return Stack(
              children: [
                CommonButton(
                  minSize: 0,
                  padding: EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                    bottom: 0.h,
                    top: 8.w,
                  ),
                  borderRadius: BorderRadius.zero,
                  onPressed: () {
                    ByNavigatorUtil.reportDataPoint(
                      pageTag: "banner_click",
                      operateType: "click",
                      funcDetailTag: menuItemBeans.first.id.toString(),
                      funcDetailImg: menuItemBeans.first.imgUrl,
                      extra: {"position": "mine"},
                    );
                    ByCommonUtils.subFunctionCase(context, menuItemBeans.first);
                  },
                  child: BYImageView.normal(
                    imageUrl: controller.menuItemBeans!.first.imgUrl,
                    width: double.infinity,
                    fit: BoxFit.fill,
                    height: 80.h,
                  ),
                ),
                Positioned(
                  right: 0.w,
                  top: -5.w,
                  child: GestureDetector(
                    onTap: () {
                      controller.closeBannerEvent();
                    },
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/ai/aiVideo/new_ai_video_close_icon.png",
                        width: 15.w,
                        height: 15.w,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}
