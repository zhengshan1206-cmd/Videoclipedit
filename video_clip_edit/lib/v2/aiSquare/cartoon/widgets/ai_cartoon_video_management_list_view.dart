import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/aiClip/ai_video_generating_page.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_page.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_opening_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_video_preview_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_screen_config_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_video_management_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_record_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_video_management_provider.dart';

import '../../mixin/ai_settings_mixin.dart';

class AiCartoonVideoManagementSliverListView extends StatefulWidget {
  final int? videoQueryType;
  const AiCartoonVideoManagementSliverListView({
    super.key,
    this.type = AiCartoonVideoManagementPageType.normal,
    this.videoQueryType,
    this.source,
  });

  final AiCartoonVideoManagementPageType? type;
  final EntranceSource? source;

  @override
  State<AiCartoonVideoManagementSliverListView> createState() =>
      _AiCartoonVideoManagementSliverListViewState();
}

class _AiCartoonVideoManagementSliverListViewState
    extends State<AiCartoonVideoManagementSliverListView> {
  @override
  Widget build(BuildContext context) {
    final List<AiCartoonVideoRecordBean> videoRecordBeans = context
        .select<
          AiCartoonVideoManagementProvider,
          List<AiCartoonVideoRecordBean>
        >((p) => p.videoRecordBeans);

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
        type: widget.type,
        videoQueryType: widget.videoQueryType,
        source: widget.source,
      ),
    );
  }
}

class AiCartoonVideoManagementListView extends StatefulWidget {
  final int? videoQueryType;
  final EntranceSource? source;

  const AiCartoonVideoManagementListView({
    super.key,
    this.type = AiCartoonVideoManagementPageType.normal,
    this.videoQueryType,
    this.source,
  });

  final AiCartoonVideoManagementPageType? type;

  @override
  State<AiCartoonVideoManagementListView> createState() =>
      _AiCartoonVideoManagementListViewState();
}

class _AiCartoonVideoManagementListViewState
    extends State<AiCartoonVideoManagementListView> {
  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiCartoonVideoManagementListView:----");
    final List<AiCartoonVideoRecordBean> videoRecordBeans = context
        .select<
          AiCartoonVideoManagementProvider,
          List<AiCartoonVideoRecordBean>
        >((p) => p.videoRecordBeans);

    return GridView.builder(
      itemCount: videoRecordBeans.length,
      padding: EdgeInsets.only(bottom: 66.h + ByScreenUtils.bottomSafeHeight),
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
        videoQueryType: widget.videoQueryType,
        source: widget.source,
      ),
    );
  }
}

enum AiCartoonVideoStatus {
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

extension AiCartoonVideoStatusExt on AiCartoonVideoStatus {
  int get rawValue {
    switch (this) {
      case AiCartoonVideoStatus.pictureGenerting:
        return 1;
      case AiCartoonVideoStatus.paragraphFinished:
        return 2;
      case AiCartoonVideoStatus.videoGenerating:
        return 3;
      case AiCartoonVideoStatus.failed:
        return 4;
      case AiCartoonVideoStatus.finished:
        return 5;
      case AiCartoonVideoStatus.deleted:
        return 6;
      default:
        return 0;
    }
  }

  static AiCartoonVideoStatus fromRawValue(int value) {
    switch (value) {
      case 1:
        return AiCartoonVideoStatus.pictureGenerting;
      case 2:
        return AiCartoonVideoStatus.paragraphFinished;
      case 3:
        return AiCartoonVideoStatus.videoGenerating;
      case 4:
        return AiCartoonVideoStatus.failed;
      case 5:
        return AiCartoonVideoStatus.finished;
      case 6:
        return AiCartoonVideoStatus.deleted;
      default:
        return AiCartoonVideoStatus.pictureGenerting;
    }
  }
}

class AiCartoonVideoManagementListViewCell extends StatelessWidget {
  const AiCartoonVideoManagementListViewCell({
    super.key,
    required this.index,
    required this.bean,
    this.type = AiCartoonVideoManagementPageType.normal,
    this.videoQueryType,
    this.source,
  });

  final int index;
  final AiCartoonVideoRecordBean bean;
  final AiCartoonVideoManagementPageType? type;
  final int? videoQueryType;
  final EntranceSource? source;

  String _getPageTag() {
    // 根据 type 和 source 判断页面类型
    if (type == AiCartoonVideoManagementPageType.normal) {
      return "myworks_list_novel_tweets_video_works";
    } else if (source == EntranceSource.explosive) {
      return "myworks_list_explosive_video_works";
    } else if (source == EntranceSource.shortPlay) {
      return "myworks_list_short_drama_video_works";
    } else {
      return "myworks_list_intelligent_hybrid_cutting_video_works";
    }
  }

  @override
  Widget build(BuildContext context) {
    byDebugPrint("---AiCartoonVideoManagementListViewCell");
    final status = AiCartoonVideoStatusExt.fromRawValue(bean.status);

    bool showCommonBg =
        status != AiCartoonVideoStatus.finished &&
        status != AiCartoonVideoStatus.failed &&
        status != AiCartoonVideoStatus.deleted;

    bool showFaildBg =
        status == AiCartoonVideoStatus.failed ||
        status == AiCartoonVideoStatus.deleted;

    String mode = bean.isAutoVideo == 1 ? "自动模式" : "手动模式";

    final videosEditing = context
        .select<AiCartoonVideoManagementProvider, bool>(
          (value) => value.videosEditing,
        );

    final selectedVideoIdxs = context
        .select<AiCartoonVideoManagementProvider, List<int>>(
          (value) => value.selectedVideoIdxs,
        );
    final selected = selectedVideoIdxs.contains(index);
    final updateAt = ByCommonUtils.timestamp2DatetimeString(
      bean.updateAt * 1000,
    );
    final timeCops = updateAt.split(" ");

    byDebugPrint("$selectedVideoIdxs----selected:$selected");

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // ByNavRouterUtils.push(context, const AiVideoGeneratingPage());
        // return;
        if (videosEditing) {
          context
              .read<AiCartoonVideoManagementProvider>()
              .updateSelectedVideoIdxsWithIndex(index);
        } else {
          if (status == AiCartoonVideoStatus.finished) {
            // 上报点击埋点
            String pageTag = _getPageTag();
            ByNavigatorUtil.reportDataPoint(
              pageTag: pageTag,
              operateType: "click",
              funcDetailTag: bean.id.toString(),
              funcDetailImg: bean.imgUrl,
            );
            ByNavRouterUtils.push(
              context,
              AiCartoonVideoPreviewPage(
                videoQueryType: videoQueryType,
                videoBean: bean,
                provider3: context.read<AiCartoonVideoManagementProvider>(),
                source: source,
              ),
            );
          } else if (status == AiCartoonVideoStatus.videoGenerating) {
            ByNavRouterUtils.push(context, const AiVideoGeneratingPage());
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
                ),
              ),
            if (showFaildBg)
              Positioned.fill(
                child: Image.asset(
                  "assets/ai/ai_cartoon_video_bg_faild.png",
                  fit: BoxFit.cover,
                ),
              ),
            if (status == AiCartoonVideoStatus.finished)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: bean.imgUrl,
                  fit: BoxFit.cover,
                ),
              ),
            if (status == AiCartoonVideoStatus.videoGenerating)
              Positioned.fill(
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    ByWidgetsUtil.activityIndicator(
                      color: const Color(0xFFFFFFFF),
                    ),
                    // RotatingWidget(
                    //   duration: 2,
                    //   child: Image.asset(
                    //     "assets/ai/clip/ai_clip_video_generating.png",
                    //     width: 30.w,
                    //     height: 30.w,
                    //   ),
                    // ),
                    SizedBox(height: 40.h),
                    ByWidgetsUtil.commonText(
                      text: "视频生成中...",
                      textColor: Colors.white,
                      fontSize: 14.sp,
                    ),
                    SizedBox(height: 30.h),
                    //刷新进度-短剧
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
                              .read<AiCartoonVideoManagementProvider>()
                              .resetPages();
                          context
                              .read<AiCartoonVideoManagementProvider>()
                              .refresh();
                          context
                              .read<AiCartoonVideoManagementProvider>()
                              .loadVideoList(
                                videoQueryType: videoQueryType,
                                source: source ?? EntranceSource.normal,
                              );
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
                    ),
                  ],
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 60.h,
              child: ByWidgetsUtil.gradientBgContainer(
                borderRadius: 0,
                padding: EdgeInsets.zero,
                gradient: ByColorUtil.lineareGradient(
                  colorStart: const Color(0xFF000000).withOpacity(0.8),
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
                          text: timeCops.isNotEmpty ? timeCops[0] : "",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.normal,
                          textColor: Colors.white,
                        ),
                        const Spacer(),
                        ByWidgetsUtil.commonText(
                          text: timeCops.length > 1 ? timeCops[1] : "",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.normal,
                          textColor: Colors.white,
                        ),
                        SizedBox(width: 10.w),
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
                                isRecovery: true,
                                bean: bean,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            if (status == AiCartoonVideoStatus.failed)
              Positioned.fill(
                child: Column(
                  children: [
                    SizedBox(height: 32.h),
                    ByWidgetsUtil.commonText(
                      fontSize: 14.sp,
                      text: "生成失败积分已退回",
                      textColor: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 40.h),
                    Image.asset(
                      "assets/ai/ai_cartoon_video_faild.png",
                      width: 32.w,
                      height: 32.h,
                      fit: BoxFit.contain,
                    ),
                    const Spacer(),
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
                              MultiProvider(
                                providers: [
                                  ChangeNotifierProvider(
                                    create: (context) => clipProvider,
                                  ),
                                  ChangeNotifierProvider(
                                    create: (BuildContext context) =>
                                        AiMaterialProvider(),
                                  ),
                                  ChangeNotifierProvider(
                                    create: (BuildContext context) =>
                                        AiClipOpeningProvider(),
                                  ),
                                ],
                                child: const AiClipPage(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
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
                ),
              ),
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
                ),
              ),
            if (videosEditing &&
                [
                  AiCartoonVideoStatus.finished,
                  AiCartoonVideoStatus.failed,
                ].contains(status))
              Positioned(
                right: 10.w,
                top: 10.h,
                child: Image.asset(
                  "assets/login/mywork_cell_${selected ? "selected" : "unselected"}.png",
                  width: 24.w,
                  height: 24.h,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
