import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/modules/guid/providers/guide_pop_providers.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/modules/home/story/assistant/ai_rewrite_page.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/creator_bean.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/widgets/ai_commentary_rewrite_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/ai_vip_guid_page.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiClip/widgets/ai_clip_item_view.dart';
import 'package:video_clip_edit/v2/aiClip/widgets/ai_clip_input_view.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:video_clip_edit/v2/aiSquare/providers/ai_vip_guid_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/guide_page.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_opening_provider.dart';
import 'package:video_clip_edit/v2/aiClip/widgets/ai_clip_material_select_view.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/rotate_animation_view.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_video_management_page.dart';
import 'package:video_clip_edit/v2/aiClip/widgets/ai_clip_material_opening_select_view.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_prohibited_words_dailog.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_video_management_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';
import 'package:video_clip_edit/widgets/common/right_navigation_bar.dart';

import '../../utils/consts/const.dart';
import '../../utils/http/apis.dart';
import '../../utils/http/http_utils.dart';

///混剪
class AiClipPage extends StatefulWidget {
  const AiClipPage({
    super.key,
    this.title,
    this.fromPrompt = false,
    this.loadCommentary = false,
    this.ratioChangeable = true,
    this.source = EntranceSource.normal,
    this.fromChat = false,
    this.pagePath = "",
  });

  /// 是否来自：推广 - 短剧创作
  /// 如果是会隐藏很多参数选项
  final bool fromPrompt;
  final bool loadCommentary;
  final String? title;
  final bool? ratioChangeable;
  final bool fromChat;

  ///来源 普通、短剧、爆文
  final EntranceSource source;

  final String pagePath;

  @override
  State<AiClipPage> createState() => _AiClipPageState();
}

class _AiClipPageState extends State<AiClipPage> {
  @override
  void initState() {
    super.initState();

    _loadData();
    actionClickReport();
  }

  @override
  void dispose() {
    // 在这里处理页面离开时的清理工作
    if (widget.fromChat) {
      final integralVipController = IntegralVipController.getOrPut();
      integralVipController.init(
        requiredPoints: 0,
        type: "txt_knows",
      );
    }
    super.dispose();
  }

  /// **************************************** logic ****************************************
  _loadData() {
    final provider = context.read<AiClipProvider>();
    final commentaryDesc = provider.commentaryDesc;
    if (widget.loadCommentary && commentaryDesc.isNotEmpty) {
      _generateCommentay(provider, commentaryDesc);
    }

    /// 视频比例
    provider.loadVideoRatios();

    /// 字幕样式
    provider.loadVideoFonts();

    /// 角色配音
    provider.loadDubbingList();

    if (widget.fromPrompt == false) {
      provider.loadRandomCase();
    }

    provider.loadBanners(postion: 5);
    // chekVip();

    getFirstAiWriteResult();
  }

  void _generateCommentay(AiClipProvider provider, String commentaryDesc) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.updateGeneratingCommentary(true);
      provider.getCommentarySimpleText(
        text: commentaryDesc,
        onSuccess: (taskId) {
          if (taskId.isEmpty) {
            provider.updateGeneratingCommentary(false);
            BotToast.showText(text: "生成解说文案失败，请稍后再试");
            return;
          }

          /// 轮询查询生成结果
          provider.queryVoiceStyleOptimizeState(
            taskId: taskId,
            onSuccess: (result) {
              if (result.isNotEmpty) {
                /// 转换解说文案
                provider.updateGeneratingCommentary(false);
                provider.updateDesc(result);
              }
            },
          );
        },
        onFailed: () {
          provider.updateGeneratingCommentary(false);
          BotToast.showText(text: "生成解说文案失败，请稍后再试");
        },
      );
    });
  }

  /// **************************************** logic ****************************************

  /// **************************************** UI ****************************************

  getFirstAiWriteResult() async {
    if (widget.source == EntranceSource.shortPlay) {
      final provider = context.read<AiClipProvider>();
      final providerMaterial = context.read<AiMaterialProvider>();
      final ids =
          providerMaterial.selectedShowListBeans.map((e) => e.id).join(",");
      provider.firstGetAi(ids: ids);
    }
  }

  ///爆文创作 功能点击上报
  actionClickReport(){
    if (widget.source == EntranceSource.explosive) {
      HttpUtils.post(APIs.apiPost, {
        "event": Consts.EVENT_PAID_PAGE,
        "event_function":
        Consts.FUNCTION_EXPLOSIVE_WRITING,
        "event_action":
        Consts.ACTION_FUNCTION_CLICK_REPORT,
        "page_path": widget.pagePath,
        "pre_page_path": "/novel_create",
        "payment_page_tag":"",
        "middle_page_tag":"",
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    byDebugPrint("_AiClipPageState: build");
    return Scaffold(
        body: SafeArea(
      top: false,
      child: Stack(
        children: [
          _buildBody(context),
          _buildAppBar(context),
          _buildBottomBar(context),
        ],
      ),
    ));
  }

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
          backgroundColor: Colors.transparent,
          bottom: ByWidgetsUtil.appBarBottom(),
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
          title: ByWidgetsUtil.commonText(
            text: widget.title ?? "混剪推文",
            textColor: ByColorUtil.CommonTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          centerTitle: true,
          actions: const [
            Center(
                //工具箱--->混剪推文 ====> 智能混剪 ai_clip /短剧创作====> short_play_create_djcz
                // child: RightNavigationBar(entranceType: 4)
                child:
                    RightNavigationBar(entranceType: GuideEntranceType.aiClip))
          ],
        ),
      ),
    );
  }

  _buildBody(BuildContext context) {
    var configBeans =
        context.select<AiClipProvider, List<List<AiCartoonItemBean>>>(
      (p) => p.sectionConfigBeans,
    );
    if (widget.fromPrompt) {
      // configBeans = configBeans.map((section) {
      //   return section
      //       .where((ele) => ele.type != AiCartoonItemBeanType.ratio)
      //       .toList();
      // }).toList();
      for (var section in configBeans) {
        for (var element in section) {
          if (element.type == AiCartoonItemBeanType.ratio) {
            element.interactive = widget.ratioChangeable;
          }
        }
      }
    }
    return Column(
      children: [
        Container(
          height: ByScreenUtils.navigationBarHeight,
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: CustomScrollView(
            slivers: [
              _buildBanner(context),
              _buildKeywordsHeader(),
              _buildKeywordsInputArea(context),
              if (!(widget.fromPrompt == true &&
                  widget.source == EntranceSource.shortPlay))
                _buildClipMaterials(),
              // _buildClipMaterialsOpening(),
              ..._buildConfigSections(configBeans),
              SliverToBoxAdapter(
                child: SizedBox(height: ByScreenUtils.bottomSafeHeight + 120.h),
              ),
            ],
          ),
        ))
      ],
    );
  }

  _buildBanner(BuildContext context) {
    final bannerBeans = context.select<AiClipProvider, List<SubFunction>>(
      (value) => value.bannerBeans,
    );
    final showBanner = context.select<AiClipProvider, bool>(
      (value) => value.showBanner,
    );
    final showBanners = bannerBeans.isNotEmpty && showBanner;
    if (showBanners) {
      return SliverPadding(
        padding: EdgeInsets.only(top: 10.h, bottom: 0),
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
                      context.read<AiClipProvider>().updateShowBanner(false);
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
                    context.read<AiClipProvider>().updateShowBanner(false);
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

  List<Widget> _buildConfigSections(List<List<AiCartoonItemBean>> configBeans) {
    return configBeans
        .map((beans) {
          return _buildSection(itemBeans: beans);
        })
        .toList()
        .cast();
  }

  SliverPadding _buildKeywordsInputArea(BuildContext context) {
    final desc = context.select<AiClipProvider, String>(
      (value) => value.desc,
    );
    return SliverPadding(
      padding: EdgeInsets.only(top: 11.h),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 240.h,
          child: AiClipInputView(
            canInput: true,
            padding: EdgeInsets.zero,
            toolBarBuilder: widget.fromPrompt
                ? (context) {
                    return SizedBox(
                      height: 24.h,
                      width: ByScreenUtils.screenWidth - 24.h,
                      child: Row(
                        children: [
                          const Spacer(),
                          ByWidgetsUtil.btnWithIcon(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            title: "AI改写",
                            iconPath: "assets/ai/clip/ai_clip_edit.png",
                            textColor: ByColorUtil.LoginBtnBgColor,
                            fontSize: 12.sp,
                            iconH: 12.h,
                            iconW: 12.h,
                            contentGap: 3,
                            borderRadius: 30.h,
                            bgColor: const Color(0xFFEAEEFF),
                            fontWeight: FontWeight.normal,
                            onClick: () async {
                              if (widget.source == EntranceSource.shortPlay) {
                                final providerMaterial =
                                    context.read<AiMaterialProvider>();
                                final ids = providerMaterial
                                    .selectedShowListBeans
                                    .map((e) => e.id)
                                    .join(",");

                                /// 跳转AI改写页面
                                final result = await showDialog(
                                  context: context,
                                  builder: (ctx) =>
                                      ChangeNotifierProvider.value(
                                    value: context.read<AiClipProvider>(),
                                    child: AiCommentaryRewriteDialog(
                                      // provider: providerClip,
                                      commentaryDesc: "",
                                      ids: ids,
                                      aiRewrite: true,
                                    ),
                                  ),
                                );
                                byDebugPrint(result);
                              } else {
                                ByNavRouterUtils.push(
                                  context,
                                  MultiProvider(
                                    providers: [
                                      ChangeNotifierProvider(
                                          create: (_) => StroyCreateProvider()),
                                      ChangeNotifierProvider.value(
                                          value:
                                              context.read<AiClipProvider>()),
                                    ],
                                    child: AiRewritePage<AiClipProvider>(
                                      bean: CreatorBean.fromIdAndTitle(
                                        id: "114",
                                        title: "AI改写",
                                      ),
                                      contents: desc,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(width: 5.w),
                        ],
                      ),
                    );
                  }
                : null,
          ),
        ),
      ),
    );
  }

  _buildKeywordsHeader() {
    if (widget.fromPrompt) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: ByWidgetsUtil.commonTipsBar("内容由Ai生成仅供参考，禁止利用功能从事违法活动。"),
        ),
      );
    }
    return const AiCartoonRandmCaseView();
  }

  /// 组标题
  Widget _buildSectionHeader({
    required String imgPath,
    required String desc,
    bool reqired = false,
  }) {
    return KeyboardDismissOnTap(
      child: Row(
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
          ),
          if (reqired)
            ByWidgetsUtil.commonText(
              text: "*",
              textColor: const Color(0xFFF74B63),
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            )
        ],
      ),
    );
  }

  _buildSection({
    required List<AiCartoonItemBean> itemBeans,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          top: itemBeans.length > 1 ? 20.h : 5.h,
        ),
        child: itemBeans.length > 1
            ? KeyboardDismissOnTap(
                dismissOnCapturedTaps: true,
                child: Row(
                  children: [
                    Expanded(child: _buildSectionItem(itemBeans[0])),
                    SizedBox(width: 10.w),
                    Expanded(child: _buildSectionItem(itemBeans[1])),
                  ],
                ),
              )
            : KeyboardDismissOnTap(
                dismissOnCapturedTaps: true,
                child: Row(
                  children: [
                    Expanded(child: _buildSectionItem(itemBeans[0])),
                  ],
                ),
              ),
      ),
    );
  }

  _buildSectionItem(AiCartoonItemBean itemBean) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (itemBean.hasHeader!)
          _buildSectionHeader(
            imgPath: itemBean.imgPath,
            desc: itemBean.title,
            reqired: itemBean.required ?? true,
          ),
        SizedBox(height: 10.h),
        AiClipItemView(itemBean: itemBean),
      ],
    );
  }

  // 积分-vip-次数-消耗模块-混剪推文
  Widget _buildIntegralVipView() {
    return const IntegralVipView(
      requiredPoints: 0,
      type: "video_mixed", // 通过这个type请求权益接口获取实际积分
    );
  }

  _buildBottomBar(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          bottom: ByScreenUtils.bottomSafeHeight,
        ),
        child: KeyboardDismissOnTap(
          dismissOnCapturedTaps: true,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIntegralVipView(),
                SizedBox(
                  height: 50.h,
                  child: Row(
                    children: [
                      if (chekVip())
                        ByWidgetsUtil.commonBtn(
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
                                MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider(
                                        create: (context) =>
                                            AiCartoonVideoManagementProvider()),
                                  ],
                                  child: AiCartoonVideoManagementPage(
                                    type: AiCartoonVideoManagementPageType.clip,
                                    source: widget.source,
                                  ),
                                ));
                          },
                        ),
                      if (chekVip()) SizedBox(width: 10.w),
                      Expanded(
                        child: ByWidgetsUtil.commonBtn(
                          title: "立即创作",
                          fontSize: 16.sp,
                          borderRadius: 12.w,
                          fontWeight: FontWeight.w500,
                          textColor: ByColorUtil.WhiteColor,
                          bgColor: ByColorUtil.TabTextColorSelected,
                          padding: EdgeInsets.symmetric(horizontal: 13.w),
                          onClick: () {
                            /// 检查违禁词
                            final provider = context.read<AiClipProvider>();
                            final purchaseProvider =
                                context.read<PurchaseProvider>();
                            if (!provider.checkParamas(
                              materialProvider:
                                  context.read<AiMaterialProvider>(),
                            )) {
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
                              String mark = 'ai_clip';
                              final launchProvider = Provider.of<LaunchProvider>(context, listen: false);

                              if (widget.source == EntranceSource.explosive) {
                                HttpUtils.post(APIs.apiPost, {
                                  "event": Consts.EVENT_PAID_PAGE,
                                  "event_function":
                                      Consts.FUNCTION_EXPLOSIVE_WRITING,
                                  "event_action":
                                      Consts.ACTION_OPEN_PAY_PAGE_REPORT,
                                  "page_path": widget.pagePath,
                                  "pre_page_path": "/novel_create",
                                  "payment_page_tag":launchProvider.launchInfo?.verConfig.halfScreenPage,
                                  "middle_page_tag":"",
                                });
                              }

                              provider.showModelPayDialog(
                                context,
                                mark,
                                eventFunction:
                                    Consts.FUNCTION_EXPLOSIVE_WRITING,
                                prePagePath: "/novel_create",
                                pagePath:  widget.pagePath,
                              );
                              return;
                            }

                            /// 检查积分是否足够-积分购买
                            if (!integralVipController.canContinueUse()) {
                              integralVipController.showIntegralPayDialog();
                              return;
                            }
                            provider.detect(
                              context,
                              provider.desc,
                              onSuccess: () {
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
                                              AiClipProvider>(),
                                    ),
                                  );
                                } else {
                                  provider.saveParamsForVideoStep1(
                                    materialProvider:
                                        context.read<AiMaterialProvider>(),
                                    openingProvider:
                                        context.read<AiClipOpeningProvider>(),
                                    onSuccess: () {
                                      integralVipController.init(
                                        requiredPoints: 0,
                                        type: "video_mixed",
                                      );
                                      ByNavRouterUtils.pushReplacement(
                                          context,
                                          MultiProvider(
                                            providers: [
                                              ChangeNotifierProvider(
                                                  create: (context) =>
                                                      AiCartoonVideoManagementProvider()),
                                            ],
                                            child: AiCartoonVideoManagementPage(
                                              type:
                                                  AiCartoonVideoManagementPageType
                                                      .clip,
                                              source: widget.source,
                                            ),
                                          ));
                                    },
                                    onFaild: () {},
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool chekVip() {
    final isVip = context.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    return isVip == 1;
  }

  _buildClipMaterials() {
    return const AiClipMaterialSelectView();
  }

  _buildClipMaterialsOpening() {
    return const AIClipMaterilaOpeningSelectView();
  }

  /// **************************************** UI ****************************************
}

class AiCartoonRandmCaseView extends StatelessWidget {
  const AiCartoonRandmCaseView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final category = context.select<AiClipProvider, String>(
      (value) => value.category,
    );
    final generatingCommentary = context.select<AiClipProvider, bool>(
        (AiClipProvider provider) => provider.generatingCommentary);
    final hasTemplates = category.isNotEmpty;

    return SliverToBoxAdapter(
      child: KeyboardDismissOnTap(
        dismissOnCapturedTaps: true,
        child: Padding(
          padding: EdgeInsets.only(top: 11.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  ByNavigatorUtil.checkLogin(
                      context: context,
                      nextStepEvent: () {
                        context.read<AiClipProvider>().pickRandomCase();
                        if (generatingCommentary) return;
                        FocusScope.of(context).unfocus();
                        if (hasTemplates) {
                          final provider = context.read<AiClipProvider>();
                          final categoryBean = provider.templateBeans
                              .firstWhere((e) => e.category == category);
                          provider.updateDesc(categoryBean.text);
                        }
                      });
                },
                child: ByWidgetsUtil.commonRichText(
                  texts: [
                    const TextSpan(text: "灵感案例："),
                    TextSpan(
                        text: category,
                        style: const TextStyle(
                          color: ByColorUtil.TabTextColorSelected,
                        )),
                  ],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: ByColorUtil.CommonTextColor,
                ),
              ),
              Offstage(
                offstage: !hasTemplates,
                child: RotateAnimationView(
                  onTap: () {
                    ByNavigatorUtil.checkLogin(
                        context: context,
                        nextStepEvent: () {
                          context.read<AiClipProvider>().pickRandomCase();
                        });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/ai/ai_cartoon_icon_random.png",
                      width: 12.w,
                      height: 14.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: Image.asset(
                  "assets/ai/ai_cartoon_icon_auth.png",
                  width: 13.w,
                  height: 13.w,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 4.w),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final provider = context.read<AiClipProvider>();
                  provider.loadTuixiaoguoUrl(onSuccess: (url) {
                    ByNavRouterUtils.jumpWebViewPage(context, "小说授权", url);
                  });
                },
                child: ByWidgetsUtil.commonText(
                  text: "小说授权",
                  textColor: const Color(0xFF5E4AFF),
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
