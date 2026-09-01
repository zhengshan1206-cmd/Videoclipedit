import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/new_ai_video_page.dart';
import 'package:bot_toast/bot_toast.dart';

import '../models/ai_video_generation_model.dart';
import '../provider/ai_video_management_provider.dart';
import '../provider/ai_video_provider.dart';
import 'ai_video_preview_page.dart';

class AiVideoManagementSliverListView extends StatefulWidget {
  const AiVideoManagementSliverListView({
    super.key,
    this.finishPage,
  });

  final bool? finishPage;

  @override
  State<AiVideoManagementSliverListView> createState() =>
      _AiVideoManagementSliverListViewState();
}

class _AiVideoManagementSliverListViewState
    extends State<AiVideoManagementSliverListView> {
  @override
  Widget build(BuildContext context) {
    final List<AiVideoGenerationTaskModel> videoRecordBeans = context
        .select<AiVideoManagementProvider, List<AiVideoGenerationTaskModel>>(
      (p) => p.videoRecordBeans,
    );

    return SliverGrid.builder(
      itemCount: videoRecordBeans.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 17 / 25,
      ),
      itemBuilder: (context, index) => AiVideoManagementListViewCell(
        index: index,
        bean: videoRecordBeans[index],
        finishPage: widget.finishPage,
      ),
    );
  }
}

class AiVideoManagementListView extends StatefulWidget {
  const AiVideoManagementListView({
    super.key,
  });

  @override
  State<AiVideoManagementListView> createState() =>
      _AiVideoManagementListViewState();
}

class _AiVideoManagementListViewState extends State<AiVideoManagementListView> {
  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiVideoManagementListView:----");
    final List<AiVideoGenerationTaskModel> videoRecordBeans = context
        .select<AiVideoManagementProvider, List<AiVideoGenerationTaskModel>>(
      (p) => p.videoRecordBeans,
    );

    return GridView.builder(
      itemCount: videoRecordBeans.length,
      padding: EdgeInsets.only(bottom: 66.h + ByScreenUtils.bottomSafeHeight),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 17 / 25,
      ),
      itemBuilder: (context, index) => AiVideoManagementListViewCell(
        index: index,
        bean: videoRecordBeans[index],
      ),
    );
  }
}

class AiVideoManagementListViewCell extends StatelessWidget {
  const AiVideoManagementListViewCell({
    super.key,
    required this.index,
    required this.bean,
    this.finishPage,
  });

  final int index;
  final AiVideoGenerationTaskModel bean;
  final bool? finishPage;

  @override
  Widget build(BuildContext context) {
    byDebugPrint("---AiVideoManagementListViewCell");
    final status = bean.status;

    bool showCommonBg = status != AiVideoStatus.done &&
        status != AiVideoStatus.failed &&
        bean.isDeleted;

    bool showFaildBg = status == AiVideoStatus.failed || bean.isDeleted;

    final videosEditing = context.select<AiVideoManagementProvider, bool>(
        (value) => value.videosEditing);

    final selectedVideoIdxs =
        context.select<AiVideoManagementProvider, List<int>>(
            (value) => value.selectedVideoIdxs);
    final selected = selectedVideoIdxs.contains(index);

    byDebugPrint("$selectedVideoIdxs----selected:$selected");

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (videosEditing) {
          context
              .read<AiVideoManagementProvider>()
              .updateSelectedVideoIdxsWithIndex(index);
        } else {
          if (status == AiVideoStatus.done) {
            // 上报点击埋点
            ByNavigatorUtil.reportDataPoint(
              pageTag: "myworks_list_motion_video_works",
              operateType: "click",
              funcDetailTag: bean.id.toString(),
              funcDetailImg: bean.coverUrl ?? "",
            );
            final provider = context.read<AiVideoManagementProvider>();
            log("provider===> ${provider.page}");
            ByNavRouterUtils.push(
                context,
                AiVideoPreviewPage(
                  videoBean: bean,
                  provider: provider,
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
            if (status == AiVideoStatus.done && bean.image != null)
              Positioned.fill(
                  child: CachedNetworkImage(
                imageUrl: bean.coverUrl!,
                fit: BoxFit.cover,
              )),
            if (status == AiVideoStatus.generating ||
                status == AiVideoStatus.taskCreated ||
                status == AiVideoStatus.taskSubmitted)
              Positioned.fill(
                  child: Column(
                children: [
                  SizedBox(height: 40.h),
                  ByWidgetsUtil.activityIndicator(color: Colors.white),
                  SizedBox(height: 40.h),
                  ByWidgetsUtil.commonText(
                    text: "视频生成中...",
                    textColor: Colors.white,
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 30.h),
                  //刷新进度-动态视频
                  SizedBox(
                    width: 150.w,
                    height: 32.h,
                    child: ByWidgetsUtil.commonBtn(
                      padding: EdgeInsets.zero,
                      fontWeight: FontWeight.normal,
                      bgColor: ByColorUtil.TabTextColorSelected,
                      borderRadius: 8.w,
                      fontSize: 14.sp,
                      title: "刷新进度",
                      onClick: () {
                        context
                            .read<AiVideoManagementProvider>()
                            .refreshProgress();
                      },
                    ),
                  ),
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
                          text: bean.updateAt,
                          // text: ByCommonUtils.timestamp2DatetimeString(
                          //   bean.updateAt * 1000,
                          // ),
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
            if (status == AiVideoStatus.failed)
              Positioned.fill(
                  child: Column(
                children: [
                  SizedBox(height: 40.h),
                  ByWidgetsUtil.commonText(
                      fontSize: 14.sp,
                      text: "生成失败积分已退回",
                      textColor: Colors.white,
                      fontWeight: FontWeight.bold),
                  SizedBox(height: 40.h),
                  Image.asset(
                    "assets/ai/ai_cartoon_video_faild.png",
                    width: 32.w,
                    height: 32.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 30.h),
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
                        final provider = AiVideoProvider();
                        if (finishPage == true) {
                          Navigator.pop(context, bean);
                        } else {
                          Get.toNamed(Routes.aiDynamicVideoPage,
                              arguments: bean);
                        }
                        // ByNavRouterUtils.push(
                        //     context,
                        //     MultiProvider(
                        //         providers: [
                        //           ChangeNotifierProvider(
                        //               create: (context) => provider),
                        //         ],
                        //         child: NewAiVideoPage(
                        //           initType: bean.type,
                        //           prompt: bean.prompt,
                        //           negativePrompt: bean.negativePrompt,
                        //           images: bean.images,
                        //           cfgScale: bean.cfgScale,
                        //           duration: bean.duration,
                        //           aspectRatio: bean.aspectRatio,
                        //           mode: bean.mode,
                        //         )));
                      },
                    ),
                  ),
                ],
              )),
            // if (status == AiVideoStatus.deleted)
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
            if (status == AiVideoStatus.done)
              Positioned.fill(
                  child: Center(
                child: Image.asset(
                  "assets/ai/ai_cartoon_video_play.png",
                  width: 40.w,
                  height: 40.h,
                  fit: BoxFit.contain,
                ),
              )),
            if (videosEditing)
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
