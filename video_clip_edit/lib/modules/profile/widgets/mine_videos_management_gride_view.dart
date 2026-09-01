import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_videos_management_provider.dart';
import 'package:video_clip_edit/modules/profile/widgets/mine_replica_video_management_list_view.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/video_extraction_detail_page.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_datetime_ext.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/v2/aiOralVideos/ai_oral_video_preview_page.dart';
import 'package:video_clip_edit/v2/aiVideo/models/ai_video_generation_model.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_video_item_bean.dart';
import 'package:video_clip_edit/modules/tool_box/beans/extraction_record_bean.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/ai_video_preview_page.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/new_ai_video_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_record_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_video_management_list_view.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_videos_single_page_provider.dart';
import 'package:video_clip_edit/modules/profile/widgets/mine_video_management_list_view_cell.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_video_provider.dart';

enum MineVideoType {
  aiClip(1),
  aiTweets(2),
  oral(3),
  textToVideo(4),
  imgToVideo(5),
  embraceVideo(6),
  hot(7),
  playPromote(8),
  novelPromote(9);

  final int rawValue;
  const MineVideoType(this.rawValue);

  static MineVideoType fromRawValue(int rawValue) {
    switch (rawValue) {
      case 1:
        return aiClip;
      case 2:
        return aiTweets;
      case 3:
        return oral;
      case 4:
        return textToVideo;
      case 5:
        return imgToVideo;
      case 6:
        return embraceVideo;
      case 7:
        return hot;
      case 8:
        return playPromote;
      case 9:
        return novelPromote;
      default:
        return aiClip;
    }
  }
}

class MineVideosManagementGrideView extends StatelessWidget {
  const MineVideosManagementGrideView({
    super.key,
    required this.index,
    required this.type,
  });

  final int index;
  final MineVideoType type;
  @override
  Widget build(BuildContext context) {
    switch (type) {
      case MineVideoType.aiClip:
      case MineVideoType.aiTweets:
      case MineVideoType.playPromote:
      case MineVideoType.novelPromote:
        return _buildTweetsVideoList(context);
      case MineVideoType.oral:
        return _buildOralVideoList(context,type);
      case MineVideoType.textToVideo:
      case MineVideoType.imgToVideo:
      case MineVideoType.embraceVideo:
        return _buildDynamicVideoList(context,type);
      case MineVideoType.hot:
        return _buildHotReplicaVideoList(context,type: type);
      // case MineVideoType.playPromote:
      //   return _buildExtractVideoList(context);
      default:
        return const SizedBox();
    }
  }

  Widget _buildExtractVideoList(BuildContext context) {
    final List<ExtractionRecordBean> videoRecordBeans = context
        .select<MineVideosSinglePageProvider, List<ExtractionRecordBean>>(
      (p) => p.videoExtractBeans,
    );

    final loadTimes = context
        .select<MineVideosSinglePageProvider, int>((value) => value.times);
    final showEmptyView = loadTimes > 0 && videoRecordBeans.isEmpty;
    return showEmptyView
        ? ByWidgetsUtil.commonListNoDataView()
        : GridView.builder(
            itemCount: videoRecordBeans.length,
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              bottom: 66.h + ByScreenUtils.bottomSafeHeight,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) => ExtractionTaskView(
              myWorkBean: videoRecordBeans[index],
            ),
          );
  }

  Widget _buildDynamicVideoList(BuildContext context,  MineVideoType type,) {
    final List<AiVideoGenerationTaskModel> videoRecordBeans = context
        .select<MineVideosSinglePageProvider, List<AiVideoGenerationTaskModel>>(
      (p) => p.dynamicRecordBeans,
    );

    final loadTimes = context
        .select<MineVideosSinglePageProvider, int>((value) => value.times);
    final showEmptyView = loadTimes > 0 && videoRecordBeans.isEmpty;
    return showEmptyView
        ? ByWidgetsUtil.commonListNoDataView()
        : GridView.builder(
            itemCount: videoRecordBeans.length,
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              bottom: 66.h + ByScreenUtils.bottomSafeHeight,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 17 / 25,
            ),
            itemBuilder: (context, index) =>
                MineDynamicVideoManagementListViewCell(
              index: index,
              bean: videoRecordBeans[index],
                  type: type,
            ),
          );
  }

  Widget _buildOralVideoList(BuildContext context,MineVideoType type) {
    List<AiOralVideotemBean> videoRecordBeans =
        context.select<MineVideosSinglePageProvider, List<AiOralVideotemBean>>(
      (value) => value.oralVideoRecordBeans,
    );
    final loadTimes = context
        .select<MineVideosSinglePageProvider, int>((value) => value.times);
    final showEmptyView = loadTimes > 0 && videoRecordBeans.isEmpty;
    return showEmptyView
        ? ByWidgetsUtil.commonListNoDataView()
        : GridView.builder(
            itemCount: videoRecordBeans.length,
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              bottom: 66.h + ByScreenUtils.bottomSafeHeight,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 17 / 25,
            ),
            itemBuilder: (context, index) =>
                MineOralVideoManagementListViewCell(
              index: index,
              bean: videoRecordBeans[index],
                  type: type,
            ),
          );
  }

  Widget _buildTweetsVideoList(BuildContext context) {
    List<AiCartoonVideoRecordBean> videoRecordBeans = context
        .select<MineVideosSinglePageProvider, List<AiCartoonVideoRecordBean>>(
      (value) => value.videoRecordBeans,
    );
    final loadTimes = context
        .select<MineVideosSinglePageProvider, int>((value) => value.times);
    final showEmptyView = loadTimes > 0 && videoRecordBeans.isEmpty;

    return showEmptyView
        ? ByWidgetsUtil.commonListNoDataView()
        : GridView.builder(
            itemCount: videoRecordBeans.length,
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              bottom: 66.h + ByScreenUtils.bottomSafeHeight,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 17 / 25,
            ),
            itemBuilder: (context, index) => MineVideoManagementListViewCell(
              index: index,
              bean: videoRecordBeans[index],
              type: type,
            ),
          );
  }

  Widget _buildHotReplicaVideoList(BuildContext context,{required MineVideoType type,}) {
    return  MineReplicaVideoManagementListView(type: type,);
    //   List<AiCartoonVideoRecordBean> hotRecordBeans = context
    //       .select<MineVideosSinglePageProvider, List<AiCartoonVideoRecordBean>>(
    //     (value) => value.hotRecordBeans,
    //   );
    //   final loadTimes = context
    //       .select<MineVideosSinglePageProvider, int>((value) => value.times);
    //   final showEmptyView = loadTimes > 0 && hotRecordBeans.isEmpty;

    //   return showEmptyView
    //       ? ByWidgetsUtil.commonListNoDataView()
    //       : GridView.builder(
    //           itemCount: hotRecordBeans.length,
    //           padding: EdgeInsets.only(
    //             left: 12.w,
    //             right: 12.w,
    //             bottom: 66.h + ByScreenUtils.bottomSafeHeight,
    //           ),
    //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //             crossAxisCount: 2,
    //             mainAxisSpacing: 10.h,
    //             crossAxisSpacing: 10.w,
    //             childAspectRatio: 17 / 25,
    //           ),
    //           itemBuilder: (context, index) => MineVideoManagementHotListViewCell(
    //             index: index,
    //             bean: hotRecordBeans[index],
    //             type: type,
    //           ),
    //         );
  }
}

class ExtractionTaskView extends StatefulWidget {
  final ExtractionRecordBean myWorkBean;
  const ExtractionTaskView({
    super.key,
    required this.myWorkBean,
  });

  @override
  State<ExtractionTaskView> createState() => _ExtractionTaskViewState();
}

class _ExtractionTaskViewState extends State<ExtractionTaskView> {
  bool fileExists = true;

  @override
  void initState() {
    super.initState();

    _checkVideoExists();
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = widget.myWorkBean.content?.coverUrl ?? "";
    return GestureDetector(
      onTap: () {
        if (!fileExists) {
          BotToast.showText(text: "视频不存在");
          return;
        }
        ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider.value(
              value: VideoExtractionProvider(),
              child: VideoExtractionDetailsPage(
                fileName: widget.myWorkBean.shareUrlMd5,
              ),
            ));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: Stack(
          children: [
            Positioned.fill(
              child: coverUrl.isEmpty
                  ? Container()
                  : CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: coverUrl,
                    ),
            ),
            Positioned.fill(
              child: Offstage(
                offstage: fileExists,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/mine/work_failed_bg.png"),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      width: 82.w,
                      height: 82.w,
                      fit: BoxFit.contain,
                      "assets/mine/work_failed.png",
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Offstage(
                offstage: true,
                child: Container(
                  alignment: Alignment.center,
                  color: ByColorUtil.WhiteColor.withOpacity(0.5),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 90.w,
                      height: 32.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: ByColorUtil.LoginBtnBgColor,
                      ),
                      child: Text(
                        "继续编辑",
                        style: TextStyle(
                          color: ByColorUtil.WhiteColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Offstage(
                offstage: !fileExists,
                child: Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: Image.asset("assets/home/icon_audio_play.png"),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10.w,
              bottom: 5.w,
              child: Text(
                widget.myWorkBean.createAt.formattedTime(),
                style: TextStyle(
                  color: ByColorUtil.WhiteColor,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Positioned.fill(
              child: Offstage(
                offstage: true,
                child: Container(
                  color: const Color(0xFFE6E9EB),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(
                        color: const Color(0xFF0E1840),
                        radius: 16.w,
                      ),
                      SizedBox(height: 30.h),
                      ByWidgetsUtil.commonText(
                          text: "去重中...",
                          textColor:
                              ByColorUtil.CommonTextColor.withOpacity(0.5))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _checkVideoExists() async {
    final fileName = "${widget.myWorkBean.shareUrlMd5}.mp4";
    final fileCachePath =
        await ByDownloadUtil.videoCachePathFromFileName(fileName);
    final fileCache = File(fileCachePath);
    final exists = await fileCache.exists();
    if (!exists) {
      setState(() {
        fileExists = false;
      });
      return false;
    }
    return true;
  }
}

class MineOralVideoManagementListViewCell extends StatelessWidget {
  const MineOralVideoManagementListViewCell({
    super.key,
    required this.index,
    required this.bean,
    required this.type,
  });

  final int index;
  final AiOralVideotemBean bean;
  final MineVideoType type;

  @override
  Widget build(BuildContext context) {
    final status = AiCartoonVideoStatusExt.fromRawValue(bean.status);

    bool showCommonBg = status != AiCartoonVideoStatus.finished &&
        status != AiCartoonVideoStatus.failed;

    bool showFaildBg = status == AiCartoonVideoStatus.failed;

    final videosEditing = context.select<MineVideosManagementProvider, bool>(
        (value) => value.videosEditing);

    final selectedVideoIdxs =
        context.select<MineVideosSinglePageProvider, List<int>>(
            (value) => value.selectedVideoIdxs);
    final selected = selectedVideoIdxs.contains(index);

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
                context, AiOralVideoPreviewPage(videoUrl: bean.videoUrl,id: bean.id,
              provider3: context.read<MineVideosSinglePageProvider>(),
            type:type
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

class MineDynamicVideoManagementListViewCell extends StatelessWidget {
  const MineDynamicVideoManagementListViewCell({
    super.key,
    required this.index,
    required this.bean,
    required this.type,
  });

  final int index;
  final AiVideoGenerationTaskModel bean;
  final MineVideoType type;

  @override
  Widget build(BuildContext context) {
    byDebugPrint("---AiVideoManagementListViewCell");
    final status = bean.status;

    bool showCommonBg = status != AiVideoStatus.done &&
        status != AiVideoStatus.failed &&
        bean.isDeleted;

    bool showFaildBg = status == AiVideoStatus.failed || bean.isDeleted;

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
          if (status == AiVideoStatus.done) {
            ByNavRouterUtils.push(context, AiVideoPreviewPage(videoBean: bean,provider2: context.read<MineVideosSinglePageProvider>(),type:type ,));
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
                  SizedBox(height: 75.h),
                  ByWidgetsUtil.activityIndicator(color: Colors.white),
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
                        Get.toNamed(Routes.aiDynamicVideoPage, arguments: bean);
                        // final provider = AiVideoProvider();
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
