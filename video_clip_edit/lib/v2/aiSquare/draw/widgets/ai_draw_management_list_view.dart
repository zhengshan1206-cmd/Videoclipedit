import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/ai_draw_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/ai_draw_work_details_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_img_details_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_work_management_provider.dart';

class AiDrawManagementSliverListView extends StatefulWidget {
  const AiDrawManagementSliverListView({super.key});

  @override
  State<AiDrawManagementSliverListView> createState() =>
      _AiDrawManagementSliverListViewState();
}

class _AiDrawManagementSliverListViewState
    extends State<AiDrawManagementSliverListView> {
  @override
  Widget build(BuildContext context) {
    final List<AiDrawImgDetailsBean> videoRecordBeans = context
        .select<AiDrawWorkManagementProvider, List<AiDrawImgDetailsBean>>(
      (p) => p.workRecordBeans,
    );
    return SliverGrid.builder(
      itemCount: videoRecordBeans.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 17 / 25,
      ),
      itemBuilder: (context, index) => AiDrawManagementListViewCell(
        index: index,
        bean: videoRecordBeans[index],
      ),
    );
  }
}

class AiDrawManagementListView extends StatefulWidget {
  const AiDrawManagementListView({
    super.key,
  });

  @override
  State<AiDrawManagementListView> createState() =>
      _AiDrawManagementListViewState();
}

class _AiDrawManagementListViewState extends State<AiDrawManagementListView> {
  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiDrawManagementListView:----");
    final List<AiDrawImgDetailsBean> videoRecordBeans = context
        .select<AiDrawWorkManagementProvider, List<AiDrawImgDetailsBean>>(
      (p) => p.workRecordBeans,
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
      itemBuilder: (context, index) => AiDrawManagementListViewCell(
        index: index,
        bean: videoRecordBeans[index],
      ),
    );
  }
}

enum AiCartoonPictureStatus {
  // 0 创建
  pictureCreate,
  // 1 预估积分
  picturePredictPrice,
  // 2 生成中
  pictureGenerating,
  // 3 生成完成
  complete,
  // 4 生成失败
  failed,
}

extension AiCartoonPictureStatusExt on AiCartoonPictureStatus {
  int get rawValue {
    switch (this) {
      case AiCartoonPictureStatus.pictureCreate:
        return 0;
      case AiCartoonPictureStatus.picturePredictPrice:
        return 1;
      case AiCartoonPictureStatus.pictureGenerating:
        return 2;
      case AiCartoonPictureStatus.complete:
        return 3;
      case AiCartoonPictureStatus.failed:
        return 4;
      default:
        return 0;
    }
  }

  static AiCartoonPictureStatus fromRawValue(int value) {
    switch (value) {
      case 0:
        return AiCartoonPictureStatus.pictureCreate;
      case 1:
        return AiCartoonPictureStatus.picturePredictPrice;
      case 2:
        return AiCartoonPictureStatus.pictureGenerating;
      case 3:
        return AiCartoonPictureStatus.complete;
      case 4:
        return AiCartoonPictureStatus.failed;
      default:
        return AiCartoonPictureStatus.pictureGenerating;
    }
  }
}

class AiDrawManagementListViewCell extends StatelessWidget {
  const AiDrawManagementListViewCell({
    super.key,
    required this.index,
    required this.bean,
  });

  final int index;
  final AiDrawImgDetailsBean bean;
  @override
  Widget build(BuildContext context) {
    byDebugPrint("---AiDrawManagementListViewCell");
    final status = AiCartoonPictureStatusExt.fromRawValue(bean.status);

    bool showCommonBg = [
      AiCartoonPictureStatus.pictureCreate,
      AiCartoonPictureStatus.picturePredictPrice,
      AiCartoonPictureStatus.pictureGenerating
    ].contains(status);

    bool showFaildBg = [AiCartoonPictureStatus.failed].contains(status);

    final videosEditing = context.select<AiDrawWorkManagementProvider, bool>(
        (value) => value.worksEditing);

    final selectedVideoIdxs =
        context.select<AiDrawWorkManagementProvider, List<int>>(
            (value) => value.selectedWorkIdxs);
    final selected = selectedVideoIdxs.contains(index);

    byDebugPrint("$selectedVideoIdxs----selected:$selected");

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (videosEditing) {
          context
              .read<AiDrawWorkManagementProvider>()
              .updateSelectedWorkIdxsWithIndex(index);
        } else {
          if (status == AiCartoonPictureStatus.complete) {
            // 上报点击埋点
            ByNavigatorUtil.reportDataPoint(
              pageTag: "myworks_list_intelligent_draw_works",
              operateType: "click",
              funcDetailTag: bean.id.toString(),
              funcDetailImg: bean.picUrl,
            );
            ByNavRouterUtils.push(
                context,
                MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                        create: (context) => AiDrawProvider(),
                      )
                    ],
                    child: AiDrawWorkDetailsPage(
                      workId: bean.id,
                    )));
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
                "assets/ai/ai_cartoon_video_bg_faild.png",
                fit: BoxFit.cover,
              )),
            if (showFaildBg)
              Positioned.fill(
                  child: Image.asset(
                "assets/ai/ai_cartoon_video_bg_faild.png",
                fit: BoxFit.cover,
              )),
            if (status == AiCartoonPictureStatus.complete)
              Positioned.fill(
                  child: CachedNetworkImage(
                imageUrl: bean.picUrl,
                fit: BoxFit.cover,
              )),
            if (showCommonBg)
              Positioned.fill(
                  child: Column(
                children: [
                  SizedBox(height: 40.h),
                  ByWidgetsUtil.activityIndicator(),
                  SizedBox(height: 30.h),
                  ByWidgetsUtil.commonText(
                    text: "生成中...",
                    textColor: Colors.white,
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 40.h),
                  //刷新进度-绘图
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
                            .read<AiDrawWorkManagementProvider>()
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
                          text: bean.createdAt ?? "",
                          // text: ByCommonUtils.timestamp2DatetimeString(
                          //     bean.createdAt!.millisecondsSinceEpoch),
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
            if (status == AiCartoonPictureStatus.failed)
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
                        final provider = AiDrawProvider();
                        provider.desc = bean.prompt;
                        provider.ratio = bean.ratio;
                        // /// 跳转到页面配置
                        ByNavRouterUtils.push(
                          context,
                          ChangeNotifierProvider.value(
                            value: provider,
                            child: const AiDrawPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )),
            if (videosEditing &&
                [
                  AiCartoonPictureStatus.complete,
                  AiCartoonPictureStatus.failed,
                ].contains(status))
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
