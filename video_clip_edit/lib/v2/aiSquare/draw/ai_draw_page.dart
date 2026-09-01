import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/guid/providers/guide_pop_providers.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/ai_draw_square_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_prohibited_words_dailog.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_input_view.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/ai_draw_management_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_same_case_view.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_draw_styles_view.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_draw_rations_view.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_work_management_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';

import '../../../widgets/common/right_navigation_bar.dart';

class AiDrawPage extends StatefulWidget {
  const AiDrawPage({super.key});

  @override
  State<AiDrawPage> createState() => _AiDrawPageState();
}

class _AiDrawPageState extends State<AiDrawPage> {
  final integralVipController = IntegralVipController.getOrPut();

  @override
  void initState() {
    super.initState();
    // chekVip();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildPage(context),
          _buildCreateBtn(context),
          _buildAppBar(context),
        ],
      ),
    );
  }

  bool chekVip() {
    final isVip = context.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    return isVip == 1;
    // if (isVip != 1) {
    //   context.read<PurchaseProvider>().loadVIPItems(
    //     onSuccess: () {
    //       showDialog(
    //         context: context,
    //         builder: (context) {
    //           return const DailogBonusLowestPrice();
    //         },
    //       );
    //     },
    //   );
    // }
  }

  /// ********************************* UI *********************************

  Positioned _buildAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: ByScreenUtils.navigationBarHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage("assets/ai/ai_app_bar_bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent, // AppBar 背景透明
          elevation: 0,
          leading: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ByNavRouterUtils.goBack(context);
            },
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/home/icon_back.png",
                width: 16,
                height: 16,
              ),
            ),
          ),
          title: Image.asset(
            "assets/ai/ai_draw_app_bar_title.png",
            height: 19,
            fit: BoxFit.fitHeight,
          ),
          centerTitle: true,
          actions: const [
            Center(
              child: RightNavigationBar(entranceType: GuideEntranceType.aiDraw),
              // child: GestureDetector(
              //   behavior: HitTestBehavior.opaque,
              //   onTap: () {
              //     ByNavRouterUtils.push(
              //       context,
              //       ChangeNotifierProvider(
              //         create: (context) => AiDrawWorkManagementProvider(),
              //         child: const AiDrawManagementPage(),
              //       ),
              //     );
              //   },
              //   child: Container(
              //     alignment: Alignment.center,
              //     padding: const EdgeInsets.only(right: 12.0),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: [
              //         Image.asset(
              //           "assets/ai/ai_draw_records.png",
              //           width: 12,
              //           height: 12,
              //         ),
              //         const SizedBox(width: 5),
              //         ByWidgetsUtil.commonText(
              //           text: "生成记录",
              //           fontSize: 12,
              //           fontWeight: FontWeight.normal,
              //           textColor: const Color(0xFF0E1840).withOpacity(0.8),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            )
          ],
        ),
      ),
    );
  }

  _buildPage(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: ByScreenUtils.navigationBarHeight),
        ),
        _buildBanner(context),

        /// 画面描述
        ..._buildDescGroup(),

        /// 同款
        ..._buildSameCaseGroup(context),

        /// 画面比例
        ..._buildRatioGroup(),

        /// 画面风格
        ..._buildStyleGroup(),

        /// 底部留白
        SliverToBoxAdapter(
          child: SizedBox(height: ByScreenUtils.bottomSafeHeight + 55.h),
        ),
      ],
    );
  }

  /// 画面描述
  _buildDescGroup() {
    return [
      SliverPadding(
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          top: 6.h,
          bottom: 7.h,
        ),
        sliver: SliverToBoxAdapter(
          child: _buildSectionHeader(
              desc: "画面描述", imgPath: "assets/ai/ai_draw_icon_desc.png"),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          bottom: 12.h,
        ),
        sliver: SliverToBoxAdapter(
          child: SizedBox(
              height: 150.h,
              child: const AiInputView(
                padding: EdgeInsets.zero,
              )),
        ),
      )
    ];
  }

  /// 同款
  _buildSameCaseGroup(BuildContext context) {
    return [
      SliverPadding(
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          bottom: 8.h,
        ),
        sliver: SliverToBoxAdapter(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ByNavRouterUtils.push(
                  context,
                  ChangeNotifierProvider.value(
                    value: context.read<AiDrawProvider>(),
                    child: const AiDrawSquarePage(),
                  ));
            },
            child: Row(
              children: [
                Image.asset(
                  "assets/mine/icon_info.png",
                  width: 12.w,
                  height: 12.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 5.w),
                ByWidgetsUtil.commonText(
                  text: "不知道如何输入？可以去绘图广场找同款！",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: const Color(0xFF5A4BF7),
                ),
                const Spacer(),
                Container(
                  width: 30.w,
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    "assets/ai/ai_draw_more.png",
                    width: 12.w,
                    height: 12.h,
                    fit: BoxFit.contain,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      const AiSameCaseView()
    ];
  }

  /// 画面比例
  _buildRatioGroup() {
    return [
      SliverPadding(
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          bottom: 7.h,
        ),
        sliver: SliverToBoxAdapter(
          child: _buildSectionHeader(
              desc: "画面比例", imgPath: "assets/ai/ai_draw_icon_ratio.png"),
        ),
      ),
      const AiDrawRationsView()
    ];
  }

  /// 画面风格
  _buildStyleGroup() {
    return [
      SliverPadding(
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          // top: 13.h,
          bottom: 7.h,
        ),
        sliver: SliverToBoxAdapter(
          child: _buildSectionHeader(
              desc: "画面风格", imgPath: "assets/ai/ai_draw_icon_style.png"),
        ),
      ),
      // const AiDrawStylesCateoryView(),
      const AiDrawStylesView()
    ];
  }

  /// 组标题
  _buildSectionHeader({
    required String imgPath,
    required String desc,
  }) {
    return Row(
      children: [
        Image.asset(
          imgPath,
          width: 15.w,
          height: 15.h,
          fit: BoxFit.contain,
        ),
        SizedBox(width: 5.w),
        ByWidgetsUtil.commonText(
          text: desc,
          textColor: const Color(0xFF0E1840),
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        )
      ],
    );
  }

  _buildCreateBtn(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: PhysicalModel(
        color: const Color(0xFF000000).withOpacity(0.5),
        elevation: 1,
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            top: 8.h,
            bottom: 8.h + ByScreenUtils.bottomSafeHeight,
            left: 12.w,
            right: 12.w,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIntegralVipView(),
              Row(
                children: [
                  if (chekVip())
                    SizedBox(
                      height: 50.h,
                      child: ByWidgetsUtil.commonBtn(
                        title: "创作记录",
                        fontSize: 16.sp,
                        borderRadius: 12.w,
                        fontWeight: FontWeight.normal,
                        bgColor: const Color(0xFFEAEEFF),
                        textColor: ByColorUtil.TabTextColorSelected,
                        padding: EdgeInsets.symmetric(horizontal: 13.w),
                        onClick: () {
                          ByNavRouterUtils.push(
                            context,
                            ChangeNotifierProvider(
                              create: (context) =>
                                  AiDrawWorkManagementProvider(),
                              child: const AiDrawManagementPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  if (chekVip()) SizedBox(width: 10.w),
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            final provider = context.read<AiDrawProvider>();
                            final purchaseProvider =
                                context.read<PurchaseProvider>();

                            if (!provider.checkParams()) {
                              return;
                            }
                            if (purchaseProvider.preLoginCheck(context) ==
                                false) {
                              return;
                            }
                            final integralVipController =
                                IntegralVipController.getOrPut();

                            ///不是会员并且无试用-付费弹窗
                            if (!chekVip() &&
                                integralVipController.isTest <= 0) {
                              final provider = context.read<AiSquareProvider>();
                              String mark = 'ai_draw';
                              provider.showModelPayDialog(context, mark);
                              return;
                            }

                            // 检查积分是否足够-积分购买
                            if (!integralVipController.canContinueUse()) {
                              integralVipController.showIntegralPayDialog();
                              return;
                            }

                            provider.detect(
                              context,
                              provider.desc,
                              onSuccess: () {
                                byDebugPrint(provider.bandedWords,
                                    tag: "违禁词洁厕结果:");
                                if (provider.bandedWords.isNotEmpty) {
                                  BotToast.showText(text: "当前存在违禁词");
                                  showDialog(
                                    context: context,
                                    useSafeArea: false,
                                    barrierDismissible: true,
                                    builder: (ctx) =>
                                        ChangeNotifierProvider.value(
                                      value: provider,
                                      child:
                                          const AiCartoonProhibitedWordsDailog<
                                              AiDrawProvider>(),
                                    ),
                                  );
                                } else {
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    provider.startCreate(
                                      onSuccess: (taskID) {
                                        integralVipController.init(
                                          requiredPoints: 0,
                                          type: "ai_qiumi_paint",
                                        );
                                        ByNavRouterUtils.push(
                                          context,
                                          ChangeNotifierProvider(
                                            create: (context) =>
                                                AiDrawWorkManagementProvider(),
                                            child: const AiDrawManagementPage(),
                                          ),
                                        );
                                      },
                                      onFailed: () {
                                        BotToast.showText(text: "创作失败，请稍后再试");
                                      },
                                    );
                                  });
                                }
                              },
                            );
                          },
                          child: SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ByWidgetsUtil.commonContainer(
                              borerRadius: 12.w,
                              alignment: Alignment.center,
                              bgColor: ByColorUtil.LoginBtnBgColor,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ByWidgetsUtil.commonText(
                                    text: "立即创作",
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    textColor: ByColorUtil.WhiteColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //暂时屏蔽
                  // Positioned(
                  //   right: -2.w,
                  //   top: -12.h,
                  //   child: Offstage(
                  //     offstage: true,
                  //     child: ByWidgetsUtil.gradientBgContainer(
                  //       borderRadius: 20.w,
                  //       padding: EdgeInsets.symmetric(
                  //           horizontal: 11.w, vertical: 5.h),
                  //       child: ByWidgetsUtil.commonText(
                  //         text:
                  //             "限免x${context.select<AiDrawProvider, int>((value) => value.trialForFree)}",
                  //         fontSize: 12.sp,
                  //         fontWeight: FontWeight.bold,
                  //         textColor: ByColorUtil.BlackColor,
                  //       ),
                  //       gradient: const LinearGradient(
                  //         begin: Alignment.topLeft,
                  //         end: Alignment.bottomRight,
                  //         colors: [
                  //           Color(0xFF05FFA4),
                  //           Color(0xFF63FFCA),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 积分-vip-次数-消耗模块-ai绘图
  Widget _buildIntegralVipView() {
    return const IntegralVipView(
      requiredPoints: 0,
      type: "ai_qiumi_paint", // 通过这个type请求权益接口获取实际积分
    );
  }

  _buildBanner(BuildContext context) {
    final bannerBeans = context.select<AiDrawProvider, List<SubFunction>>(
      (value) => value.bannerBeans,
    );
    final showBanner = context.select<AiDrawProvider, bool>(
      (value) => value.showBanner,
    );
    final showBanners = bannerBeans.isNotEmpty && showBanner;
    if (showBanners) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        sliver: SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: double.infinity,
                height: 40.h,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.w),
                  child: BannerView(
                    onError: () {
                      context.read<AiDrawProvider>().updateShowBanner(false);
                    },
                    urls: bannerBeans.map((e) => e.imgUrl).toList(),
                    fit: BoxFit.cover,
                    onTap: (index) {
                      ByCommonUtils.subFunctionCase(
                          context, bannerBeans[index]);
                    },
                  ),
                ),
              ),
              Positioned(
                right: 5.w,
                top: 5.h,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    context.read<AiDrawProvider>().updateShowBanner(false);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: ByColorUtil.BlackColor.withOpacity(0.1),
                          blurRadius: 4.w,
                        )
                      ],
                    ),
                    child: Image.asset(
                      "assets/ai/ai_cartoon_config_close1.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SliverToBoxAdapter(child: Container());
  }

  /// ********************************* UI *********************************
}
