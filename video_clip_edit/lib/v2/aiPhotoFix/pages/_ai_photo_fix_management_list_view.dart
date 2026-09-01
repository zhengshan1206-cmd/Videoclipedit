import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiPhotoFix/pages/new_hd_photo_fix_page.dart';

import '../models/ai_photo_fix_task_model.dart';
import '../provider/ai_photo_fix_management_provider.dart';
import '../provider/ai_photo_fix_provider.dart';
import 'ai_photo_fix_preview_page.dart';
import 'new_old_photo_fix_page.dart';

class AiPhotoFixManagementSliverListView extends StatefulWidget {
  const AiPhotoFixManagementSliverListView({
    super.key,
  });

  @override
  State<AiPhotoFixManagementSliverListView> createState() =>
      _AiPhotoFixManagementSliverListViewState();
}

class _AiPhotoFixManagementSliverListViewState
    extends State<AiPhotoFixManagementSliverListView> {
  @override
  Widget build(BuildContext context) {
    final List<AiPhotoFixTaskModel> videoRecordBeans = context
        .select<AiPhotoFixManagementProvider, List<AiPhotoFixTaskModel>>(
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
      itemBuilder: (context, index) => AiPhotoFixManagementListViewCell(
        index: index,
        bean: videoRecordBeans[index],
      ),
    );
  }
}

class AiPhotoFixManagementListView extends StatefulWidget {
  const AiPhotoFixManagementListView({
    super.key,
  });

  @override
  State<AiPhotoFixManagementListView> createState() =>
      _AiPhotoFixManagementListViewState();
}

class _AiPhotoFixManagementListViewState extends State<AiPhotoFixManagementListView> {
  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiPhotoFixManagementListView:----");
    final List<AiPhotoFixTaskModel> videoRecordBeans = context
        .select<AiPhotoFixManagementProvider, List<AiPhotoFixTaskModel>>(
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
      itemBuilder: (context, index) => AiPhotoFixManagementListViewCell(
        index: index,
        bean: videoRecordBeans[index],
      ),
    );
  }
}

class AiPhotoFixManagementListViewCell extends StatelessWidget {
  const AiPhotoFixManagementListViewCell({
    super.key,
    required this.index,
    required this.bean,
  });

  final int index;
  final AiPhotoFixTaskModel bean;

  @override
  Widget build(BuildContext context) {
    byDebugPrint("---AiPhotoFixManagementListViewCell");
    final status = bean.status;

    bool showCommonBg = status != AiPhotoFixStatus.done &&
        status != AiPhotoFixStatus.failed &&
        !bean.isDeleted;

    bool showFaildBg = status == AiPhotoFixStatus.failed || bean.isDeleted;

    final videosEditing = context.select<AiPhotoFixManagementProvider, bool>(
        (value) => value.videosEditing);

    final selectedVideoIdxs =
        context.select<AiPhotoFixManagementProvider, List<int>>(
            (value) => value.selectedVideoIdxs);
    final selected = selectedVideoIdxs.contains(index);

    byDebugPrint("$selectedVideoIdxs----selected:$selected");

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (videosEditing) {
          context
              .read<AiPhotoFixManagementProvider>()
              .updateSelectedVideoIdxsWithIndex(index);
        } else {
          if (status == AiPhotoFixStatus.done) {
            ByNavRouterUtils.push(context, MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(
                      value: context.read<AiPhotoFixManagementProvider>()
                  ),
                ],
                child: AiPhotoFixPreviewPage(taskModel: bean)
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
            if (status == AiPhotoFixStatus.done)
              Positioned.fill(
                  child: CachedNetworkImage(
                imageUrl: bean.imageUrl!,
                fit: BoxFit.cover,
              )),
            if (status == AiPhotoFixStatus.generating ||
                status == AiPhotoFixStatus.taskCreated ||
                status == AiPhotoFixStatus.taskSubmitted)
              Positioned.fill(
                  child: Column(
                children: [
                  SizedBox(height: 75.h),
                  ByWidgetsUtil.activityIndicator(color: Colors.white),
                  SizedBox(height: 36.h),
                  ByWidgetsUtil.commonText(
                    text: "图片修复中",
                    textColor: Colors.white,
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 15.h),
                  SizedBox(
                    height: 28.h,
                    width: 100.w,
                    child: ByWidgetsUtil.btnWithSvgIcon(
                      title: "刷新状态",
                      fontSize: 12.sp,
                      iconH: 11,
                      iconW: 11,
                      bgColor: ByColorUtil.WhiteColor,
                      borderRadius: 30,
                      padding: EdgeInsets.zero,
                      fontWeight: FontWeight.normal,
                      textColor: ByColorUtil.CommonTextColor,
                      iconPath: "assets/ai/clip/ai_clip_icon_refresh.svg",
                      onClick: () {
                        context
                            .read<AiPhotoFixManagementProvider>()
                            .refreshTaskStatus(bean.id);
                      },
                    ),
                  ),
                  SizedBox(height: 10.h),
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
            if (status == AiPhotoFixStatus.failed)
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
                        final provider = AiPhotoFixProvider();
                        if (bean.type == kAiOldPhotoFixTaskType) {
                          ByNavRouterUtils.push(
                              context,
                              MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider(
                                        create: (context) => provider),
                                  ],
                                  child: const NewOldPhotoFixPage()
                              )
                          );
                        } else if (bean.type == kAiHdPhotoFixTaskType) {
                          ByNavRouterUtils.push(
                              context,
                              MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider(
                                        create: (context) => provider),
                                  ],
                                  child: const NewHdPhotoFixPage()
                              )
                          );
                        }
                      },
                    ),
                  ),
                ],
              )),
            // if (status == AiPhotoFixStatus.deleted)
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
