import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/widgets/refresh/by_refresh.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/data/model/folk/story_video_bean.dart';
import 'package:video_clip_edit/widgets/common/multi_status_view.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/v2/aiCreate/views/folk_story_steps_page.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/videos_manageent_bar.dart';
import 'package:video_clip_edit/v2/aiCreate/views/story_video_preview_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_videos_downoad_dialog.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/video_management_controller.dart';
import 'package:video_clip_edit/utils/comon/by_loading_widget.dart';

import '../../../routes/app_pages.dart';

class FolkStoyVideoManagementPage extends StatefulWidget {
  const FolkStoyVideoManagementPage({
    super.key,
  });

  @override
  State<FolkStoyVideoManagementPage> createState() =>
      _FolkStoyVideoManagementPageState();
}

class _FolkStoyVideoManagementPageState
    extends State<FolkStoyVideoManagementPage> {
  /// 视频管理控制器
  late final controller = Get.put(VideoManagementController());

  final tips =
      "1、当前生成任务数量较多，预计十分钟后完成。\n2、内容由AI生成仅供参考，禁止利用功能从事违法活动。\n3、作品只保留7天请及时保存到相册。";

  @override
  void initState() {
    super.initState();
    controller.loadFolkStoryList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: _buildAppBar(context),
          backgroundColor: ByColorUtil.CommonPageBgColor,
          body: Stack(
            children: [
              Positioned.fill(child: GetBuilder<VideoManagementController>(
                builder: (VideoManagementController controller) {
                  return BYRefresh.instance(
                    hasMore: true,
                    hasBefore: true,
                    controller: controller.refreshController,
                    onRefresh: () {
                      controller.loadFolkStoryList(isRefresh: true);
                    },
                    onLoad: () {
                      controller.loadFolkStoryList(isRefresh: false);
                    },
                    child: Obx(() => MultiStatusView(
                      backgroundColor: Colors.transparent,
                      currentStatus: controller.multiStatus.value,
                      emptyActionType: EmptyActionType.text,
                      hasAppBar: false,
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 12.w,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: ByWidgetsUtil.commonTipsBar2(
                                  title: "温馨提示", tips: tips),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.only(
                                left: 12.w, right: 12.w, bottom: 10.h),
                            sliver: Obx(() => SliverGrid.builder(
                                  itemCount: controller.videoRecordBeans.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 10.h,
                                    crossAxisSpacing: 10.w,
                                    childAspectRatio: 17 / 24,
                                  ),
                                  itemBuilder: (context, index) =>
                                      FolkStoryVideoManagementListViewCell(
                                    bean: controller.videoRecordBeans[index],
                                  ),
                                )),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                                height: ByScreenUtils.bottomSafeHeight),
                          ),
                        ],
                      ),
                    )),
                  );
                },
              )),

              /// 底部管理栏
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottmBar(context),
              ),
            ],
          ),
        ),

        /// 刷新中遮罩
        GetX<VideoManagementController>(
          builder: (controller) => controller.isRefreshing.value
              ? Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: ByLoadingWidget(
                        message: "刷新中...",
                        messageSize: 14,
                        backgroundColor: Colors.transparent,
                        messageColor: ByColorUtil.WhiteColor,
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  _buildBottmBar(BuildContext context) {
    return Obx(() => Offstage(
          offstage: controller.videosEditing.value == false,
          child: VideosManagementBar(
            onCancel: () {
              controller.videosEditing.value = false;
            },
            onDelete: () {
              final ids = controller.selectedVideoIdxs;
              if (ids.isEmpty) {
                BotToast.showText(text: "请选择要删除的视频");
                return;
              }
              showDialog(
                context: context,
                builder: (ctx) {
                  return CommonDialog(
                    reverse: false,
                    maxLine: 10,
                    contents: "请确认是否删除，删除后将不可回恢复，请谨慎操作",
                    confirmBtnTitle: "删除",
                    confirmCallback: () {
                      controller.deleteVideos(
                        ids,
                        onSuccess: () {
                          controller.selectAll.value = false;
                          controller.selectedVideoIdxs.clear();
                          controller.loadFolkStoryList(isRefresh: true);
                        },
                      );
                    },
                  );
                },
              );
            },
            onDownload: () async {
              if (await ByPermissionUtils.storage() == false) return;

              // 检查选中的视频是否都有有效的链接
              final selectedVideos = controller.selectedVideoIdxs
                  .map((id) =>
                      controller.videoRecordBeans.firstWhere((e) => e.id == id))
                  .where((video) =>
                      video.videoUrl != null && video.videoUrl!.isNotEmpty)
                  .toList();

              if (selectedVideos.isEmpty) {
                BotToast.showText(text: "请选择已生成的视频进行下载！");
                return;
              }

              showDialog(
                context: context,
                builder: (c) {
                  return AiVideosDownoadDialog(
                    contents: "",
                    maxLine: 10,
                    cancelBtnTitle: "取消",
                    confirmBtnTitle: "确定",
                    confirmCallback: () {},
                    videoUrls:
                        selectedVideos.map((video) => video.videoUrl).toList(),
                  );
                },
              );
            },
          ),
        ));
  }

  _buildAppBar(BuildContext context) {
    return ByWidgetsUtil.appBar(
        context: context, title: "视频管理", actions: _buildActions(context));
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      Obx(() {
        final worksEditing = controller.videosEditing.value;
        if (worksEditing) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.selectOrDeselectAllVideos();
              controller.selectAll.value = !controller.selectAll.value;
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  controller.selectAll.value
                      ? "assets/home/mat_icon_selected.png"
                      : "assets/home/mat_icon_unselected.png",
                  width: 16.w,
                  height: 16.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 6.w),
                ByWidgetsUtil.commonText(
                  text: controller.selectAll.value ? "取消全选" : "全选",
                  fontSize: 14.sp,
                ),
                SizedBox(width: 12.w),
              ],
            ),
          );
        }
        return Offstage(
          offstage: controller.videoRecordBeans.isEmpty,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              /// 更新编辑状态
              controller.videosEditing.value = true;
            },
            child: Container(
              height: 40.h,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: ByWidgetsUtil.commonText(
                text: "管理",
                fontSize: 14.sp,
              ),
            ),
          ),
        );
      })
    ];
  }
}

class FolkStoryVideoManagementListViewCell extends StatelessWidget {
  const FolkStoryVideoManagementListViewCell({
    super.key,
    required this.bean,
  });

  final FolkStoryVideoBean bean;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoManagementController>();
    final status = FolkStoryVideoStatus.fromRawValue(bean.status); //bean.status

    bool showCommonBg = ![
      FolkStoryVideoStatus.failed,
      FolkStoryVideoStatus.finished
    ].contains(status);

    bool showFaildBg = status == FolkStoryVideoStatus.failed;

    return Obx(() {
      final canSelect = [
        FolkStoryVideoStatus.finished,
        FolkStoryVideoStatus.failed,
      ].contains(status);
      final videosEditing = controller.videosEditing.value;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (videosEditing) {
            if (canSelect) {
              controller.changeSelectedVideoIdxs(bean);
            }
          } else {
            //进入视频详情页
            if (status == FolkStoryVideoStatus.finished) {
              Get.to(() => StoryVideoPreviewPage(
                    videoUrl: bean.videoUrl,
                    id: bean.id,
                  ));
            } else if (status != FolkStoryVideoStatus.failed) {
              //非智能模式进入编辑页
              _gotoVideoEditPage();
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

              /// 构建不同状态的内容
              _buildContentsByStatus(context, status),

              /// 选中/未选中
              if (videosEditing && canSelect)
                Positioned(
                    right: 10.w,
                    top: 10.h,
                    child: Image.asset(
                      "assets/login/mywork_cell_${controller.selectedVideoIdxs.contains(bean.id) ? "selected" : "unselected"}.png",
                      width: 24.w,
                      height: 24.h,
                      fit: BoxFit.contain,
                    )),

              /// 创建时间
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
                            text: bean
                                .createdAt, //ByCommonUtils.timestamp2DatetimeString(bean.createdAt.millisecondsSinceEpoch)
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

              /// 播放按钮
              if (status == FolkStoryVideoStatus.finished)
                Positioned.fill(
                    child: Center(
                  child: Image.asset(
                    "assets/ai/ai_cartoon_video_play.png",
                    width: 40.w,
                    height: 40.h,
                    fit: BoxFit.contain,
                  ),
                )),
            ],
          ),
        ),
      );
    });
  }

  /// 非智能模式进入编辑页
  _gotoVideoEditPage() {
    if (bean.isAuto == 2) {
      Get.toNamed(Routes.stepsPage, arguments: bean.id);
    }
  }

  /// 构建不同状态的内容
  _buildContentsByStatus(BuildContext context, FolkStoryVideoStatus status) {
    if (status == FolkStoryVideoStatus.finished) {
      return Positioned.fill(
          child: CachedNetworkImage(
        imageUrl: bean.cover,
        fit: BoxFit.cover,
      ));
    }

    if ([
      FolkStoryVideoStatus.saved,
      FolkStoryVideoStatus.roleExtracting,
      FolkStoryVideoStatus.roleExtracted,
      FolkStoryVideoStatus.roleDrawing,
    ].contains(status)) {
      return Positioned.fill(child: _buildStatusContents('角色绘制中', false));
    }

    if ([
      FolkStoryVideoStatus.roleDrawn,
    ].contains(status)) {
      return Positioned.fill(child: _buildStatusContents('角色绘制完成', true));
    }

    if ([
      FolkStoryVideoStatus.scenesCreating,
      FolkStoryVideoStatus.scenesCreated,
      FolkStoryVideoStatus.scenesDrawing,
    ].contains(status)) {
      return Positioned.fill(child: _buildStatusContents('分镜绘制中', false));
    }

    if ([
      FolkStoryVideoStatus.scenesDrawn,
    ].contains(status)) {
      return Positioned.fill(child: _buildStatusContents('分镜绘制完成', true));
    }

    if ([
      FolkStoryVideoStatus.videoCreating,
    ].contains(status)) {
      return Positioned.fill(child: _buildStatusContents('视频生成中', false));
    }

    if (status == FolkStoryVideoStatus.failed) {
      return Positioned.fill(
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
      ));
    }

    return Container();
  }

  ///构建状态内部组件
  Widget _buildStatusContents(String statusString, bool canEdit) {
    final controller = Get.find<VideoManagementController>();

    ///智能模式下可编辑步骤为均为不可编辑状态
    if (canEdit && bean.isAuto == 1) {
      canEdit = false;
    }
    return canEdit
        ? Stack(
          children: [
            Positioned.fill(
                    child: Image.asset(
                  "assets/v2/folk/folk_video_cell_bg.png",
                  fit: BoxFit.cover,
                )),
            Positioned.fill(
              child: Column(
              children: [
                SizedBox(height: 65.h),
                // ByWidgetsUtil.fadedSpin(),
                Image.asset(
                  "assets/v2/folk/status_draw_finshed.png",
                  width: 30.w,
                  height: 30.w,
                ),
                SizedBox(height: 15.h),
                ByWidgetsUtil.commonText(
                  text: statusString,
                  textColor: Colors.white,
                  fontSize: 14.sp,
                ),
                SizedBox(height: 23.h),
                SizedBox(
                  height: 28.h,
                  width: 100.w,
                  child: ByWidgetsUtil.commonBtn(
                    title: "继续编辑",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    padding: EdgeInsets.zero,
                    borderRadius: 100,
                    bgColor: ByColorUtil.WhiteColor,
                    textColor: ByColorUtil.CommonTextColor,
                    onClick: () {
                      _gotoVideoEditPage();
                    },
                  ),
                )
              ],
            ),)
          ],
        )
        : Column(
            children: [
              SizedBox(height: 30.h),
              ByWidgetsUtil.fadedSpin(),
              SizedBox(height: 30.h),
              ByWidgetsUtil.commonText(
                text: statusString,
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
                    controller.refreshProgress();
                  },
                ),
              ),
            ],
          );
  }
}
