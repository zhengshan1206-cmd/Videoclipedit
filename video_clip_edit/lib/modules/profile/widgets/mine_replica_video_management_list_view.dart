import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_videos_management_provider.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_videos_single_page_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_video_preview_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_record_bean.dart';

import 'mine_videos_management_gride_view.dart';

class MineReplicaVideoManagementListView extends StatefulWidget {
  final MineVideoType type;
  const MineReplicaVideoManagementListView({
    super.key,
    required this.type,
  });

  @override
  State<MineReplicaVideoManagementListView> createState() =>
      _AiOralVideoManagementListViewState();
}

class _AiOralVideoManagementListViewState
    extends State<MineReplicaVideoManagementListView> {
  @override
  Widget build(BuildContext context) {
    final List<AiCartoonVideoRecordBean> videoRecordBeans = context
        .select<MineVideosSinglePageProvider, List<AiCartoonVideoRecordBean>>(
      (p) => p.hotRecordBeans,
    );

    return GridView.builder(
      itemCount: videoRecordBeans.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 17 / 25,
      ),
      itemBuilder: (context, index) => MineReplicaVideoManagementListViewCell(
        index: index,
        bean: videoRecordBeans[index],
        type: widget.type,
      ),
    );
  }
}

// 状态 1待完善 2已提交 3生成中 4生成成功 5生成失败
enum ReplicaVideoStatus {
  // 1 成图中
  pictureGenerting,
  // 2 填充完成可以提交
  paragraphFinished,
  // 3 已经提交
  videoGenerating,
  // 4视频生成失败
  failed,
  // 5 视频生成成功
  finished,
  // 已删除
  deleted,
}

extension AiHotCartoonVideoStatusExt on ReplicaVideoStatus {
  int get rawValue {
    switch (this) {
      case ReplicaVideoStatus.pictureGenerting:
        return 1;
      case ReplicaVideoStatus.paragraphFinished:
        return 2;
      case ReplicaVideoStatus.videoGenerating:
        return 3;
      case ReplicaVideoStatus.failed:
        return 4;
      case ReplicaVideoStatus.finished:
        return 5;
      case ReplicaVideoStatus.deleted:
        return 6;
      default:
        return 0;
    }
  }

  static ReplicaVideoStatus fromRawValue(int value) {
    switch (value) {
      case 1:
        return ReplicaVideoStatus.pictureGenerting;
      case 2:
        return ReplicaVideoStatus.paragraphFinished;
      case 3:
        return ReplicaVideoStatus.videoGenerating;
      case 4:
        return ReplicaVideoStatus.failed;
      case 5:
        return ReplicaVideoStatus.finished;
      case 6:
        return ReplicaVideoStatus.deleted;
      default:
        return ReplicaVideoStatus.pictureGenerting;
    }
  }
}

class MineReplicaVideoManagementListViewCell extends StatelessWidget {
  const MineReplicaVideoManagementListViewCell({
    super.key,
    required this.index,
    required this.bean,
    required this.type,
  });

  final int index;
  final AiCartoonVideoRecordBean bean;
  final MineVideoType type;

  @override
  Widget build(BuildContext context) {
    byDebugPrint("---AiCartoonVideoManagementListViewCell");
    final status = AiHotCartoonVideoStatusExt.fromRawValue(bean.status);

    bool showCommonBg = status != ReplicaVideoStatus.finished &&
        status != ReplicaVideoStatus.failed &&
        status != ReplicaVideoStatus.deleted;

    bool showFaildBg = status == ReplicaVideoStatus.failed ||
        status == ReplicaVideoStatus.deleted;

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
          if (status == ReplicaVideoStatus.finished) {
            ByNavRouterUtils.push(
                context,
                AiCartoonVideoPreviewPage(
                  videoBean: bean,
                  showCopyBtn: false,
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
            if (status == ReplicaVideoStatus.finished)
              Positioned.fill(
                  child: CachedNetworkImage(
                imageUrl: bean.imgUrl,
                fit: BoxFit.cover,
              )),
            if (status == ReplicaVideoStatus.videoGenerating)
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
            if (status == ReplicaVideoStatus.pictureGenerting)
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
            if (status == ReplicaVideoStatus.paragraphFinished)
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
                ],
              )),
            if (status == ReplicaVideoStatus.failed)
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
            if (status == ReplicaVideoStatus.finished)
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
                [ReplicaVideoStatus.finished, ReplicaVideoStatus.failed]
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
