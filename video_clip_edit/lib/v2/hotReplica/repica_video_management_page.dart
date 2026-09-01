import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_videos_downoad_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_record_bean.dart';
import 'package:video_clip_edit/v2/hotReplica/widgets/replica_video_management_list_view.dart';
import 'package:video_clip_edit/v2/hotReplica/providers/replica_video_management_provider.dart';
import 'package:video_clip_edit/widgets/common/works_management_bottom_bar_shell.dart';

class RepicaVideoManagementPage extends StatefulWidget {
  const RepicaVideoManagementPage({
    super.key,
  });

  @override
  State<RepicaVideoManagementPage> createState() =>
      _AiOralVideoManagementPageState();
}

class _AiOralVideoManagementPageState extends State<RepicaVideoManagementPage> {
  final tips =
      "1、当前生成任务数量较多，预计十分钟后完成。\n2、内容由AI生成仅供参考，禁止利用功能从事违法活动。\n3、作品只保留7天请及时保存到相册。";

  @override
  Widget build(BuildContext context) {
    final editing = context
        .select<ReplicaVideoManagementProvider, bool>((p) => p.videosEditing);
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: EasyRefresh(
                  refreshOnStart: true,
                  onRefresh: () {
                    _loadVideos(reset: true);
                  },
                  onLoad: _loadVideos,
                  canRefreshAfterNoMore: true,
                  canLoadAfterNoMore: false,
                  child: VideoManagementView(tips: tips),
                ),
              ),
              if (editing) _buildBottomBar(context),
            ],
          ),
        ],
      ),
    );
  }

  _buildBottomBar(BuildContext context) {
    final provider = context.read<ReplicaVideoManagementProvider>();
    final rowH = ByScreenUtils.managementBottomActionRowHeight(44.h);
    final barH = ByScreenUtils.managementBottomBarSurfaceHeight(
      scaledBarH: Platform.isAndroid ? 66.h : 80.h,
      actionRowHeight: rowH,
    );
    return WorksManagementBottomBarShell(
      barSurfaceHeight: barH,
      actionRowHeight: rowH,
      materialElevation: 10,
      actionsRow: Row(
              children: [
                SizedBox(
                  width: 12.w,
                ),
                Expanded(
                  child: ByWidgetsUtil.commonBtn(
                    title: "取消",
                    fontSize: 16.sp,
                    borderRadius: 12.w,
                    fontWeight: FontWeight.w600,
                    bgColor: ByColorUtil.CommonTextColor.withOpacity(0.2),
                    textColor: ByColorUtil.WhiteColor,
                    onClick: () {
                      if (provider.videosEditing) {
                        provider.updateWorksEditingState(false);
                        provider.updateSelectAllStatus(false);
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 12.w,
                ),
                Expanded(
                  child: ByWidgetsUtil.commonBtn(
                    title: "删除",
                    fontSize: 16.sp,
                    borderRadius: 12.w,
                    fontWeight: FontWeight.w600,
                    bgColor: const Color(0xFFFF5373),
                    textColor: ByColorUtil.WhiteColor,
                    onClick: () {
                      final ids = provider.selectedVideoIdxs;
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
                              provider.deleteVideos(
                                ids.map((e) {
                                  return provider.videoRecordBeans[e].id;
                                }).toList(),
                                onSuccess: () {
                                  provider.resetPages();
                                  provider.updateSelectAllStatus(false);
                                  provider.loadVideoList(isRefresh: true);
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 12.w,
                ),
                Expanded(
                  child: ByWidgetsUtil.commonBtn(
                    title: " 下载",
                    fontSize: 16.sp,
                    borderRadius: 12.w,
                    fontWeight: FontWeight.w600,
                    textColor: ByColorUtil.WhiteColor,
                    bgColor: ByColorUtil.LoginBtnBgColor,
                    onClick: () async {
                      if (await ByPermissionUtils.storage() == false) return;

                      // 检查选中的视频是否都有有效的链接
                      final selectedVideos = provider.selectedVideoIdxs
                          .map((idx) => provider.videoRecordBeans[idx])
                          .where((video) =>
                              video.videoUrl != null &&
                              video.videoUrl!.isNotEmpty)
                          .toList();

                      if (selectedVideos.isEmpty) {
                        BotToast.showText(text: "请选择已生成的视频进行下载！");
                        return;
                      }

                      showDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (c) {
                          return AiVideosDownoadDialog(
                            contents: "",
                            maxLine: 10,
                            cancelBtnTitle: "取消",
                            confirmBtnTitle: "确定",
                            confirmCallback: () {},
                            videoUrls: selectedVideos
                                .map((video) => video.videoUrl)
                                .toList(),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 12.w,
                ),
              ],
            ),
    );
  }

  _buildAppBar(BuildContext context) {
    return ByWidgetsUtil.appBar(
        context: context, title: "视频管理", actions: _buildActions(context));
  }

  List<Widget> _buildActions(BuildContext context) {
    final provider = context.read<ReplicaVideoManagementProvider>();
    final worksEditing = context
        .select<ReplicaVideoManagementProvider, bool>((p) => p.videosEditing);
    final selectAll = context
        .select<ReplicaVideoManagementProvider, bool>((p) => p.selectAll);
    if (worksEditing) {
      return [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            provider.updateSelectAllStatus(!selectAll);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                selectAll
                    ? "assets/home/mat_icon_selected.png"
                    : "assets/home/mat_icon_unselected.png",
                width: 16.w,
                height: 16.h,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 6.w),
              ByWidgetsUtil.commonText(
                text: selectAll ? "取消全选" : "全选",
                fontSize: 14.sp,
              ),
              SizedBox(width: 12.w),
            ],
          ),
        )
      ];
    }

    /// 管理按钮
    return [
      Offstage(
        offstage: context
            .select<ReplicaVideoManagementProvider,
                List<AiCartoonVideoRecordBean>>(
              (p) => p.videoRecordBeans,
            )
            .isEmpty,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            /// 更新编辑状态
            provider.updateWorksEditingState(true);
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
      )
    ];
  }

  FutureOr _loadVideos({
    bool reset = false,
  }) {
    final provider = context.read<ReplicaVideoManagementProvider>();
    if (reset) {
      provider.resetPages();
    }
    provider.loadVideoList();
  }
}

class VideoManagementView extends StatelessWidget {
  const VideoManagementView({
    super.key,
    required this.tips,
  });

  final String tips;

  @override
  Widget build(BuildContext context) {
    final List<AiCartoonVideoRecordBean> videoRecordBeans = context
        .select<ReplicaVideoManagementProvider, List<AiCartoonVideoRecordBean>>(
      (p) => p.videoRecordBeans,
    );
    final times = context.select<ReplicaVideoManagementProvider, int>(
      (p) => p.times,
    );
    if (videoRecordBeans.isEmpty && times > 0) {
      return ByWidgetsUtil.commonListNoDataView();
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(
              vertical: 8.h,
              // horizontal: 12.w,
            ),
            sliver: SliverToBoxAdapter(
              child: ByWidgetsUtil.commonTipsBar2(
                title: "温馨提示",
                tips: tips,
              ),
            ),
          ),
          const ReplicaVideoManagementListView(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: ByScreenUtils.bottomSafeHeight,
            ),
          ),
        ],
      ),
    );
  }
}
