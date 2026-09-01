import 'dart:async';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_loading_widget.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_img_details_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_work_management_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_draw_management_list_view.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_imgs_downoad_dialog.dart';
import 'package:video_clip_edit/widgets/common/works_management_bottom_bar_shell.dart';

class AiDrawManagementPage extends StatefulWidget {
  const AiDrawManagementPage({super.key});

  @override
  State<AiDrawManagementPage> createState() => _AiDrawManagementPageState();
}

class _AiDrawManagementPageState extends State<AiDrawManagementPage> {
  final tips =
      "1、当前生成任务数量较多，预计十分钟后完成。\n2、内容由AI生成仅供参考，禁止利用功能从事违法活动。\n3、作品只保留7天请及时保存到相册。";

  @override
  void initState() {
    super.initState();

    // _loadWorkList();
    // 上报页面进入埋点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ByNavigatorUtil.reportDataPoint(
        pageTag: "myworks_list_intelligent_draw_works",
        operateType: "view",
        funcDetailTag: "",
        funcDetailImg: "",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRefreshing = context.select<AiDrawWorkManagementProvider, bool>(
      (p) => p.isRefreshing,
    );
    final editing = context
        .select<AiDrawWorkManagementProvider, bool>((p) => p.worksEditing);
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
                      _loadImages(reset: true);
                    },
                    onLoad: _loadImages,
                    canRefreshAfterNoMore: true,
                    canLoadAfterNoMore: false,
                    child: AiDrawManagmentView(tips: tips),
                  ),
                ),
                if (editing) _buildBottmBar(context),
              ],
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
        ));
  }

  _buildBottmBar(BuildContext context) {
    final provider = context.read<AiDrawWorkManagementProvider>();
    final rowH = ByScreenUtils.managementBottomActionRowHeight(44.h);
    final barH = ByScreenUtils.managementBottomBarSurfaceHeight(
      scaledBarH: Platform.isAndroid ? 66.h : 86.h,
      actionRowHeight: rowH,
    );
    return WorksManagementBottomBarShell(
      barSurfaceHeight: barH,
      actionRowHeight: rowH,
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
                        if (provider.worksEditing) {
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
                        final ids = provider.selectedWorkIdxs;
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
                                provider.deletePictures(
                                  ids.map((e) {
                                    return provider.workRecordBeans[e].id;
                                  }).toList(),
                                  onSuccess: () {
                                    provider.resetPages();
                                    provider.updateSelectAllStatus(false);
                                    provider.loadPictureList();
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
                      title: "保存",
                      fontSize: 16.sp,
                      borderRadius: 12.w,
                      fontWeight: FontWeight.w600,
                      textColor: ByColorUtil.WhiteColor,
                      bgColor: ByColorUtil.LoginBtnBgColor,
                      onClick: () async {
                        final status = await ByPermissionUtils.storage();
                        if (!status) return;
                        final ids = provider.selectedWorkIdxs;
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
                              imgUrls: ids
                                  .map(
                                      (e) => provider.workRecordBeans[e].picUrl)
                                  .toList(),
                            );
                          },
                        );

                        // for (var id in ids) {
                        //   EasyLoading.show(status: "保存第${ids.indexOf(id) + 1}张");
                        //   await ByDownloadUtil.saveNetwrokImage(
                        //       provider.workRecordBeans[id].picUrl,
                        //       showLoading: false);
                        //   EasyLoading.dismiss();
                        // }
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
        context: context, title: "我的创作", actions: _buildActions(context));
  }

  List<Widget> _buildActions(BuildContext context) {
    final provider = context.read<AiDrawWorkManagementProvider>();
    final worksEditing = context
        .select<AiDrawWorkManagementProvider, bool>((p) => p.worksEditing);
    final selectAll =
        context.select<AiDrawWorkManagementProvider, bool>((p) => p.selectAll);
    if (worksEditing) {
      return [
        Offstage(
          offstage: context
              .select<AiDrawWorkManagementProvider, List<AiDrawImgDetailsBean>>(
                (p) => p.workRecordBeans,
              )
              .isEmpty,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              provider.updateSelectAllStatus(!selectAll);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  selectAll
                      ? "assets/login/checked.png"
                      : "assets/login/uncheck_all.png",
                  width: 15.w,
                  height: 15.h,
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
          ),
        )
      ];
    }

    /// 管理按钮
    return [
      GestureDetector(
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
      )
    ];
  }

  void _loadWorkList() {
    context.read<AiDrawWorkManagementProvider>().loadPictureList();
  }

  FutureOr _loadImages({
    bool reset = false,
  }) {
    final provider = context.read<AiDrawWorkManagementProvider>();
    if (reset) {
      provider.resetPages();
    }
    provider.loadPictureList();
  }
}

class AiDrawManagmentView extends StatelessWidget {
  const AiDrawManagmentView({
    super.key,
    required this.tips,
  });

  final String tips;

  @override
  Widget build(BuildContext context) {
    final List<AiDrawImgDetailsBean> videoRecordBeans = context
        .select<AiDrawWorkManagementProvider, List<AiDrawImgDetailsBean>>(
      (p) => p.workRecordBeans,
    );
    final times =
        context.select<AiDrawWorkManagementProvider, int>((p) => p.times);
    if (videoRecordBeans.isEmpty && times > 0) {
      return ByWidgetsUtil.commonNoData();
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
          sliver: const AiDrawManagementSliverListView(),
        ),
      ],
    );
  }
}
