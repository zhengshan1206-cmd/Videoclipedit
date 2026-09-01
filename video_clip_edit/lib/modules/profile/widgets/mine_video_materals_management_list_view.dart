import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_video_materials_management_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/aiOralVideos/ai_oral_video_preview_page.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_my_video_bean.dart';
import 'package:video_clip_edit/modules/profile/widgets/mine_video_materials_managment_page_view.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_video_materials_single_page_provider.dart';

class MineVideoMateralsManagementListView extends StatefulWidget {
  const MineVideoMateralsManagementListView({
    super.key,
    required this.index,
    required this.type,
  });
  final int index;
  final MineVideoMaterialsPageType type;
  @override
  State<MineVideoMateralsManagementListView> createState() =>
      _MineVideoMateralsManagementListViewState();
}

class _MineVideoMateralsManagementListViewState
    extends State<MineVideoMateralsManagementListView> {
  @override
  Widget build(BuildContext context) {
    final List<AiOralMyVideoBean> videoRecordBeans = context
        .select<MineVideoMaterialsSinglePageProvider, List<AiOralMyVideoBean>>(
      (p) => p.videoRecordBeans,
    );
    if (videoRecordBeans.isEmpty) return ByWidgetsUtil.commonListNoDataView();

    return GridView.builder(
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
        type: widget.type,
      ),
    );
  }
}

// 状态 1待完善 2已提交 3生成中 4生成成功 5生成失败
enum MineAiCartoonVideoStatus {
  // 1 待完善
  underReview,
  // 2 已提交
  success,
  // 3 已经提交
  failed,
  // 4 视频生成成功
  recommented,
}

extension MineAiCartoonVideoStatusExt on MineAiCartoonVideoStatus {
  int get rawValue {
    switch (this) {
      case MineAiCartoonVideoStatus.underReview:
        return 1;
      case MineAiCartoonVideoStatus.success:
        return 2;
      case MineAiCartoonVideoStatus.failed:
        return 3;
      case MineAiCartoonVideoStatus.recommented:
        return 4;
      default:
        return 0;
    }
  }

  static MineAiCartoonVideoStatus fromRawValue(int value) {
    switch (value) {
      case 1:
        return MineAiCartoonVideoStatus.underReview;
      case 2:
        return MineAiCartoonVideoStatus.success;
      case 3:
        return MineAiCartoonVideoStatus.failed;
      case 4:
        return MineAiCartoonVideoStatus.recommented;
      default:
        return MineAiCartoonVideoStatus.underReview;
    }
  }
}

class AiCartoonVideoManagementListViewCell extends StatelessWidget {
  const AiCartoonVideoManagementListViewCell({
    super.key,
    required this.index,
    required this.bean,
    required this.type,
  });

  final int index;
  final AiOralMyVideoBean bean;
  final MineVideoMaterialsPageType type;

  @override
  Widget build(BuildContext context) {
    final status = MineAiCartoonVideoStatusExt.fromRawValue(bean.status);

    bool showCommonBg = status == MineAiCartoonVideoStatus.underReview;
    bool showFaildBg = status == MineAiCartoonVideoStatus.failed;

    final videosEditing =
        context.select<MineVideoMaterialsManagementProvider, bool>(
            (value) => value.videosEditing);

    final selectedVideoIdxs =
        context.select<MineVideoMaterialsSinglePageProvider, List<int>>(
            (value) => value.selectedVideoIdxs);
    byDebugPrint(selectedVideoIdxs, tag: "=================selectedVideoIdxs:");
    final selected = selectedVideoIdxs.contains(index);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (videosEditing) {
          context
              .read<MineVideoMaterialsSinglePageProvider>()
              .updateSelectedVideoIdxsWithIndex(index);
        } else {
          if (status == MineAiCartoonVideoStatus.success) {
            // 上报点击埋点
            ByNavigatorUtil.reportDataPoint(
              pageTag: "myworks_list_source_material_works",
              operateType: "click",
              funcDetailTag: bean.id.toString(),
              funcDetailImg: bean.cover,
            );
            ByNavRouterUtils.push(
                context,
                AiOralVideoPreviewPage(
                  videoUrl: bean.url,
                  id: bean.id,
                  provider2:
                      context.read<MineVideoMaterialsSinglePageProvider>(),
                  type2: type,
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
            if (status == MineAiCartoonVideoStatus.success)
              Positioned.fill(
                  child: CachedNetworkImage(
                imageUrl: bean.cover,
                fit: BoxFit.cover,
              )),
            if ([
              MineAiCartoonVideoStatus.underReview,
            ].contains(status))
              Positioned.fill(
                  child: Column(
                children: [
                  SizedBox(height: 75.h),
                  ByWidgetsUtil.activityIndicator(isNormal: false),
                  SizedBox(height: 50.h),
                  ByWidgetsUtil.commonText(
                    text: "视频生成中...",
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

            if (status == MineAiCartoonVideoStatus.failed)
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
            if (status == MineAiCartoonVideoStatus.success)
              Positioned.fill(
                  child: Center(
                child: Image.asset(
                  "assets/ai/ai_cartoon_video_play.png",
                  width: 40.w,
                  height: 40.h,
                  fit: BoxFit.contain,
                ),
              )),
            if (videosEditing && status != MineAiCartoonVideoStatus.underReview)
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
