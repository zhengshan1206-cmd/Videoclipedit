import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_loading_widget.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/v2/aiOralVideos/beans/ai_oral_video_item_bean.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_video_management_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_videos_downoad_dialog.dart';
import 'package:video_clip_edit/v2/aiOralVideos/widgets/ai_oral_video_management_list_view.dart';

enum ManagementRecord {
  ///数字人
  aiOral,

  ///AI漫剧
  aiAnime,
}

class AiOralVideoManagementPage extends StatefulWidget {
  const AiOralVideoManagementPage({
    super.key,
    this.recordType = ManagementRecord.aiOral,
  });

  final ManagementRecord recordType;

  @override
  State<AiOralVideoManagementPage> createState() =>
      _AiOralVideoManagementPageState();
}

class _AiOralVideoManagementPageState extends State<AiOralVideoManagementPage> {
  final tips =
      "1、当前生成任务数量较多，预计十分钟后完成。\n2、内容由AI生成仅供参考，禁止利用功能从事违法活动。\n3、作品只保留7天请及时保存到相册。";

  @override
  void initState() {
    super.initState();
    // 上报页面进入埋点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pageTag = widget.recordType == ManagementRecord.aiAnime
          ? "myworks_list_anime_works"
          : "myworks_list_digital_human_works";
      ByNavigatorUtil.reportDataPoint(
        pageTag: pageTag,
        operateType: "view",
        funcDetailTag: "",
        funcDetailImg: "",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRefreshing = context.select<AiOralVideoManagementProvider, bool>(
      (p) => p.isRefreshing,
    );
    return Scaffold(
        appBar: _buildAppBar(context),
        backgroundColor: ByColorUtil.CommonPageBgColor,
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              EasyRefresh(
                refreshOnStart: true,
                onRefresh: () {
                  _loadVideos(reset: true);
                },
                onLoad: _loadVideos,
                canRefreshAfterNoMore: true,
                canLoadAfterNoMore: false,
                child: VideoManagementView(
                  tips: tips,
                  recordType: widget.recordType,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottmBar(context),
              ),
              if (isRefreshing)
                Positioned.fill(
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
                ),
            ],
          ),
        ));
  }

  _buildBottmBar(BuildContext context) {
    final provider = context.read<AiOralVideoManagementProvider>();
    return Offstage(
      offstage: !context
          .select<AiOralVideoManagementProvider, bool>((p) => p.videosEditing),
      child: PhysicalModel(
        color: Colors.black,
        elevation: 0,
        child: Container(
          height: 66.h,
          width: double.infinity,
          color: ByColorUtil.WhiteColor,
          alignment: Alignment.center,
          child: SizedBox(
            height: 44.h,
            child: Row(
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
                                type: widget.recordType,
                                onSuccess: () {
                                  provider.resetPages();
                                  provider.updateSelectAllStatus(false);
                                  provider.loadVideoList(
                                      type: widget.recordType);
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
                              video.videoUrl.isNotEmpty)
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
          ),
        ),
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return ByWidgetsUtil.appBar(
        context: context, title: "视频管理", actions: _buildActions(context));
  }

  List<Widget> _buildActions(BuildContext context) {
    final provider = context.read<AiOralVideoManagementProvider>();
    final worksEditing = context
        .select<AiOralVideoManagementProvider, bool>((p) => p.videosEditing);
    final selectAll =
        context.select<AiOralVideoManagementProvider, bool>((p) => p.selectAll);
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
            .select<AiOralVideoManagementProvider, List<AiOralVideotemBean>>(
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
    final provider = context.read<AiOralVideoManagementProvider>();
    if (reset) {
      provider.resetPages();
    }
    provider.loadVideoList(type: widget.recordType);
  }
}

class VideoManagementView extends StatelessWidget {
  const VideoManagementView({
    super.key,
    required this.tips,
    this.recordType,
  });

  final String tips;
  final ManagementRecord? recordType;

  @override
  Widget build(BuildContext context) {
    final List<AiOralVideotemBean> videoRecordBeans =
        context.select<AiOralVideoManagementProvider, List<AiOralVideotemBean>>(
      (p) => p.videoRecordBeans,
    );
    final times = context.select<AiOralVideoManagementProvider, int>(
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
          // SliverPadding(
          //   padding: EdgeInsets.only(
          //     left: 12.w,
          //     right: 12.w,
          //     bottom: ByScreenUtils.bottomSafeHeight,
          //   ),
          //   sliver: const SliverToBoxAdapter(
          //     child: AiOralVideoManagementListView(),
          //   ),
          // ),
          AiOralVideoManagementListView(
            recordType: recordType,
          ),
          SliverToBoxAdapter(
              child: SizedBox(height: ByScreenUtils.bottomSafeHeight)),
        ],
      ),
    );
  }
}
