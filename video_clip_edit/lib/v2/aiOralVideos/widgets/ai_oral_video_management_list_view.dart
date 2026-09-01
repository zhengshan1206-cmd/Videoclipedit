import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/aiOralVideos/ai_oral_video_preview_page.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_video_item_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_video_management_provider.dart';

import '../ai_oral_video_management_page.dart';

class AiOralVideoManagementListView extends StatefulWidget {
  const AiOralVideoManagementListView({
    super.key,
    this.recordType,
  });

  final ManagementRecord? recordType;

  @override
  State<AiOralVideoManagementListView> createState() =>
      _AiOralVideoManagementListViewState();
}

class _AiOralVideoManagementListViewState
    extends State<AiOralVideoManagementListView> {
  @override
  Widget build(BuildContext context) {
    final List<AiOralVideotemBean> videoRecordBeans =
        context.select<AiOralVideoManagementProvider, List<AiOralVideotemBean>>(
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
      itemBuilder: (context, index) => AiCartoonVideoManagementListViewCell(
        index: index,
        bean: videoRecordBeans[index],
        recordType: widget.recordType,
      ),
    );
  }
}

// 状态 1待完善 2已提交 3生成中 4生成成功 5生成失败
enum AiCartoonVideoStatus {
  // 1 待完善
  uncommitted,
  // 2 已提交
  committed,
  // 3 已经提交
  videoGenerating,
  // 4 视频生成成功
  finished,
  // 5 生成失败
  failed,
}

extension AiCartoonVideoStatusExt on AiCartoonVideoStatus {
  int get rawValue {
    switch (this) {
      case AiCartoonVideoStatus.uncommitted:
        return 1;
      case AiCartoonVideoStatus.committed:
        return 2;
      case AiCartoonVideoStatus.videoGenerating:
        return 3;
      case AiCartoonVideoStatus.finished:
        return 4;
      case AiCartoonVideoStatus.failed:
        return 5;
      default:
        return 0;
    }
  }

  static AiCartoonVideoStatus fromRawValue(int value) {
    switch (value) {
      case 1:
        return AiCartoonVideoStatus.uncommitted;
      case 2:
        return AiCartoonVideoStatus.committed;
      case 3:
        return AiCartoonVideoStatus.videoGenerating;
      case 4:
        return AiCartoonVideoStatus.finished;
      case 5:
        return AiCartoonVideoStatus.failed;
      default:
        return AiCartoonVideoStatus.videoGenerating;
    }
  }
}

class AiCartoonVideoManagementListViewCell extends StatelessWidget {
  const AiCartoonVideoManagementListViewCell({
    super.key,
    required this.index,
    required this.bean,
    this.recordType,
  });

  final int index;
  final AiOralVideotemBean bean;
  final ManagementRecord? recordType;

  @override
  Widget build(BuildContext context) {
    byDebugPrint("---AiCartoonVideoManagementListViewCell");
    final status = AiCartoonVideoStatusExt.fromRawValue(bean.status);

    bool showCommonBg = status != AiCartoonVideoStatus.finished &&
        status != AiCartoonVideoStatus.failed;

    bool showFaildBg = status == AiCartoonVideoStatus.failed;

    final videosEditing = context.select<AiOralVideoManagementProvider, bool>(
        (value) => value.videosEditing);

    final selectedVideoIdxs =
        context.select<AiOralVideoManagementProvider, List<int>>(
            (value) => value.selectedVideoIdxs);
    final selected = selectedVideoIdxs.contains(index);

    byDebugPrint("$selectedVideoIdxs----selected:$selected");

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (videosEditing) {
          context
              .read<AiOralVideoManagementProvider>()
              .updateSelectedVideoIdxsWithIndex(index);
        } else {
          if (status == AiCartoonVideoStatus.finished) {
            // 上报点击埋点
            final pageTag = recordType == ManagementRecord.aiAnime
                ? "myworks_list_anime_works"
                : "myworks_list_digital_human_works";
            ByNavigatorUtil.reportDataPoint(
              pageTag: pageTag,
              operateType: "click",
              funcDetailTag: bean.id.toString(),
              funcDetailImg: bean.coverUrl,
            );
            ByNavRouterUtils.push(
                context,
                AiOralVideoPreviewPage(
                  videoUrl: bean.videoUrl,
                  id: bean.id,
                  provider: context.read<AiOralVideoManagementProvider>(),
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
                imageUrl: bean.coverUrl,
                fit: BoxFit.cover,
              )),
            if ([
              AiCartoonVideoStatus.videoGenerating,
              AiCartoonVideoStatus.uncommitted,
              AiCartoonVideoStatus.committed,
            ].contains(status))
              Positioned.fill(
                  child: Column(
                children: [
                  SizedBox(height: 40.h),
                  ByWidgetsUtil.activityIndicator(isNormal: false),
                  SizedBox(height: 30.h),
                  ByWidgetsUtil.commonText(
                    text: "视频生成中...",
                    textColor: Colors.white,
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 30.h),
                  //刷新进度-数字人
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
                            .read<AiOralVideoManagementProvider>()
                            .refreshProgress(type: recordType!);
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
                          text: ByCommonUtils.timestamp2DatetimeString(
                              bean.createdAt.millisecondsSinceEpoch),
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
