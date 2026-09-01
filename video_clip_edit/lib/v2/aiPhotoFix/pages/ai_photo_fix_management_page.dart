import 'dart:async';
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
import '../../aiSquare/draw/widgets/ai_imgs_downoad_dialog.dart';
import '../models/ai_photo_fix_task_model.dart';
import '../provider/ai_photo_fix_management_provider.dart';
import '_ai_photo_fix_management_list_view.dart';

class AiPhotoFixManagementPage extends StatefulWidget {
  const AiPhotoFixManagementPage({
    required this.type,
    super.key,
  });

  final int type;

  @override
  State<AiPhotoFixManagementPage> createState() =>
      _AiPhotoFixManagementPageState();
}

class _AiPhotoFixManagementPageState extends State<AiPhotoFixManagementPage> {
  final tips = "1、作品只保留7天请及时保存到相册。\n2、可手动下拉刷新查看作品生成状态。";

  @override
  void initState() {
    super.initState();

    /// 延迟1秒加载数据
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (Provider.of<AiPhotoFixManagementProvider>(context, listen: false)
            .videoRecordBeans
            .isEmpty) {
          _loadVideos(reset: true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Stack(
        children: [
          EasyRefresh(
            refreshOnStart: true,
            onRefresh: () {
              _loadVideos(reset: true);
            },
            onLoad: _loadVideos,
            canRefreshAfterNoMore: true,
            canLoadAfterNoMore: false,
            child: VideoManagementView(tips: tips),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottmBar(context),
          ),
        ],
      ),
    );
  }

  _buildBottmBar(BuildContext context) {
    final provider = context.read<AiPhotoFixManagementProvider>();
    return Offstage(
      offstage: !context
          .select<AiPhotoFixManagementProvider, bool>((p) => p.videosEditing),
      child: PhysicalModel(
        color: Colors.black,
        elevation: 10,
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
                        BotToast.showText(text: "请选择要删除的记录");
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
                                  provider.loadVideoList(type: widget.type);
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
                    title: "下载",
                    fontSize: 16.sp,
                    borderRadius: 12.w,
                    fontWeight: FontWeight.w600,
                    textColor: ByColorUtil.WhiteColor,
                    bgColor: ByColorUtil.LoginBtnBgColor,
                    onClick: () async {
                      if (await ByPermissionUtils.storage() == false) return;
                      showDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (c) {
                          return AiImgsDownoadDialog(
                            contents: "",
                            maxLine: 10,
                            cancelBtnTitle: "取消",
                            confirmBtnTitle: "确定",
                            confirmCallback: () {},
                            imgUrls: provider.selectedVideoIdxs
                                .map((idx) =>
                                    provider.videoRecordBeans[idx].imageUrl!)
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
        context: context, title: "生成记录", actions: _buildActions(context));
  }

  List<Widget> _buildActions(BuildContext context) {
    final provider = context.read<AiPhotoFixManagementProvider>();
    final worksEditing = context
        .select<AiPhotoFixManagementProvider, bool>((p) => p.videosEditing);
    final selectAll =
        context.select<AiPhotoFixManagementProvider, bool>((p) => p.selectAll);
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
            .select<AiPhotoFixManagementProvider, List<AiPhotoFixTaskModel>>(
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
    final provider = context.read<AiPhotoFixManagementProvider>();
    if (reset) {
      provider.resetPages();
    }
    provider.loadVideoList(type: widget.type);
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
    final List<AiPhotoFixTaskModel> videoRecordBeans =
        context.select<AiPhotoFixManagementProvider, List<AiPhotoFixTaskModel>>(
      (p) => p.videoRecordBeans,
    );
    final times = context.select<AiPhotoFixManagementProvider, int>(
      (p) => p.times,
    );
    if (videoRecordBeans.isEmpty && times > 0) {
      return ByWidgetsUtil.commonListNoDataView();
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            vertical: 8.h,
            horizontal: 12.w,
          ),
          sliver: SliverToBoxAdapter(
            child: ByWidgetsUtil.commonTipsBar2(
              title: "温馨提示",
              tips: tips,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            bottom: ByScreenUtils.bottomSafeHeight,
          ),
          sliver: AiPhotoFixManagementSliverListView(),
        ),
      ],
    );
  }
}
