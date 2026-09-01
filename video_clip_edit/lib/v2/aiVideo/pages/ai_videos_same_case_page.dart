// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_videos_downoad_dialog.dart';
import 'package:video_clip_edit/v2/minorMode/minor_mode_ui.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_video_player.dart';
import 'package:video_clip_edit/v2/aiVideo/models/ai_video_square_model.dart';

import '../../../modules/home/beans/cloud_video_bean.dart';
import '../../../modules/home/providers/stroy_create_provider.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/http/apis.dart';
import '../../../utils/http/http_utils.dart';
import '../../../widgets/toast_util.dart';
import '../../aiClip/ai_clip_page.dart';
import '../../aiClip/provider/ai_clip_mine_materials_provider.dart';
import '../../aiClip/provider/ai_clip_opening_provider.dart';
import '../../aiClip/provider/ai_clip_provider.dart';
import '../../aiClip/provider/ai_material_provider.dart';
import '../../aiSquare/cartoon/ai_cartoon_page.dart';
import '../../aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import '../../anime/beans/anime_bean.dart';
import '../../anime/controllers/anime_controller.dart';
import '../../anime/pages/anime_detail_setting_page.dart';
import '../../integral/integral_vip_controller.dart';

class AiVideosSameCasePage extends StatelessWidget {
  const AiVideosSameCasePage({
    super.key,
    required this.caseBean,
    required this.preview,
    this.jumpUrl,
    this.type,
    this.jumpParam,
    this.isOldEmbrace = false,
    this.prePagePath = "",
  });
  final AiVideoSquareModel caseBean;
  final bool preview;
  final String? jumpUrl;
  final String? type;

  ///立即创作需要跳转的页面
  final String? jumpParam; //跳转视频

  ///是否是老的拥抱视频
  final bool isOldEmbrace;

  ///父级页面参数
  final String prePagePath;

  ///做同款的点击事件
  void _clickDoSameEvent({required BuildContext context}) {
    ByNavigatorUtil.checkLogin(
      context: context,
      nextStepEvent: () {
        eventBus.fire(const StopVideoPlayEvent());
        if (type == "ai_tweets") {
          final provider = AiCartoonProvider();
          provider.desc = caseBean.prompt ?? "";
          ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (context) => provider,
              child: const AiCartoonPage(),
            ),
          );
          return;
        } else if (type == "ai_clip") {
          final providerClip = AiClipProvider();
          providerClip.desc = caseBean.prompt ?? "";
          ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (context) => StroyCreateProvider(),
              child: MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (context) => providerClip),
                  ChangeNotifierProvider(
                    create: (BuildContext context) => AiMaterialProvider(),
                  ),
                  ChangeNotifierProvider(
                    create: (BuildContext context) => AiClipOpeningProvider(),
                  ),
                  ChangeNotifierProvider(
                    create: (BuildContext context) =>
                        AiClipMineMaterialsProvider(),
                  ),
                ],
                child: const AiClipPage(),
              ),
            ),
          );
          return;
        } else if (type == "short_play_create_detail") {
          HttpUtils.get(
            APIs.getMaterialInfo,
            {"id": int.parse(jumpParam!), "detailNum": 1},
            success: (data) {
              final CloudVideoListBean shortPlayBean =
                  CloudVideoListBean.fromJson(data["data"]);
              // ByNavRouterUtils.push(
              //     context,
              //     ChangeNotifierProvider(
              //       create: (BuildContext context) =>
              //           ShortShowDetailsProvider(),
              //       child: ShortPlayListPage(
              //         videoListBean: shortPlayBean,
              //         fromPrompt: true,
              //       ),
              //     ));
              Get.toNamed(
                Routes.newShortPlayListPage,
                arguments: {
                  "fromPrompt": false,
                  "videoListBean": shortPlayBean,
                  "prePagePath": prePagePath,
                },
              );
            },
            fail: (code, msg) {
              // BotToast.showText(text: msg);
              ToastUtil().showToast(msg);
            },
          );
          return;
        } else if (type == "anime") {
          // 漫剧做同款 - 显示底部弹窗设置页
          if (jumpParam != null && jumpParam!.isNotEmpty) {
            final animeData = jsonDecode(jumpParam!);
            final AnimeBean animeBean = AnimeBean.fromJson(json: animeData);

            // 注入必要的 Controllers（如果不存在）
            IntegralVipController.getOrPut();
            if (!Get.isRegistered<AnimeController>()) {
              Get.put(AnimeController());
            }

            showModalBottomSheet(
              context: context,
              builder: (context) {
                return AnimeDetailSettingPage(bean: animeBean);
              },
            );
          }
          return;
        }
        if (isOldEmbrace) {
          ByNavRouterUtils.pushNamed(context, "/ai_embrace_video");
          return;
        }
        Get.toNamed(Routes.aiDynamicVideoPage, arguments: caseBean);
        // ByNavRouterUtils.push(
        //   context,
        //   ChangeNotifierProvider(
        //     create: (context) => AiVideoProvider(),
        //     child: NewAiVideoPage(
        //       initType: caseBean.type,
        //       prompt: caseBean.prompt,
        //       negativePrompt: caseBean.negativePrompt,
        //       images: caseBean.multiImage,
        //       aspectRatio: caseBean.aspectRatio,
        //       cfgScale: caseBean.cfgScale,
        //       mode: caseBean.mode,
        //     ),
        //   ),
        // );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPreview = preview == true;
    log("333=====");
    return Scaffold(
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.only(bottom: 66.h),
              children: [
                SizedBox(
                  // height: 210.h,
                  child: AiVideoPlayer(videoUrl: caseBean.shareVideoUrl),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ByWidgetsUtil.commonText(
                        text: caseBean.prompt ?? "",
                        fontWeight: FontWeight.bold,
                        maxLines: 2,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(
                      height: 32.h,
                      child: MinorModeUi.hideWhenRestricted(
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            eventBus.fire(const StopVideoPlayEvent());
                            LaunchProvider provider = context
                                .read<LaunchProvider>();
                            if (provider.launchInfo?.isVip != 1) {
                              provider.gotoPay(
                                context,
                                closePay: true,
                                replace: false,
                              );
                              return;
                            }
                            if (await ByPermissionUtils.storage() == false)
                              return;
                            showDialog(
                              context: context,
                              builder: (c) {
                                return AiVideosDownoadDialog(
                                  contents: "",
                                  maxLine: 10,
                                  cancelBtnTitle: "取消",
                                  confirmBtnTitle: "确定",
                                  toast: "保存完成",
                                  confirmCallback: () {},
                                  videoUrls: [caseBean.videoUrl],
                                );
                              },
                            );
                          },
                          child: ByWidgetsUtil.commonContainer(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            bgColor: const Color(0xFFEBEEFD),
                            borerRadius: 9.w,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 13,
                                  height: 12,
                                  child: Image.asset(
                                    "assets/ai/ai_same_case_download.png",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                ByWidgetsUtil.commonText(
                                  text: "保存",
                                  textColor: const Color(0xFF584CEE),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                ),
                SizedBox(height: 5.h),
                Offstage(
                  offstage: isPreview,
                  child: Row(
                    children: [
                      SizedBox(width: 12.w),
                      ByWidgetsUtil.commonText(
                        text: "${caseBean.useTime}浏览",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.normal,
                        textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                      ),
                      SizedBox(width: 10.w),
                      ..._buildLabels(),
                      SizedBox(width: 5.w),
                      SizedBox(
                        height: 18.h,
                        child: ByWidgetsUtil.btnWithIcon(
                          borderRadius: 9.h,
                          fontSize: 12.sp,
                          padding: const EdgeInsets.only(left: 4, right: 6),
                          bgColor: const Color(0xFFF64556),
                          title: "HOT",
                          contentGap: 2,
                          iconW: 12,
                          iconH: 12,
                          fontWeight: FontWeight.bold,
                          iconPath: "assets/ai/ai_same_case_hot.png",
                          onClick: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                // 作者模块 - anime 类型时隐藏
                Offstage(
                  offstage: type == "anime",
                  child: Column(
                    children: [
                      Container(
                        height: 0.5,
                        color: const Color(0xFFF3F5F9),
                        width: double.infinity,
                        margin: EdgeInsets.only(
                          left: 12.w,
                          right: 12.w,
                          bottom: 10.h,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          children: [
                            ClipOval(
                              child: caseBean.activeUserAvatar.isEmpty
                                  ? Image.asset(
                                      "assets/mine/mine_avarta.png",
                                      width: 44.w,
                                      height: 44.w,
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: caseBean.activeUserAvatar,
                                      width: 44.w,
                                      height: 44.w,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            SizedBox(width: 10.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ByWidgetsUtil.commonText(
                                  text: caseBean.activeUserName.isEmpty
                                      ? "未知"
                                      : caseBean.activeUserName,
                                  textColor: const Color(0xFF0E1840),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(height: 5.h),
                                ByWidgetsUtil.commonText(
                                  text:
                                      "已入驻平台${caseBean.activeUserCreateDays}天",
                                  textColor: const Color(
                                    0xFF0E1840,
                                  ).withOpacity(0.5),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.normal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 0.5,
                        color: const Color(0xFFF3F5F9),
                        width: double.infinity,
                        margin: EdgeInsets.only(
                          left: 12.w,
                          right: 12.w,
                          bottom: 15.h,
                          top: 10.h,
                        ),
                      ),
                    ],
                  ),
                ),
                // 提示词模块 - anime 类型时隐藏
                Offstage(
                  offstage: type == "anime",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 12.w, bottom: 12.h),
                        child: ByWidgetsUtil.commonText(
                          text: "提示词",
                          textColor: const Color(0xFF0E1840),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 12.w,
                          right: 12.w,
                          bottom: 15.h,
                        ),
                        child: ByWidgetsUtil.commonText(
                          text: caseBean.prompt ?? "",
                          textColor: const Color(0xFF0E1840).withOpacity(0.5),
                          fontSize: 14.sp,
                          maxLines: 100,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Container(
                        height: 44.h,
                        margin: EdgeInsets.symmetric(horizontal: 12.w),
                        child: ByWidgetsUtil.btnWithIcon(
                          borderRadius: 9.h,
                          fontSize: 12.sp,
                          padding: const EdgeInsets.only(left: 4, right: 6),
                          bgColor: const Color(0xFFF8FAFB),
                          title: "复制",
                          textColor: const Color(0xFF0E1840).withOpacity(0.5),
                          contentGap: 5.w,
                          iconW: 12,
                          iconH: 14,
                          fontWeight: FontWeight.bold,
                          iconPath: "assets/ai/ai_same_case_copy.png",
                          onClick: () {
                            Clipboard.setData(
                              ClipboardData(text: caseBean.prompt ?? ""),
                            );
                            BotToast.showText(text: "复制成功");
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            MinorModeUi.hideWhenRestricted(
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: PhysicalModel(
                  color: Colors.white,
                  child: Container(
                    height: 96.h,
                    color: Colors.white,
                    margin: EdgeInsets.only(bottom: 10.w),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: [
                        Offstage(
                          offstage: isPreview,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {},
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  height: 50.h,
                                  child: ByWidgetsUtil.commonContainer(
                                    alignment: Alignment.center,
                                    bgColor: const Color(0xFFF3F5F9),
                                    borerRadius: 50.h,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 19.w,
                                    ),
                                    child: ByWidgetsUtil.commonText(
                                      text: caseBean.withdrawMoney,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      textColor: ByColorUtil.CommonTextColor,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: -9.h,
                                  child: Offstage(
                                    offstage: caseBean.withdrawMoneyTip.isEmpty,
                                    child: ByWidgetsUtil.commonContainer(
                                      bgColor: const Color(0xFFF49A2F),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 2.h,
                                        horizontal: 4.w,
                                      ),
                                      child: ByWidgetsUtil.commonText(
                                        text: caseBean.withdrawMoneyTip,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.normal,
                                        textColor: const Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _clickDoSameEvent(context: context);
                            },
                            child: SizedBox(
                              height: 50.h,
                              child: ByWidgetsUtil.commonContainer(
                                alignment: Alignment.center,
                                bgColor: ByColorUtil.LoginBtnBgColor,
                                borerRadius: 50.h,
                                child: ByWidgetsUtil.commonRichText(
                                  texts: isPreview
                                      ? [const TextSpan(text: "做同款")]
                                      : [
                                          const TextSpan(text: "做同款"),
                                          TextSpan(
                                            text: "  ${caseBean.useTime}",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.normal,
                                              color: ByColorUtil
                                                  .WhiteColor.withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  textColor: ByColorUtil.WhiteColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 11,
              top: ByScreenUtils.topSafeHeight + kToolbarHeight * 0.5 - 16,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  ByNavRouterUtils.goBack(context);
                },
                child: Image.asset(
                  "assets/ai/ai_same_case_back.png",
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildLabels() {
    final List widgets = [];
    final labels = caseBean.labels ?? [];
    for (var element in labels) {
      widgets.add(SizedBox(width: 5.w));
      widgets.add(
        SizedBox(
          height: 18.sp,
          child: ByWidgetsUtil.commonBtn(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            borderColor: const Color(0xFF040A22),
            borderWidth: 0.5,
            bgColor: ByColorUtil.WhiteColor,
            title: element,
            fontSize: 12.sp,
            fontWeight: FontWeight.normal,
            textColor: const Color(0xFF0E1840),
            onClick: () {},
          ),
        ),
      );
    }
    return widgets;
  }
}
