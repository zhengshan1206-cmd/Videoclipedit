import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/modules/profile/widgets/no_data_view.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_files_downoad_dialog.dart';
import 'package:video_clip_edit/modules/home/story/assistant/widgets/record_item_widget.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/assistant_record_item_bean.dart';

// ignore: must_be_immutable
class AssistantRecordPage extends StatefulWidget {
  bool isAiPage;

  AssistantRecordPage({
    super.key,
    this.isAiPage = false,
  });

  @override
  State<AssistantRecordPage> createState() => _AssistantRecordPageState();
}

class _AssistantRecordPageState extends State<AssistantRecordPage> {
  @override
  void initState() {
    super.initState();

    _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    final StroyCreateProvider provider = context.watch<StroyCreateProvider>();
    final beans = provider.assistantRecordBeans;
    final len = beans.length;

    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: widget.isAiPage ? "历史记录" : "生成记录",
        actions: _buildActions(context),
      ),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 10.w,
              right: 10.w,
              top: 12.h,
              bottom: context.byBottomSafeHeight,
            ),
            child: Column(
              children: [
                ByWidgetsUtil.commonTipsBar("文字在云端存储7天，过期无法恢复，请及时保存。"),
                Expanded(
                  child: len == 0
                      ? _buildNoData(context)
                      : EasyRefresh(
                          controller: provider.aiController,
                          onRefresh: () {
                            provider.aiPage = 1;
                            provider.loadAIRecords(
                              onSuccess: (p0) {},
                            );
                          },
                          onLoad: () {
                            provider.loadAIRecords(
                              onSuccess: (p0) {},
                            );
                          },
                          child: ListView.builder(
                            padding: EdgeInsets.only(top: 12.w),
                            itemCount: len,
                            itemBuilder: (context, index) {
                              final AssistantRecordItemBean bean = beans[index];
                              return RecordItemWidget(
                                recordItemBean: bean,
                                index: index,
                                isAiPage: widget.isAiPage,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
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
    final provider = context.read<StroyCreateProvider>();
    final recordsEditing = context.select<StroyCreateProvider, bool>(
      (p) => p.recordsEditing,
    );
    return Offstage(
      offstage: !recordsEditing,
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
                      if (recordsEditing) {
                        provider.updateRecordsEditingState(false);
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
                              provider.deleteRecords(
                                ids.map((e) {
                                  return provider.assistantRecordBeans[e].token;
                                }).toList(),
                                onSuccess: () {
                                  provider.assistantPage = 1;
                                  provider.updateSelectAllStatus(false);
                                  provider.loadAssistantRecord();
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
                    title: " 导出",
                    fontSize: 16.sp,
                    borderRadius: 12.w,
                    fontWeight: FontWeight.w600,
                    textColor: ByColorUtil.WhiteColor,
                    bgColor: ByColorUtil.LoginBtnBgColor,
                    onClick: () async {
                      showModalBottomSheet(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                        ),
                        builder: (BuildContext ctx) {
                          //构建弹框中的内容
                          return StatefulBuilder(
                              builder: (c, setBottomSheetState) {
                            return Container(
                              height: 260.h,
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(),
                                      Text(
                                        "选择导出格式",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Image.asset(
                                          "assets/login/login_dialog_close.png",
                                          width: 12.9,
                                          height: 12.7,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 20.h),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () async {
                                          ByNavRouterUtils.goBack(context);
                                          provider.exportDoc(
                                            type: "word",
                                            onSuccess: (url) async {
                                              final status =
                                                  await ByPermissionUtils
                                                      .storage();
                                              if (!status) return;
                                              showDialog(
                                                context: context,
                                                builder: (c) {
                                                  return AiFilesDownoadDialog(
                                                    contents: "",
                                                    maxLine: 10,
                                                    cancelBtnTitle: "取消",
                                                    confirmBtnTitle: "确定",
                                                    confirmCallback: () {},
                                                    fileUrls: [url],
                                                    onSuccess: (index,
                                                        filePath) async {
                                                      await Share.shareXFiles(
                                                          [XFile(filePath)],
                                                          text:
                                                              'Word Document Shared');
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                        child: Image.asset(
                                          "assets/ai/aiduihua_dcword.png",
                                          fit: BoxFit.fitWidth,
                                        ),
                                      )),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                          child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () async {
                                          ByNavRouterUtils.goBack(context);
                                          final directory =
                                              await getApplicationCacheDirectory();
                                          final filePath =
                                              "${directory.path}/files/file_${DateTime.now().millisecondsSinceEpoch}.txt";
                                          // 创建文件并写入内容
                                          File file = File(filePath);
                                          await file.writeAsString(provider
                                              .selectedVideoIdxs
                                              .map((e) {
                                            final bean = provider
                                                .assistantRecordBeans[e];
                                            return "第${e + 1}段: 标题: ${bean.sketch}\n\n\n时间: ${bean.answerEndTime}\n\n\n内容: ${bean.answer}\n\n\n";
                                          }).join("\n"));

                                          await Share.shareXFiles(
                                              [XFile(filePath)],
                                              text: 'Txt Document Shared');
                                        },
                                        child: Image.asset(
                                          "assets/ai/aiduihua_dctxt.png",
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ))
                                    ],
                                  )
                                ],
                              ),
                            );
                          });
                        },
                        context: context,
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

  List<Widget> _buildActions(BuildContext context) {
    final provider = context.read<StroyCreateProvider>();
    final worksEditing =
        context.select<StroyCreateProvider, bool>((p) => p.recordsEditing);
    final selectAll =
        context.select<StroyCreateProvider, bool>((p) => p.selectAll);
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
                    : "assets/home/mat_icon_ai_unselected.png",
                width: 16.w,
                height: 16.h,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 5.w),
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
            .select<StroyCreateProvider, List<AssistantRecordItemBean>>(
              (p) => p.assistantRecordBeans,
            )
            .isEmpty,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            /// 更新编辑状态
            provider.updateRecordsEditingState(true);
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

  _buildNoData(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ByColorUtil.WhiteColor,
        borderRadius: BorderRadius.circular(15.h),
      ),
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 15.h),
      child: NoDataView(
        onTap: () {
          ByNavRouterUtils.goBack(context);
        },
      ),
    );
  }

  void _loadRecords() {
    final provider = context.read<StroyCreateProvider>();
    provider.loadAssistantRecord(
      onSuccess: (beans) {},
    );
  }
}
