import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_videos_management_provider.dart';
import 'package:video_clip_edit/modules/profile/widgets/mine_videos_management_gride_view.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_page.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_opening_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_screen_config_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_video_preview_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_video_management_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_record_bean.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_videos_single_page_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_video_management_list_view.dart';

class MineVideoManagementListViewCell extends StatelessWidget {
  const MineVideoManagementListViewCell({
    super.key,
    required this.index,
    required this.bean,
    required this.type,
  });

  final int index;
  final MineVideoType type;
  final AiCartoonVideoRecordBean bean;

  @override
  Widget build(BuildContext context) {
    byDebugPrint("---AiCartoonVideoManagementListViewCell");
    final status = AiCartoonVideoStatusExt.fromRawValue(bean.status);

    bool showCommonBg = status != AiCartoonVideoStatus.finished &&
        status != AiCartoonVideoStatus.failed &&
        status != AiCartoonVideoStatus.deleted;

    bool showFaildBg = status == AiCartoonVideoStatus.failed ||
        status == AiCartoonVideoStatus.deleted;

    String mode = bean.isAutoVideo == 1 ? "自动模式" : "手动模式";

    final videosEditing = context.select<MineVideosManagementProvider, bool>(
        (value) => value.videosEditing);

    final selectedVideoIdxs =
        context.select<MineVideosSinglePageProvider, List<int>>(
            (value) => value.selectedVideoIdxs);
    final selected = selectedVideoIdxs.contains(index);

    byDebugPrint("$selectedVideoIdxs----selected:$selected");

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (videosEditing) {
          context
              .read<MineVideosSinglePageProvider>()
              .updateSelectedVideoIdxsWithIndex(index);
        } else {
          if (status == AiCartoonVideoStatus.finished) {
            ByNavRouterUtils.push(
                context,
                AiCartoonVideoPreviewPage(
                  videoBean: bean,
                  type: type,
                  provider: context.read<MineVideosSinglePageProvider>(),
                ));
          }
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (showCommonBg)
              Positioned.fill(
                  child: Image.asset(
                "assets/ai/ai_cartoon_video_bg.png",
                fit: BoxFit.cover,
              )),
            if (showFaildBg)
              Positioned.fill(
                  child: Image.asset(
                "assets/ai/ai_cartoon_video_bg_faild.png",
                fit: BoxFit.cover,
              )),
            if (status == AiCartoonVideoStatus.finished)
              Positioned.fill(
                  child: CachedNetworkImage(
                imageUrl: bean.imgUrl,
                fit: BoxFit.cover,
              )),
            if (status == AiCartoonVideoStatus.videoGenerating)
              Positioned.fill(
                  child: Column(
                children: [
                  SizedBox(height: 75.h),
                  ByWidgetsUtil.activityIndicator(),
                  SizedBox(height: 50.h),
                  ByWidgetsUtil.commonText(
                    text: "视频生成中...",
                    textColor: Colors.white,
                    fontSize: 14.sp,
                  )
                ],
              )),
            if (status == AiCartoonVideoStatus.pictureGenerting)
              Positioned.fill(
                  child: Column(
                children: [
                  SizedBox(height: 75.h),
                  ByWidgetsUtil.activityIndicator(),
                  SizedBox(height: 50.h),
                  ByWidgetsUtil.commonText(
                    text: "成图中...",
                    textColor: Colors.white,
                    fontSize: 14.sp,
                  )
                ],
              )),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 60.h,
              child: ByWidgetsUtil.gradientBgContainer(
                borderRadius: 0,
                padding: EdgeInsets.zero,
                gradient: ByColorUtil.lineareGradient(
                  colorStart: const Color(0xFF000000),
                  colorEnd: const Color(0xFF000000).withOpacity(0.01),
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                child: Column(
                  children: [
                    const Spacer(),
                    Row(
                      children: [
                        SizedBox(width: 10.w),
                        ByWidgetsUtil.commonText(
                          text: ByCommonUtils.timestamp2DatetimeString(
                            bean.updateAt * 1000,
                          ),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.normal,
                          textColor: Colors.white,
                        ),
                        const Spacer(),
                        // ByWidgetsUtil.commonText(
                        //   text: "15:33:33",
                        //   fontSize: 12.sp,
                        //   fontWeight: FontWeight.normal,
                        //   textColor: Colors.white,
                        // ),
                        // SizedBox(width: 10.w),
                      ],
                    ),
                    SizedBox(height: 11.h),
                  ],
                ),
              ),
            ),
            if (status == AiCartoonVideoStatus.paragraphFinished)
              Positioned.fill(
                  child: Column(
                children: [
                  SizedBox(height: 75.h),
                  Image.asset(
                    "assets/ai/ai_cartoon_video_paragraph.png",
                    width: 32.w,
                    height: 32.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 24.h),
                  ByWidgetsUtil.commonText(
                    text: "已完成分段",
                    textColor: Colors.white,
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 22.h),
                  SizedBox(
                    width: 150.w,
                    height: 32.h,
                    child: ByWidgetsUtil.commonBtn(
                      padding: EdgeInsets.zero,
                      fontWeight: FontWeight.normal,
                      bgColor: ByColorUtil.CommonTextColor.withOpacity(0.8),
                      borderRadius: 8.w,
                      fontSize: 14.sp,
                      title: "继续成片",
                      onClick: () {
                        final provider = AiCartoonProvider();
                        provider.selectedVideoModeIndex =
                            bean.isAutoVideo == 1 ? 0 : 1;
                        provider.pid = bean.id.toString();

                        /// 跳转到页面配置
                        ByNavRouterUtils.push(
                          context,
                          ChangeNotifierProvider.value(
                            value: provider,
                            child: AiCartoonScreenConfigPage(
                                isRecovery: true, bean: bean),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )),
            if (status == AiCartoonVideoStatus.failed)
              Positioned.fill(
                  child: Column(
                children: [
                  SizedBox(height: 37.h),
                  ByWidgetsUtil.commonText(
                      fontSize: 14.sp,
                      text: "生成失败积分已退回",
                      textColor: Colors.white,
                      fontWeight: FontWeight.bold),
                  SizedBox(height: 46.h),
                  Image.asset(
                    "assets/ai/ai_cartoon_video_faild.png",
                    width: 32.w,
                    height: 32.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 40.h),
                  SizedBox(
                    width: 150.w,
                    height: 32.h,
                    child: ByWidgetsUtil.commonBtn(
                      padding: EdgeInsets.zero,
                      fontWeight: FontWeight.normal,
                      bgColor: ByColorUtil.TabTextColorSelected,
                      borderRadius: 8.w,
                      fontSize: 14.sp,
                      title: "重新生成",
                      onClick: () {
                        byDebugPrint(bean.toJson());
                        final provider = AiCartoonProvider();
                        provider.desc = bean.text;
                        // /// 跳转到页面配置
                        if (type == AiCartoonVideoManagementPageType.normal) {
                          ByNavRouterUtils.push(
                            context,
                            ChangeNotifierProvider.value(
                              value: provider,
                              child: const AiCartoonPage(),
                            ),
                          );
                        } else {
                          final clipProvider = AiClipProvider();
                          clipProvider.desc = bean.text;
                          ByNavRouterUtils.push(
                              context,
                              MultiProvider(providers: [
                                ChangeNotifierProvider(
                                    create: (context) => clipProvider),
                                ChangeNotifierProvider(
                                  create: (BuildContext context) =>
                                      AiMaterialProvider(),
                                ),
                                ChangeNotifierProvider(
                                  create: (BuildContext context) =>
                                      AiClipOpeningProvider(),
                                ),
                              ], child: const AiClipPage()));
                        }
                      },
                    ),
                  ),
                ],
              )),
            // if (status == AiCartoonVideoStatus.deleted)
            //   Positioned.fill(
            //       child: Column(
            //     children: [
            //       SizedBox(height: 113.h),
            //       ByWidgetsUtil.commonText(
            //           fontSize: 14.sp,
            //           text: "已删除",
            //           textColor: Colors.white,
            //           fontWeight: FontWeight.bold),
            //     ],
            //   )),
            if (status == AiCartoonVideoStatus.finished)
              Positioned.fill(
                  child: Center(
                child: Image.asset(
                  "assets/ai/ai_cartoon_video_play.png",
                  width: 40.w,
                  height: 40.h,
                  fit: BoxFit.contain,
                ),
              )),
            if (showCommonBg && type == AiCartoonVideoManagementPageType.normal)
              Positioned(
                  top: 14.h,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 12.w,
                        height: 12.w,
                        child: ByWidgetsUtil.commonContainer(
                          borerRadius: 12.w,
                          padding: EdgeInsets.all(3.w),
                          bgColor: const Color(0xFFFFFFFF).withOpacity(0.3),
                          child: ByWidgetsUtil.commonContainer(
                            child: Container(),
                          ),
                        ),
                      ),
                      SizedBox(width: 5.w),
                      ByWidgetsUtil.commonText(
                        text: mode,
                        textColor: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  )),
            if (videosEditing &&
                [AiCartoonVideoStatus.finished, AiCartoonVideoStatus.failed]
                    .contains(status))
              Positioned(
                  right: 10.w,
                  top: 10.h,
                  child: Image.asset(
                    "assets/login/mywork_cell_${selected ? "selected" : "unselected"}.png",
                    width: 24.w,
                    height: 24.h,
                    fit: BoxFit.contain,
                  )),
          ],
        ),
      ),
    );
  }
}
