import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';

import '../../../modules/common/widget/common_dialog.dart';
import '../models/ai_novel_generation_model.dart';
import '../providers/ai_novel_management_provider.dart';
import 'ai_novel_modify_dialog.dart';
import 'ai_novel_preview_page.dart';
import 'ai_novel_rename_dialog.dart';

class AiNovelManagementSliverListView extends StatefulWidget {
  const AiNovelManagementSliverListView({
    super.key,
  });

  @override
  State<AiNovelManagementSliverListView> createState() =>
      _AiNovelManagementSliverListViewState();
}

class _AiNovelManagementSliverListViewState
    extends State<AiNovelManagementSliverListView> {
  @override
  Widget build(BuildContext context) {
    final List<AiNovelGenerationTaskModel> recordBeans = context
        .select<AiNovelManagementProvider, List<AiNovelGenerationTaskModel>>(
      (p) => p.recordBeans,
    );

    return SliverList.builder(
      itemCount: recordBeans.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: AiNovelManagementListViewCell(
          index: index,
          bean: recordBeans[index],
        ),
      ),
    );
  }
}

class AiNovelManagementListView extends StatefulWidget {
  const AiNovelManagementListView({
    super.key,
  });

  @override
  State<AiNovelManagementListView> createState() =>
      _AiNovelManagementListViewState();
}

class _AiNovelManagementListViewState extends State<AiNovelManagementListView> {
  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiNovelManagementListView:----");
    final List<AiNovelGenerationTaskModel> videoRecordBeans = context
        .select<AiNovelManagementProvider, List<AiNovelGenerationTaskModel>>(
      (p) => p.recordBeans,
    );

    return ListView.separated(
      itemCount: videoRecordBeans.length,
      padding: EdgeInsets.only(bottom: 66.h + ByScreenUtils.bottomSafeHeight),
      separatorBuilder: (BuildContext context, int index) =>
          Container(height: 10.h),
      itemBuilder: (context, index) => AiNovelManagementListViewCell(
        index: index,
        bean: videoRecordBeans[index],
      ),
    );
  }
}

class AiNovelManagementListViewCell extends StatelessWidget {
  const AiNovelManagementListViewCell({
    super.key,
    required this.index,
    required this.bean,
  });

  final int index;
  final AiNovelGenerationTaskModel bean;

  @override
  Widget build(BuildContext context) {
    byDebugPrint("---AiNovelManagementListViewCell");
    final status = bean.status;
    final provider = context.watch<AiNovelManagementProvider>();

    final editing = context.select<AiNovelManagementProvider, bool>(
        (value) => value.videosEditing);

    final selectedNovelIdxs =
        context.select<AiNovelManagementProvider, List<int>>(
            (value) => value.selectedNovelIdxs);
    final selected = selectedNovelIdxs.contains(index);

    byDebugPrint("$selectedNovelIdxs----selected:$selected");

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (editing) {
          context
              .read<AiNovelManagementProvider>()
              .updateSelectedNovelIdxsWithIndex(index);
        } else {
          if (status == AiNovelStatus.done) {
            ByNavRouterUtils.push(
                context,
                MultiProvider(
                  providers: [
                    ChangeNotifierProvider.value(
                        value: context.read<AiNovelManagementProvider>()),
                  ],
                  child: AiNovelPreviewPage(novelBean: bean),
                ));
          }
        }
      },
      child: Container(
        // height: 85,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                offset: Offset.zero,
                blurRadius: 4,
              ),
            ]),
        child: Stack(
          children: [
            if (status == AiNovelStatus.inspirationGenerating ||
                status == AiNovelStatus.chapterUnitDesign ||
                status == AiNovelStatus.chapterOutline ||
                status == AiNovelStatus.chapterExpansion)
              Stack(
                children: [
                  Container(
                    height: 115,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 18,
                          width: 180,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B1843).withOpacity(0.02),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          height: 12,
                          width: 300,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B1843).withOpacity(0.02),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          height: 12,
                          width: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B1843).withOpacity(0.02),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Image.asset(
                              "assets/ai/icon_novel_tips.png",
                              width: 13,
                              height: 13,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 5.w),
                            ByWidgetsUtil.commonText(
                              text: "正在生成小说，耗时较长请耐心等待",
                              textColor: const Color(0xFFFF2A70),
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 85,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ByWidgetsUtil.activityIndicator(
                            color: const Color(0xFF5B4BF7)),
                        SizedBox(height: 11.5.h),
                        ByWidgetsUtil.commonText(
                          text: "内容生成中...",
                          textColor: const Color(0xFF5B4BF7),
                          fontSize: 12.sp,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            if (status == AiNovelStatus.failed)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ByWidgetsUtil.commonText(
                        fontSize: 14.sp,
                        text: "生成失败积分已退回",
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center),
                    SizedBox(height: 8.h),
                    Image.asset(
                      "assets/ai/ai_cartoon_video_faild.png",
                      width: 32.w,
                      height: 32.h,
                      color: ByColorUtil.MainTextColor,
                      fit: BoxFit.contain,
                    ),
                    // SizedBox(
                    //   width: 150.w,
                    //   height: 32.h,
                    //   child: ByWidgetsUtil.commonBtn(
                    //     padding: EdgeInsets.zero,
                    //     fontWeight: FontWeight.normal,
                    //     bgColor: ByColorUtil.TabTextColorSelected,
                    //     borderRadius: 8.w,
                    //     fontSize: 14.sp,
                    //     title: "重新生成",
                    //     onClick: () {
                    //       byDebugPrint(bean.toJson());
                    //       final provider = AiNovelProvider();
                    //       ByNavRouterUtils.push(
                    //           context,
                    //           MultiProvider(
                    //               providers: [
                    //                 ChangeNotifierProvider(
                    //                     create: (context) => provider),
                    //               ],
                    //               child: NewAiNovelPage()));
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              ),
            // if (status == AiNovelStatus.deleted)
            //   Center(
            //     child: Column(
            // mainAxisSize: MainAxisSize.min,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         ByWidgetsUtil.commonText(
            //           fontSize: 14.sp,
            //           text: "已删除",
            //           fontWeight: FontWeight.bold,
            //           textAlign: TextAlign.center,
            //         ),
            //     ],
            //                 ),
            //   ),
            if (status == AiNovelStatus.done)
              Padding(
                padding: EdgeInsets.all(12.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            bean.title ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              height: 1.0,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: ByColorUtil.MainTextColor,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            bean.inspiration ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              height: 1.0,
                              fontSize: 12.sp,
                              color: const Color(0xFF0B1843).withOpacity(0.6),
                            ),
                          ),
                          SizedBox(height: 6.5.h),
                          Text(
                            bean.createAt,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              height: 1.0,
                              fontSize: 12.sp,
                              color: const Color(0xFF0B1843).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5.w),
                    if (!editing)
                      GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => showModalBottomSheet(
                                context: context,
                                isScrollControlled: true, // 允许高度自适应
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(18),
                                  ),
                                ),
                                builder: (ctx) => AiNovelModifyDialog(
                                  onDelete: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return CommonDialog(
                                          reverse: false,
                                          maxLine: 10,
                                          contents: "请确认是否删除，删除后将不可回恢复，请谨慎操作",
                                          confirmBtnTitle: "删除",
                                          confirmCallback: () {
                                            provider.deleteNovels(
                                              [bean.id],
                                              onSuccess: () {
                                                provider.resetPages();
                                                provider.updateSelectAllStatus(
                                                    false);
                                                provider.loadNovelList();
                                              },
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  onRename: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true, // 允许高度自适应
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(18),
                                        ),
                                      ),
                                      builder: (ctx) => AiNovelRenameDialog(
                                        onFinish: (name) {
                                          provider.renameNovel(
                                            bean,
                                            name,
                                            onSuccess: () {},
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                          child: const Icon(Icons.more_vert,
                              color: Color(0xFF0B1843))),
                  ],
                ),
              ),
            if (editing)
              Positioned(
                  right: 9.5.w,
                  top: 0,
                  bottom: 0,
                  child: Image.asset(
                    "assets/login/mywork_cell_${selected ? "selected" : "unselected"}.png",
                    width: 20.w,
                    height: 20.h,
                    color: selected ? null : ByColorUtil.MainTextColor,
                    fit: BoxFit.contain,
                  )),
          ],
        ),
      ),
    );
  }
}
