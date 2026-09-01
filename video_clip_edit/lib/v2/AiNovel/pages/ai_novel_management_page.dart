import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_clip_edit/main.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';

import '../../../utils/comon/by_nav_router_utils.dart';
import '../../aiSquare/draw/widgets/ai_files_downoad_dialog.dart';
import '../models/ai_novel_generation_model.dart';
import '../providers/ai_novel_management_provider.dart';
import 'ai_novel_management_list_view.dart';

class AiNovelManagementPage extends StatefulWidget {
  const AiNovelManagementPage({
    super.key,
  });

  @override
  State<AiNovelManagementPage> createState() => _AiNovelManagementPageState();
}

class _AiNovelManagementPageState extends State<AiNovelManagementPage> {
  @override
  void initState() {
    super.initState();

    /// 延迟1秒加载数据
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (Provider.of<AiNovelManagementProvider>(context, listen: false)
            .recordBeans
            .isEmpty) {
          _loadNovels(reset: true);
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
              _loadNovels(reset: true);
            },
            onLoad: _loadNovels,
            canRefreshAfterNoMore: true,
            canLoadAfterNoMore: false,
            child: NovelManagementView(tips: ""),
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
    final provider = context.read<AiNovelManagementProvider>();
    return Offstage(
      offstage: !context
          .select<AiNovelManagementProvider, bool>((p) => p.videosEditing),
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
                      final ids = provider.selectedNovelIdxs;
                      if (ids.isEmpty) {
                        BotToast.showText(text: "请选择要删除的创作");
                        return;
                      }
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          return CommonDialog(
                            maxLine: 10,
                            title: "确认删除",
                            contents: "删除内容后无法找回，是否删除？",
                            confirmBtnTitle: "删除",
                            isDanger: true,
                            reverse: true,
                            confirmCallback: () {
                              provider.deleteNovels(
                                ids.map((e) {
                                  return provider.recordBeans[e].id;
                                }).toList(),
                                onSuccess: () {
                                  provider.resetPages();
                                  provider.updateSelectAllStatus(false);
                                  provider.loadNovelList();
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
                    title: "导出",
                    fontSize: 16.sp,
                    borderRadius: 12.w,
                    fontWeight: FontWeight.w600,
                    textColor: ByColorUtil.WhiteColor,
                    bgColor: ByColorUtil.LoginBtnBgColor,
                    onClick: () => _showExportDialog(provider),
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
    final provider = context.read<AiNovelManagementProvider>();
    final worksEditing =
        context.select<AiNovelManagementProvider, bool>((p) => p.videosEditing);
    final selectAll =
        context.select<AiNovelManagementProvider, bool>((p) => p.selectAll);
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
            .select<AiNovelManagementProvider,
                List<AiNovelGenerationTaskModel>>(
              (p) => p.recordBeans,
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

  FutureOr _loadNovels({
    bool reset = false,
  }) {
    final provider = context.read<AiNovelManagementProvider>();
    if (reset) {
      provider.resetPages();
    }
    provider.loadNovelList();
  }

  _showExportDialog(AiNovelManagementProvider provider) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(18),
          ),
        ),
        builder: (BuildContext context) {
          //构建弹框中的内容
          return StatefulBuilder(builder: (c, setBottomSheetState) {
            return Container(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: 24.h,
                    width: double.infinity,
                    child: NavigationToolbar(
                      middle: Text(
                        "选择导出格式",
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset(
                          "assets/login/login_dialog_close.png",
                          width: 12.9.w,
                          height: 12.7.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 19.5.h),
                  Row(
                    children: [
                      Expanded(
                          child: GestureDetector(
                        onTap: () async {
                          ByNavRouterUtils.goBack(context);
                          provider.export(
                            type: "word",
                            onSuccess: (urls) async {
                              final status = await ByPermissionUtils.storage();
                              if (!status) return;

                              final List<String> files = [];
                              await showDialog(
                                context: navigatorKey.currentContext!,
                                builder: (c) {
                                  return AiFilesDownoadDialog(
                                    contents: "",
                                    maxLine: 10,
                                    cancelBtnTitle: "取消",
                                    confirmBtnTitle: "确定",
                                    confirmCallback: () {},
                                    fileUrls: urls,
                                    onSuccess: (index, filePath) async {
                                      files.add(filePath);
                                    },
                                  );
                                },
                              );

                              await Share.shareXFiles(
                                  files.map((e) => XFile(e)).toList(),
                                  text: 'Word Document Shared');
                            },
                          );
                        },
                        child: Image.asset(
                          "assets/ai/aiduihua_dcword.png",
                          width: 170.w,
                          height: 170.h,
                        ),
                      )),
                      Expanded(
                          child: GestureDetector(
                        onTap: () async {
                          ByNavRouterUtils.goBack(context);
                          provider.export(
                            type: "txt",
                            onSuccess: (urls) async {
                              final status = await ByPermissionUtils.storage();
                              if (!status) return;

                              final List<String> files = [];
                              await showDialog(
                                context: navigatorKey.currentContext!,
                                builder: (c) {
                                  return AiFilesDownoadDialog(
                                    contents: "",
                                    maxLine: 10,
                                    cancelBtnTitle: "取消",
                                    confirmBtnTitle: "确定",
                                    confirmCallback: () {},
                                    fileUrls: urls,
                                    onSuccess: (index, filePath) async {
                                      files.add(filePath);
                                    },
                                  );
                                },
                              );

                              await Share.shareXFiles(
                                  files.map((e) => XFile(e)).toList(),
                                  text: 'Word Document Shared');
                            },
                          );
                        },
                        child: Image.asset(
                          "assets/ai/aiduihua_dctxt.png",
                          width: 170.w,
                          height: 170.h,
                        ),
                      ))
                    ],
                  )
                ],
              ),
            );
          });
        },
        context: context);
  }
}

class NovelManagementView extends StatelessWidget {
  const NovelManagementView({
    super.key,
    required this.tips,
  });

  final String tips;

  @override
  Widget build(BuildContext context) {
    final List<AiNovelGenerationTaskModel> videoRecordBeans = context
        .select<AiNovelManagementProvider, List<AiNovelGenerationTaskModel>>(
      (p) => p.recordBeans,
    );
    final times = context.select<AiNovelManagementProvider, int>(
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
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.w),
                color: const Color(0xFF2E54FF).withOpacity(0.1),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/mine/icon_info.png",
                        width: 12.w,
                        height: 12.w,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: ByWidgetsUtil.commonText(
                          text: "文字在云端存储7天，过期无法恢复，请及时保存。",
                          maxLines: 100,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          textColor: const Color(0xFF5A4BF7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            bottom: ByScreenUtils.bottomSafeHeight,
          ),
          sliver: AiNovelManagementSliverListView(),
        ),
      ],
    );
  }
}
