import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/guid/providers/guide_pop_providers.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/business/widget/guide_last_step_view.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/new_short_play_list_controller.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';
import '../../modules/home/beans/cloud_video_bean.dart';
import '../../modules/home/providers/by_audio_player.dart';
import '../../providers/launch_provider.dart';
import '../../utils/comon/by_colors.dart';
import '../../utils/comon/by_nav_router_utils.dart';
import '../../utils/comon/by_screen_utils.dart';
import '../../utils/comon/by_widgets_util.dart';
import '../../widgets/common/right_navigation_bar.dart';
import '../aiClip/provider/ai_clip_bgm_provider.dart';
import '../aiClip/provider/ai_clip_provider.dart';
import '../aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';
import '../aiSquare/cartoon/widgets/ai_cartoon_bgm_dialog.dart';
import '../aiSquare/cartoon/widgets/ai_cartoon_more_settings_dialog.dart';
import '../aiSquare/cartoon/widgets/ai_cartoon_video_fonts_dialog.dart';
import '../aiSquare/cartoon/widgets/ai_cartoon_video_voice_dialog.dart';

///新的短剧展示页面
class NewShortPlayListPage extends StatefulWidget {
  const NewShortPlayListPage({super.key});

  @override
  State<NewShortPlayListPage> createState() => _NewShortPlayListPageState();
}

class _NewShortPlayListPageState extends State<NewShortPlayListPage> {
  final NewShortPlayListController controller =
      Get.put(NewShortPlayListController());
  bool _showScaleWidget = false; // 控制定位图片的显示
  bool _showShortDramaGuideHeader = false; // 控制短剧引导页头部的显示
  bool _showGif = true; // 控制烟花GIF的显示
  Timer? _guideHeaderTimer; // 引导页头部定时器
  Timer? _gifTimer; // 烟花GIF定时器

  ///appbar 部分
  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: ByScreenUtils.navigationBarHeight,
      decoration: const BoxDecoration(
        // color: Colors.red,
        image: DecorationImage(
          image: AssetImage("assets/ai/ai_app_bar_bg.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        bottom: ByWidgetsUtil.appBarBottom(),
        bottomOpacity: 0,
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
          text: "短剧创作",
          textColor: ByColorUtil.CommonTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
        actions: [
          Center(
            child: Container(
              height: 30.h,
              margin: EdgeInsets.only(right: 12.w),
              child: const Center(
                child: RightNavigationBar(
                  entranceType: GuideEntranceType.shortPlayCreate,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  ///header 部分
  Widget _buildHeaderView() {
    return GetBuilder<NewShortPlayListController>(builder: (c) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0XFFF6F7FE),
          borderRadius: BorderRadius.circular(16.w),
        ),
        margin: EdgeInsets.all(12.w),
        padding:
            EdgeInsets.only(left: 12.5.w, top: 15.w, right: 10.w, bottom: 14.w),
        child: Column(
          children: [
            controller.type == 1 ? headerType1View() : headerType2View(),
            SizedBox(
              height: 17.5.w,
            ),

            ///查看全部的点击事件
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "选择剧集",
                  style: TextStyle(
                      color: const Color(0XFF0B1843),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  "（可多选）",
                  style: TextStyle(
                      color: const Color(0XFF0B1843).withOpacity(0.5),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),

                ///重新选择的点击事件
                GestureDetector(
                  onTap: () {
                    ByNavigatorUtil.checkLogin(
                        context: context,
                        nextStepEvent: () {
                          controller.newClickSelectShortPlayEvent();
                        });
                  },
                  child: Row(
                    children: [
                      Text(
                        "重新选择",
                        style: TextStyle(
                            color: const Color(0XFF0B1843).withOpacity(0.5),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: 3.w,
                      ),
                      Image.asset(
                        "assets/ai/hot/open_more_play_icon.png",
                        width: 10.w,
                        height: 10.w,
                      )
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(
              height: 9.w,
            ),

            ///选择剧情的详细列表
            SizedBox(
              height: 104.w,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...controller.selectedVideoDetailBeans.map((e) {
                    bool selected = false;
                    for (var e1 in controller.idsList) {
                      if (e.id == e1) {
                        selected = true;
                      }
                    }
                    return GestureDetector(
                      onTap: () {
                        // controller.changeSelectedShortPlay(id: e.id);
                        ByNavigatorUtil.checkLogin(
                            context: context,
                            nextStepEvent: () {
                              controller.newClickSelectShortPlayEvent();
                            });
                      },
                      child: Container(
                        height: 104.w,
                        width: 82.w,
                        margin: EdgeInsets.only(right: 10.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9.w),
                          image: DecorationImage(
                            image: NetworkImage(e.coverUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        // padding: EdgeInsets.only(top: 5.w, right: 5.w),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 5.w, right: 5.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Image.asset(
                                    selected
                                        ? "assets/ai/hot/selected_icon.png"
                                        : "assets/ai/hot/unselected_icon.png",
                                    width: 20.w,
                                    height: 20.w,
                                  )
                                ],
                              ),
                            ),
                            const Spacer(),
                            Stack(
                              children: [
                                Container(
                                  width: 82.w,
                                  height: 40.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(9.w),
                                      bottomRight: Radius.circular(9.w),
                                    ),
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0XFF000000).withOpacity(0),
                                        const Color(0XFF000000).withOpacity(1),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                Positioned(
                                    bottom: 2,
                                    left: 0.w,
                                    right: 0.w,
                                    child: Center(
                                      child: Text(
                                        "${e.videoTitle}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ))
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  })
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  ///配置部分
  Widget _buildConfigView() {
    return GetBuilder<NewShortPlayListController>(
      builder: (c) {
        int type = controller.selectCommentaryType;
        return Container(
          margin: EdgeInsets.only(left: 12.w, right: 12.w),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0XFFEAEEFF)),
            borderRadius: BorderRadius.circular(12.w),
            color: const Color(0XffF9FAFF),
          ),
          padding: EdgeInsets.only(bottom: 5.w),
          child: Column(
            children: [
              Container(
                width: 1.sw,
                height: 44.w,
                decoration: BoxDecoration(
                  color: const Color(0XffEAEEFF),
                  borderRadius: BorderRadius.circular(
                    12.w,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkResponse(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                        onTap: () {
                          if (type == 1) {
                            return;
                          }
                          controller.changeMode(modeValue: 1);
                        },
                        child: Container(
                          width: 0.5.sw,
                          alignment: Alignment.center,
                          decoration: type == 1
                              ? BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0XFF5A4BF7),
                                    width: 1.5.w,
                                  ),
                                  borderRadius: BorderRadius.circular(12.w),
                                  color: const Color(0XFF5A4BF7))
                              : null,
                          child: Text(
                            "解说脚本",
                            style: TextStyle(
                                color: type == 1
                                    ? Colors.white
                                    : const Color(0XFF0B1843),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkResponse(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                        onTap: () {
                          if (type == 2) {
                            return;
                          }
                          controller.changeMode(modeValue: 2);
                        },
                        child: Container(
                          width: 0.5.sw,
                          alignment: Alignment.center,
                          decoration: type == 2
                              ? BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0XFF5A4BF7),
                                    width: 1.5.w,
                                  ),
                                  borderRadius: BorderRadius.circular(12.w),
                                  color: const Color(0XFF5A4BF7))
                              : null,
                          child: Text(
                            "解说视频配置",
                            style: TextStyle(
                                color: type == 2
                                    ? Colors.white
                                    : const Color(0XFF0B1843),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 6.w,
              ),
              type == 1 ? _commentaryVideoConfigView() : _commentaryScriptView()
            ],
          ),
        );
      },
    );
  }

  ///解说脚本部分
  Widget _commentaryScriptView() {
    List<List<AiCartoonItemBean>> sectionConfigBeans =
        controller.sectionConfigBeans;
    return Padding(
      padding: EdgeInsets.only(left: 12.5.w, right: 9.5.w, top: 20.w),
      child: Column(
        children: [
          ///解说角色
          InkResponse(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            onTap: () {
              // final providerClip = AiClipProvider();
              final providerClip = context.read<AiClipProvider>();
              providerClip.selectedDubbingId = controller.selectedDubbingId;

              ///点击事件
              showDialog(
                useSafeArea: false,
                context: context,
                builder: (ctx) {
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(
                        value: providerClip,
                      ),
                      ChangeNotifierProvider.value(
                        value: ByAudioPlayer.sharedInstance.statusProvider,
                      ),
                    ],
                    child: AiCartoonVideoVoiceDialog<AiClipProvider>(
                      itemBean: sectionConfigBeans[0][0],
                      isNeedData: true,
                      dubbingBeans: controller.dubbingBeans,
                      updateSelectedDubbingId: (id) {
                        Get.log("选中的id===> $id");
                        controller.updateSelectedDubbingId(id);
                      },
                      updateSectionConfigBeansFrom: (itemBean, value) {
                        controller.updateSectionConfigBeansFrom(
                            itemBean, value);
                      },
                      selectedDubbingId: controller.selectedDubbingId,
                    ),
                  );
                },
              );
            },
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "${sectionConfigBeans[0][0].title}:",
                      style: TextStyle(
                          color: const Color(0XFF0B1843),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      sectionConfigBeans[0][0].value ?? "请选择解说角色",
                      style: TextStyle(
                          color: const Color(0XFF0B1843),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      width: 9.w,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2.w),
                      child: Image.asset(
                        "assets/ai/hot/open_more_icon2.png",
                        width: 13.w,
                        height: 13.w,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 13.w,
                ),
                Container(
                  height: 2.w,
                  color: const Color(0XFF81899F).withOpacity(0.04),
                )
              ],
            ),
          ),

          ///背景音乐
          InkResponse(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            onTap: () {
              ///选择背景音乐的点击事件
              Get.log(
                  "====点击背景音乐选择弹窗==== ${sectionConfigBeans[1][0].toJson()}   选中的背景音乐=== ${controller.selectedBgmUrl}");
              final clipProvider = context.read<AiClipProvider>();
              showDialog(
                useSafeArea: false,
                context: context,
                builder: (ctx) {
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: clipProvider),
                      ChangeNotifierProvider(
                        create: (context) => AiClipBgmProvider(
                            bgmUrlInitial: clipProvider.selectedBgmUrl),
                      ),
                      ChangeNotifierProvider.value(
                        value: ByAudioPlayer.sharedInstance.statusProvider,
                      ),
                    ],
                    child:
                        AiCartoonBgmDialog<AiClipProvider, AiClipBgmProvider>(
                      itemBean: sectionConfigBeans[1][0],
                      fromNewShortPlayPage: true,
                      controller: controller,
                    ),
                  );
                },
              );
            },
            child: Column(
              children: [
                SizedBox(
                  height: 16.w,
                ),
                Row(
                  children: [
                    Text(
                      "${sectionConfigBeans[1][0].title}:",
                      style: TextStyle(
                          color: const Color(0XFF0B1843),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      "${sectionConfigBeans[1][0].value}",
                      style: TextStyle(
                          color: const Color(0XFF0B1843),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      width: 9.w,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2.w),
                      child: Image.asset(
                        "assets/ai/hot/open_more_icon2.png",
                        width: 13.w,
                        height: 13.w,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 13.w,
                ),
                Container(
                  height: 2.w,
                  color: const Color(0XFF81899F).withOpacity(0.04),
                )
              ],
            ),
          ),

          ///视频字幕
          InkResponse(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            onTap: () {
              showDialog(
                useSafeArea: false,
                context: context,
                builder: (ctx) {
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(
                          value: context.read<AiClipProvider>()),
                    ],
                    child: AiCartoonVideoFontsDialog<AiClipProvider>(
                      itemBean: sectionConfigBeans[1][1],
                      controller: controller,
                    ),
                  );
                },
              );
            },
            child: Column(
              children: [
                SizedBox(
                  height: 16.w,
                ),
                Row(
                  children: [
                    Text(
                      "${sectionConfigBeans[1][1].title}:",
                      style: TextStyle(
                          color: const Color(0XFF0B1843),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      "${sectionConfigBeans[1][1].value}",
                      style: TextStyle(
                          color: const Color(0XFF0B1843).withOpacity(0.5),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2.w),
                      child: Image.asset(
                        "assets/ai/hot/open_more_icon2.png",
                        width: 13.w,
                        height: 13.w,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 13.w,
                ),
                Container(
                  height: 2.w,
                  color: const Color(0XFF81899F).withOpacity(0.04),
                )
              ],
            ),
          ),

          ///更多设置
          InkResponse(
            onTap: () {
              showDialog(
                useSafeArea: false,
                context: context,
                builder: (ctx) {
                  return ChangeNotifierProvider.value(
                    value: context.read<AiClipProvider>(),
                    child: const AiCartoonMoreSettingsDialog<AiClipProvider>(),
                  );
                },
              );
            },
            child: Column(
              children: [
                SizedBox(
                  height: 16.w,
                ),
                Row(
                  children: [
                    Text(
                      "更多设置：",
                      style: TextStyle(
                          color: const Color(0XFF0B1843),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(top: 2.w),
                      child: Image.asset(
                        "assets/ai/hot/open_more_icon2.png",
                        width: 13.w,
                        height: 13.w,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 13.w,
                ),
                Container(
                  height: 2.w,
                  color: const Color(0XFF81899F).withOpacity(0.04),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///解说视频配置部分
  Widget _commentaryVideoConfigView() {
    ///生成解说失败
    final bool isDescError = controller.isDescError;
    final String desc = controller.desc;
    if (isDescError) {
      return Column(
        children: [
          SizedBox(
            height: 40.w,
          ),
          const Text(
            "解说脚本生成失败",
            style: TextStyle(color: Color(0XFF5A4BF7)),
          ),
          SizedBox(
            height: 300.w,
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          children: [
            SizedBox(
              height: 150.w,
              child: desc.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ByWidgetsUtil.activityIndicator(radius: 13.w),
                          SizedBox(
                            height: 20.w,
                          ),
                          Text(
                            "解说脚本生成中...",
                            style: TextStyle(
                              color: const Color(0XFF5A4BF7),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding:
                          EdgeInsets.only(left: 15.w, right: 15.w, top: 20.w),
                      children: [
                        Text(
                          desc,
                          style: TextStyle(
                            color: const Color(0XFF0B1843),
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
            ),
            if (desc.isNotEmpty)
              SizedBox(
                height: 32.h,
                child: Row(
                  children: [
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: ByWidgetsUtil.btnWithIcon(
                        height: 28.h,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                        ),
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
                          ByNavigatorUtil.reportDataPoint(
                            pageTag: "drama_creation_page_ai_rewrite_btn",
                            operateType: "click",
                            funcDetailTag:
                                controller.cloudVideoListBean?.id.toString() ??
                                    "",
                            funcDetailImg:
                                controller.cloudVideoListBean?.coverUrl ?? "",
                          );
                          ByNavigatorUtil.checkLogin(
                              context: context,
                              nextStepEvent: () {
                                final ids = controller.getSelectedVideoIds();
                                controller.rewriteCommentarySimpleTextByAI(
                                    ids: ids, isClicked: true);
                              });
                        },
                      ),
                    ),
                    SizedBox(width: 5.w),
                  ],
                ),
              ),
          ],
        ),
        if (desc.isEmpty)
          SizedBox(
            height: 50.w,
          ),
      ],
    );
  }

  ///处理下一步按钮点击事件
  void _handleNextStepClick() {
    // 点击下一步按钮时隐藏定位图片
    Get.find<UserController>().showFinger(false);
    Get.find<UserController>().showShortDramaGuide(false);
    ByNavigatorUtil.reportDataPoint(
      pageTag: "drama_creation_page_promote_btn",
      operateType: "click",
      funcDetailTag: controller.cloudVideoListBean?.id.toString() ?? "",
      funcDetailImg: controller.cloudVideoListBean?.coverUrl ?? "",
      extra: {
        "drama_detail_ids": controller.getSelectedVideoIds(),
      },
    );
    ByNavigatorUtil.checkLogin(
        context: context,
        nextStepEvent: () {
          controller.clickNextStepEvent(
              provider: context.read<AiClipProvider>(),
              provider2: context.read<LaunchProvider>(),
              context: context);
        });
  }

  ///一键成片
  Widget _oneNextBtn() {
    bool isShowFinger = Get.find<UserController>().isShowFinger;
    bool isShowShortDramaGuide =
        Get.find<UserController>().isShowShortDramaGuide;
    return GetBuilder<NewShortPlayListController>(builder: (c) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIntegralVipView(),
          SizedBox(
            height: 50.h,
            child: Row(
              children: [
                if (context.read<LaunchProvider>().launchInfo?.isVip == 1)
                  ByWidgetsUtil.commonBtn(
                    title: "创作记录",
                    fontSize: 16.sp,
                    borderRadius: 12.w,
                    fontWeight: FontWeight.normal,
                    bgColor: const Color(0xFFEAEEFF),
                    textColor: ByColorUtil.TabTextColorSelected,
                    // padding: EdgeInsets.symmetric(horizontal: 13.w),
                    onClick: () {
                      controller.clickCreationRecordEvent(context);
                    },
                  ),
                if (context.read<LaunchProvider>().launchInfo?.isVip == 1)
                  SizedBox(width: 10.w),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: _handleNextStepClick,
                        child: DiagonalShimmerWidget(
                          child: Container(
                            height: 50.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B4BF7),
                              borderRadius: BorderRadius.circular(12.w),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isShowShortDramaGuide ? "立即推广" : "下一步",
                              style: TextStyle(
                                fontSize: 19.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 根据 _showScaleWidget 控制定位图片的显示
                      if (isShowFinger || isShowShortDramaGuide)
                        Positioned(
                          right: 80.w,
                          bottom: -12.h,
                          child: GestureDetector(
                            onTap: _handleNextStepClick,
                            child: ScaleTransitionWidget(
                              period: 150,
                              child: Image.asset(
                                "assets/v2/promote/promote-5.png",
                                width: 52.w,
                                height: 52.w,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  // 积分-vip-次数-消耗模块-短剧创作
  Widget _buildIntegralVipView() {
    return const IntegralVipView(
      requiredPoints: 0,
      type: "video_mixed", // 通过这个type请求权益接口获取实际积分
    );
  }

  /// 剧本详情走第二种header 部分
  // Widget _buildHeaderView2() {
  //   return GetBuilder<NewShortPlayListController>(builder: (c) {
  //     if (controller.type == 0) {
  //       return Container(
  //         decoration: BoxDecoration(
  //           color: Color(0XFFF6F7FE),
  //           borderRadius: BorderRadius.circular(16.w),
  //         ),
  //         margin: EdgeInsets.all(12.w),
  //         padding: EdgeInsets.only(
  //             left: 12.5.w, top: 15.w, right: 10.w, bottom: 14.w),
  //         child: Column(
  //           children: [
  //             ///头部展示
  //             Container(
  //               height: 25.h,
  //               decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(10.w),
  //                   image: const DecorationImage(
  //                     image: AssetImage("assets/ai/hot/image_bg1.png"),
  //                     fit: BoxFit.cover,
  //                   )),
  //               child: Column(
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Text(
  //                         "热门短剧",
  //                         style: TextStyle(
  //                             color: Color(0XFF0B1843),
  //                             fontSize: 16.sp,
  //                             fontWeight: FontWeight.w600),
  //                       ),
  //                       const Spacer(),
  //                       GestureDetector(
  //                         onTap: () {
  //                           ///todo
  //                         },
  //                         child: Row(
  //                           children: [
  //                             Image.asset(
  //                               "assets/ai/hot/hot_short_play_icon.png",
  //                               width: 15.w,
  //                               height: 15.w,
  //                             ),
  //                             SizedBox(
  //                               width: 4.5.w,
  //                             ),
  //                             Text(
  //                               "全部",
  //                               style: TextStyle(
  //                                   color: Color(0XFF0B1843),
  //                                   fontSize: 14.sp,
  //                                   fontWeight: FontWeight.w600),
  //                             ),
  //                           ],
  //                         ),
  //                       )
  //                     ],
  //                   )
  //                 ],
  //               ),
  //             ),
  //
  //             ///短剧列表展示
  //             SizedBox(
  //               height: 150.w,
  //               child: ListView(
  //                 scrollDirection: Axis.horizontal,
  //                 children: [
  //                   ...controller.shortPlayBeans.map(
  //                     (e) => GestureDetector(
  //                       onTap: () {
  //                         ///todo 小条目的点击事件
  //                       },
  //                       child: Container(
  //                         height: 143.w,
  //                         width: 110.w,
  //                         margin: EdgeInsets.only(right: 10.w),
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(12.w),
  //                           border: GradientBoxBorder(
  //                             gradient: const LinearGradient(
  //                                 begin: Alignment.topCenter,
  //                                 end: Alignment.bottomCenter,
  //                                 colors: [
  //                                   Color(0XFFFF5DB3),
  //                                   Color(0XFFA984FF),
  //                                 ]),
  //                             width: 2.w,
  //                           ),
  //                         ),
  //                         padding: EdgeInsets.all(5.w),
  //                         child: Container(
  //                           decoration: BoxDecoration(
  //                               borderRadius: BorderRadius.circular(12.w),
  //                               image: DecorationImage(
  //                                 image: NetworkImage(e.coverUrl),
  //                                 fit: BoxFit.cover,
  //                               )),
  //                         ),
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ),
  //
  //             SizedBox(
  //               height: 17.5.w,
  //             ),
  //
  //             ///查看全部的点击事件
  //             Row(
  //               crossAxisAlignment: CrossAxisAlignment.end,
  //               children: [
  //                 Text(
  //                   "选择剧集",
  //                   style: TextStyle(
  //                       color: Color(0XFF0B1843),
  //                       fontSize: 16.sp,
  //                       fontWeight: FontWeight.w600),
  //                 ),
  //                 Text(
  //                   "（可多选）",
  //                   style: TextStyle(
  //                       color: Color(0XFF0B1843).withOpacity(0.5),
  //                       fontSize: 12.sp,
  //                       fontWeight: FontWeight.w500),
  //                 ),
  //
  //                 const Spacer(),
  //
  //                 ///查看全部的点击事件
  //                 GestureDetector(
  //                   onTap: () {
  //                     ///todo 查看全部的点击事件
  //                   },
  //                   child: Row(
  //                     children: [
  //                       Text(
  //                         "查看全部",
  //                         style: TextStyle(
  //                             color: Color(0XFF0B1843).withOpacity(0.5),
  //                             fontSize: 12.sp,
  //                             fontWeight: FontWeight.w500),
  //                       ),
  //                       SizedBox(
  //                         width: 3.w,
  //                       ),
  //                       Image.asset(
  //                         "assets/ai/hot/open_more_play_icon.png",
  //                         width: 10.w,
  //                         height: 10.w,
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //
  //             SizedBox(
  //               height: 9.w,
  //             ),
  //
  //             ///选择剧情的详细列表
  //             SizedBox(
  //               height: 120.w,
  //               child: ListView(
  //                 scrollDirection: Axis.horizontal,
  //                 children: [
  //                   ...controller.selectedVideoDetailBeans.map(
  //                     (e) => Container(
  //                       height: 120.w,
  //                       width: 90.w,
  //                       margin: EdgeInsets.only(right: 10.w),
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(10.w),
  //                         image: DecorationImage(
  //                           image: NetworkImage("${e.coverUrl}"),
  //                           fit: BoxFit.cover,
  //                         ),
  //                       ),
  //                       padding: EdgeInsets.only(top: 5.w, right: 5.w),
  //                       child: Column(
  //                         children: [
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.end,
  //                             children: [
  //                               Image.asset(
  //                                 "assets/ai/hot/unselected_icon.png",
  //                                 width: 20.w,
  //                                 height: 20.w,
  //                               )
  //                             ],
  //                           )
  //                         ],
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             )
  //           ],
  //         ),
  //       );
  //     }
  //
  //     return SizedBox();
  //   });
  // }

  ///字幕样式- 这里沿用以前的
  loadData() {
    final provider = context.read<AiClipProvider>();
    provider.loadVideoFonts();
  }

  ///多种短剧可切换选择
  headerType1View() {
    return Column(
      children: [
        ///头部展示
        Container(
          height: 25.h,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.w),
              image: const DecorationImage(
                image: AssetImage("assets/ai/hot/image_bg1.png"),
                fit: BoxFit.cover,
              )),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "热门短剧",
                    style: TextStyle(
                        color: const Color(0XFF0B1843),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ByNavigatorUtil.checkLogin(
                          context: context,
                          nextStepEvent: () {
                            controller.clickLookAllShortPlayEvent();
                          });
                    },
                    child: Row(
                      children: [
                        // Image.asset(
                        //   "assets/ai/hot/hot_short_play_icon.png",
                        //   width: 15.w,
                        //   height: 15.w,
                        // ),
                        SizedBox(
                          width: 4.5.w,
                        ),
                        Text(
                          "全部",
                          style: TextStyle(
                              color: const Color(0XFF0B1843),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 15.w,
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),

        ///短剧列表展示
        SizedBox(
          height: 150.w,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...controller.shortPlayBeans.map((e) {
                int index = controller.shortPlayBeans.indexOf(e);
                return GestureDetector(
                  onTap: () {
                    ByNavigatorUtil.checkLogin(
                        context: context,
                        nextStepEvent: () {
                          if (index == controller.selectedShortPlayBeansIndex) {
                            return;
                          }
                          controller.selectedNewShortPlayBeans(
                              index: index, id: e.id);
                        });
                  },
                  child: Container(
                    height: 143.w,
                    width: 110.w,
                    margin: EdgeInsets.only(right: 10.w),
                    decoration: index == controller.selectedShortPlayBeansIndex
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(12.w),
                            border: GradientBoxBorder(
                              gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0XFFFF5DB3),
                                    Color(0XFFA984FF),
                                  ]),
                              width: 2.w,
                            ),
                          )
                        : null,
                    padding: EdgeInsets.all(5.w),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.w),
                          image: DecorationImage(
                            image: NetworkImage(e.coverUrl),
                            fit: BoxFit.cover,
                          )),
                    ),
                  ),
                );
              })
            ],
          ),
        ),
      ],
    );
  }

  ///单一短剧
  headerType2View() {
    CloudVideoListBean? cloudVideoListBean = controller.cloudVideoListBean;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ///头部展示
        Stack(
          children: [
            Container(
              height: 25.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.w),
                  image: const DecorationImage(
                    image: AssetImage("assets/ai/hot/image_bg1.png"),
                    fit: BoxFit.cover,
                  )),
            ),
            if (cloudVideoListBean != null)
              Row(
                children: [
                  Container(
                    width: 118.w,
                    height: 150.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.w),
                      image: DecorationImage(
                        image: NetworkImage(cloudVideoListBean.coverUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 12.w,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 180.w,
                        child: Text(
                          cloudVideoListBean.materialName,
                          style: TextStyle(
                            color: const Color(0XFF0B1843),
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 6.w,
                      ),

                      DiagonalShimmerWidget(
                          child: Row(
                        children: [
                          ByWidgetsUtil.commonText(
                            text: "推广进账:",
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            textColor: const Color(0xFF0B1843).withOpacity(0.5),
                          ),
                          SizedBox(width: 4.w),
                          Image.asset(
                            "assets/v2/promote/promote-2.png",
                            width: 20.w,
                            fit: BoxFit.fitWidth,
                          ),
                          SizedBox(width: 3.w),
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) => const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFFF8206),
                                Color(0xFFFFB12F),
                              ],
                            ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                            child: Text(
                              (cloudVideoListBean.otherConfig?.maxIncome ?? 0)
                                  .toString(),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )),
                      SizedBox(height: 2.w),
                      // 参与人数
                      if (cloudVideoListBean.otherConfig?.joinPeopleNum !=
                          null) ...[
                        Row(
                          children: [
                            ByWidgetsUtil.commonText(
                              text: "参与人数: ",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.normal,
                              textColor:
                                  const Color(0xFF0B1843).withOpacity(0.5),
                            ),
                            ByWidgetsUtil.commonText(
                              text:
                                  "${cloudVideoListBean.otherConfig?.joinPeopleNum ?? 0}",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              textColor:
                                  const Color(0xFF0B1843).withOpacity(0.5),
                            ),
                          ],
                        ),
                      ],

                      // Row(
                      //   children: [
                      //     ByWidgetsUtil.commonText(
                      //       text:
                      //           "${cloudVideoListBean.otherConfig?.joinPeopleNum ?? 0}人已推广",
                      //       fontSize: 12.sp,
                      //       fontWeight: FontWeight.normal,
                      //       textColor:
                      //           ByColorUtil.CommonTextColor.withOpacity(0.6),
                      //     ),
                      //     if (!ChannelConfig.exclude_channel_earn.contains(
                      //         BuildConfig.instance.channelType.channel)) ...[
                      //       ByWidgetsUtil.commonText(
                      //         text: "   |   ",
                      //         fontSize: 12.sp,
                      //         fontWeight: FontWeight.normal,
                      //         textColor:
                      //             ByColorUtil.CommonTextColor.withOpacity(0.6),
                      //       ),
                      //       Image.asset(
                      //         "assets/ai/hot/icon_coin.png",
                      //         width: 12.w,
                      //         fit: BoxFit.fitWidth,
                      //       ),
                      //       SizedBox(width: 3.w),
                      //       ByWidgetsUtil.commonText(
                      //         text:
                      //             (cloudVideoListBean.otherConfig?.maxIncome ??
                      //                     0)
                      //                 .toString(),
                      //         fontSize: 12.sp,
                      //         fontWeight: FontWeight.w600,
                      //         textColor: const Color(0xFFFFB452),
                      //       ),
                      //     ],
                      //   ],
                      // ),
                      SizedBox(
                        height: 2.w,
                      ),
                      if (cloudVideoListBean.otherConfig?.fansNum != null) ...[
                        Row(
                          children: [
                            ByWidgetsUtil.commonText(
                              text: "粉丝要求: ",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.normal,
                              textColor:
                                  const Color(0xFF0B1843).withOpacity(0.5),
                            ),
                            ByWidgetsUtil.commonText(
                              text:
                                  "${cloudVideoListBean.fansNum.isNotEmpty ? cloudVideoListBean.fansNum : "0"}",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              textColor:
                                  const Color(0xFF0B1843).withOpacity(0.5),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(
                        height: 10.w,
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 2.w),
                            child: Image.asset(
                              "assets/v2/promote/promote-1.png",
                              width: 10.w,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          SizedBox(
                            width: 180.w,
                            child: Text(
                              "过往收益不代表未来表现，实际收益以推广效果为准",
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.normal,
                                color: const Color(0xFF0B1843).withOpacity(0.4),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      ///快手 抖音信息
                      // Row(
                      //   children: [
                      //     Text(
                      //       "快手粉丝数>=0",
                      //       style: TextStyle(
                      //           color: const Color(0XFFFF3B79),
                      //           fontSize: 12.sp,
                      //           fontWeight: FontWeight.w500),
                      //     ),
                      //   ],
                      // ),

                      // SizedBox(
                      //   height: 15.w,
                      // ),
                      // SizedBox(
                      //     width: 190.w,
                      //     child: Text(
                      //       cloudVideoListBean.desc,
                      //       style: TextStyle(
                      //         color: const Color(0XFF0B1843).withOpacity(0.5),
                      //         fontSize: 12.sp,
                      //         overflow: TextOverflow.ellipsis,
                      //       ),
                      //       maxLines: 3,
                      //     ))
                    ],
                  ),
                ],
              ),

            // Align(alignment: Alignment.bottomCenter,child:   Container(
            //   height: 25.h,
            //   decoration: BoxDecoration(
            //       color: Colors.red,
            //       borderRadius: BorderRadius.circular(10.w),
            //       image: const DecorationImage(
            //         image: AssetImage("assets/ai/hot/image_bg1.png"),
            //         fit: BoxFit.cover,
            //       )),
            // ),)
          ],
        ),

        ///短剧列表展示
        // SizedBox(
        //   height: 150.w,
        //   child: ListView(
        //     scrollDirection: Axis.horizontal,
        //     children: [
        //       ...controller.shortPlayBeans.map((e) {
        //         int index = controller.shortPlayBeans.indexOf(e);
        //         return GestureDetector(
        //           onTap: () {
        //             if (index == controller.selectedShortPlayBeansIndex) {
        //               return;
        //             }
        //             controller.selectedNewShortPlayBeans(
        //                 index: index, id: e.id);
        //           },
        //           child: Container(
        //             height: 143.w,
        //             width: 110.w,
        //             margin: EdgeInsets.only(right: 10.w),
        //             decoration: index == controller.selectedShortPlayBeansIndex
        //                 ? BoxDecoration(
        //                     borderRadius: BorderRadius.circular(12.w),
        //                     border: GradientBoxBorder(
        //                       gradient: const LinearGradient(
        //                           begin: Alignment.topCenter,
        //                           end: Alignment.bottomCenter,
        //                           colors: [
        //                             Color(0XFFFF5DB3),
        //                             Color(0XFFA984FF),
        //                           ]),
        //                       width: 2.w,
        //                     ),
        //                   )
        //                 : null,
        //             padding: EdgeInsets.all(5.w),
        //             child: Container(
        //               decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(12.w),
        //                 image: DecorationImage(
        //                   image: NetworkImage(e.coverUrl),
        //                   fit: BoxFit.cover,
        //                 ),
        //               ),
        //             ),
        //           ),
        //         );
        //       })
        //     ],
        //   ),
        // ),
      ],
    );
  }

  /// 短剧引导页头部展示
  Widget _buildShortDramaGuideHeaderView() {
    return GetBuilder<NewShortPlayListController>(builder: (c) {
      final maxIncome = c.cloudVideoListBean?.otherConfig?.maxIncome ?? 0;

      return Positioned(
        top: ByScreenUtils.navigationBarHeight,
        left: 0,
        right: 0,
        child: SizedBox(
          width: 1.sw,
          height: 400.w, // 设置足够的高度以显示烟花效果
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 背景图片
              Positioned(
                top: 0,
                left: 15.w,
                child: Image.asset(
                  "assets/v2/promote/promote-21.png",
                  width: 345.w,
                  fit: BoxFit.fitWidth,
                ),
              ),

              // 左侧文字和金额（叠加在图片上）
              Positioned(
                left: 30.w,
                top: 20.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 45.h),
                    // ¥ 符号和金额在同一行
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        // ¥ 符号（带渐变色和描边）
                        _buildGradientStrokedText(
                          text: "¥",
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          strokeColor: Colors.white,
                          strokeWidth: 5,
                        ),
                        SizedBox(width: 4.w),
                        // 金额（整数部分和小数部分分开显示）
                        _buildIncomeText(maxIncome),
                      ],
                    ),
                  ],
                ),
              ),
              // 右上角关闭按钮
              Positioned(
                top: 24.h,
                right: 24.w,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // 关闭引导页头部
                    _guideHeaderTimer?.cancel();
                    _gifTimer?.cancel();
                    setState(() {
                      _showShortDramaGuideHeader = false;
                      _showGif = false;
                    });
                    c.fromShortDramaGuide = false;
                    c.update();
                  },
                  child: Image.asset(
                    "assets/v2/promote/promote-20.png",
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),

              // 烟花GIF效果
              if (_showGif)
                Positioned(
                  top: 0.w,
                  left: -120.w,
                  child: Transform.rotate(
                    angle: 0.7853, // 顺时针旋转45度 (π/4)
                    child: Image.asset(
                      "assets/v2/promote/promote-10.gif",
                      width: 440.w,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              if (_showGif)
                Positioned(
                  top: 0.w,
                  right: -120.w,
                  child: Transform.rotate(
                    angle: -0.7853, // 逆时针旋转45度 (-π/4)
                    child: Image.asset(
                      "assets/v2/promote/promote-10.gif",
                      width: 440.w,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  /// 创建带渐变和描边的文字
  Widget _buildGradientStrokedText({
    required String text,
    required double fontSize,
    required FontWeight fontWeight,
    required Color strokeColor,
    required double strokeWidth,
  }) {
    return Stack(
      children: [
        // 描边层（底层）
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        // 渐变色填充层（上层）
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter, // 270度，从上到下
            colors: [
              Color(0xFFFF0000), // #FF0000
              Color(0xFFFF7434), // #FF7434
            ],
            stops: [0.0, 1.0],
          ).createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: Colors.white, // 这个颜色会被渐变覆盖
            ),
          ),
        ),
      ],
    );
  }

  /// 创建金额文字（整数部分正常大小，小数部分缩小）
  Widget _buildIncomeText(int maxIncome) {
    if (maxIncome <= 0) {
      return _buildGradientStrokedText(
        text: "0.00",
        fontSize: 42.sp,
        fontWeight: FontWeight.w500,
        strokeColor: Colors.white,
        strokeWidth: 5,
      );
    }

    final incomeStr = maxIncome.toStringAsFixed(2);
    final parts = incomeStr.split('.');
    final integerPart = parts[0];
    final decimalPart = '.${parts[1]}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // 整数部分（正常大小）
        _buildGradientStrokedText(
          text: integerPart,
          fontSize: 42.sp,
          fontWeight: FontWeight.w500,
          strokeColor: Colors.white,
          strokeWidth: 5,
        ),
        // 小数部分（缩小）
        _buildGradientStrokedText(
          text: decimalPart,
          fontSize: 30.sp, // 缩小字体
          fontWeight: FontWeight.w500,
          strokeColor: Colors.white,
          strokeWidth: 5,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    loadData();
    // 根据传入的参数判断是否显示定位图片
    dynamic arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      if (arguments["showScaleWidget"] != null) {
        if (arguments["showScaleWidget"] is bool) {
          _showScaleWidget = arguments["showScaleWidget"];
        }
      }
    }

    // 如果是从短剧引导页进入，延迟1秒显示头部，3秒后自动关闭
    if (controller.fromShortDramaGuide) {
      _guideHeaderTimer = Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            ByNavigatorUtil.reportDataPoint(
              pageTag: "promotion_page_0fans_income_top_dialog",
              operateType: "view",
              funcDetailTag: "0",
              funcDetailImg: "",
            );
            _showShortDramaGuideHeader = true;
            _showGif = true;
          });
          // 1.5秒后隐藏烟花GIF
          _gifTimer = Timer(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() {
                _showGif = false;
              });
            }
          });
          // 显示3秒后自动关闭
          _guideHeaderTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showShortDramaGuideHeader = false;
                _showGif = false;
                controller.fromShortDramaGuide = false;
                controller.update();
              });
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _guideHeaderTimer?.cancel();
    _gifTimer?.cancel();
    // 页面退出时，确保更新 isShowShortDramaGuide 状态为 false
    if (Get.find<UserController>().isShowShortDramaGuide) {
      Get.find<UserController>().showShortDramaGuide(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: 1.sw,
            height: 1.sh,
          ),
          // AppBar 放在最上层，确保可见
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildAppBar(context),
          ),
          Positioned.fill(
            top: ByScreenUtils.navigationBarHeight - 12.w,
            child: SizedBox(
              height: 1.sh - 100.w,
              child: ListView(
                padding: EdgeInsets.only(bottom: 160.w),
                children: [
                  _buildHeaderView(),
                  _buildConfigView(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10.0,
                        offset: const Offset(6.0, 0.0),
                        spreadRadius: 0)
                  ]),
              padding: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                  top: 12.w,
                  bottom: ByScreenUtils.bottomSafeHeight + 8.w),
              child: _oneNextBtn(),
            ),
          ),
          if (controller.fromShortDramaGuide && _showShortDramaGuideHeader) ...[
            _buildShortDramaGuideHeaderView(),
          ],
        ],
      ),
    );
  }
}
