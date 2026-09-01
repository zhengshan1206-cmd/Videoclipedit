import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/recreate/widgets/role_words_cell.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/home/recreate/widgets/role_edit_dailog.dart';
import 'package:video_clip_edit/modules/home/recreate/beans/commentary_item_bean.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class NarratorCell<T extends MaterialBaseProvider> extends StatefulWidget {
  const NarratorCell({
    super.key,
    required this.resultBean,
    required this.index,
  });
  final CommentaryItemBean resultBean;
  final int index;
  @override
  State<NarratorCell<T>> createState() => _NarratorCellState<T>();
}

class _NarratorCellState<T extends MaterialBaseProvider>
    extends State<NarratorCell<T>> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool storylineExpanded = widget.resultBean.talkExpanded;
    final storylineName = "剧情${widget.index + 1}";
    final startTime = widget.resultBean.duration.round();
    final storylineLen =
        "${"${(startTime / 60).floor()}".padLeft(2, "0")}:${"${startTime.remainder(60)}".padLeft(2, "0")}";
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            bottom: 15.h,
            top: 15.h,
          ),
          decoration: const BoxDecoration(color: ByColorUtil.WhiteColor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 剧情header
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final provider = context.read<ShowRecreateProvider>();
                  final bean = widget.resultBean.copyWith();
                  bean.talkExpanded = !bean.talkExpanded;
                  provider.updateCommentaryItemBeanAtIndex(widget.index, bean);
                },
                child: Row(
                  children: [
                    ByWidgetsUtil.commonText(
                      text: "$storylineName  $storylineLen",
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                    ByWidgetsUtil.commonText(
                      text: "(剧情和解说二选一)",
                      textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                      fontSize: 12.sp,
                    ),
                    const Spacer(),
                    ByWidgetsUtil.commonText(
                      text: storylineExpanded ? "收起" : "展开",
                      fontWeight: FontWeight.normal,
                      fontSize: 12.sp,
                    ),
                    const SizedBox(width: 5),
                    Image.asset(
                      "assets/home/${storylineExpanded ? "icon_role_expand" : "icon_role_collapse"}.png",
                      width: 10.w,
                      height: 10.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              /// 剧情内容
              Padding(
                padding: EdgeInsets.only(top: 15.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 剧情截图
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                final provider =
                                    context.read<ShowRecreateProvider>();
                                provider.updateVideoOffset(
                                    widget.resultBean.talk.first);
                                // ByNavRouterUtils.push(
                                //     context,
                                //     VideoMaterialEditPage(
                                //         assetEntity: context
                                //             .read<ShowRecreateProvider>()
                                //             .selectedMaterials
                                //             .first));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.w),
                                child: ByWidgetsUtil.futuerBuilderWidget(
                                  future: _getSnapshots(context),
                                  builder: (ctx, data) {
                                    if (data?.isEmpty ?? true) {
                                      return SizedBox(
                                        width: 44.w,
                                        height: 44.w,
                                      );
                                    }
                                    return SizedBox(
                                      width: 44.w,
                                      height: 44.w,
                                      child: Image.file(
                                        File(data!),
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  },
                                  waitingWidget:
                                      ByWidgetsUtil.activityIndicator(),
                                  errorWidget: SizedBox(
                                    width: 44.w,
                                    height: 44.w,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 5.h,
                              left: 16.w,
                              child: Image.asset(
                                "assets/home/icon_storyline_preview.png",
                                width: 12.w,
                                height: 12.h,
                                alignment: Alignment.center,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              final provider =
                                  context.read<ShowRecreateProvider>();
                              final bean = widget.resultBean.copyWith();
                              bean.talkSelected = true;
                              provider.updateCommentaryItemBeanAtIndex(
                                  widget.index, bean);
                            },
                            child: SizedBox(
                              height: 44.h,
                              child: ByWidgetsUtil.commonContainer(
                                borerRadius: 8.w,
                                alignment: Alignment.center,
                                bgColor: widget.resultBean.talkSelected
                                    ? const Color(0xFFEBEDFF)
                                    : const Color(0xFFF5F8F9),
                                child: ByWidgetsUtil.commonText(
                                  text: "剧情",
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  textColor: widget.resultBean.talkSelected
                                      ? ByColorUtil.TabTextColorSelected
                                      : ByColorUtil.CommonTextColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              final provider =
                                  context.read<ShowRecreateProvider>();
                              final bean = widget.resultBean.copyWith();
                              bean.talkSelected = false;
                              provider.updateCommentaryItemBeanAtIndex(
                                  widget.index, bean);
                            },
                            child: SizedBox(
                              height: 44.h,
                              child: ByWidgetsUtil.commonContainer(
                                borerRadius: 8.w,
                                alignment: Alignment.center,
                                bgColor: widget.resultBean.talkSelected
                                    ? const Color(0xFFF5F8F9)
                                    : const Color(0xFFEBEDFF),
                                child: ByWidgetsUtil.commonText(
                                  text: "解说",
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  textColor: widget.resultBean.talkSelected
                                      ? ByColorUtil.CommonTextColor
                                      : ByColorUtil.TabTextColorSelected,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Offstage(
                      offstage: !(widget.resultBean.talkSelected &&
                          storylineExpanded),
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.h, left: 30.w),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.resultBean.talk.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final e = widget.resultBean.talk[index];
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                e.selected = !e.selected;
                                final bean = widget.resultBean.copyWith();
                                context
                                    .read<ShowRecreateProvider>()
                                    .updateCommentaryItemBeanAtIndex(
                                        widget.index, bean);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                child: Row(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      width: 25.w,
                                      height: 25.h,
                                      child: Image.asset(
                                        "assets/home/role_edit_${e.selected ? "checked" : "uncheck"}.png",
                                        width: 15.w,
                                        height: 15.h,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Expanded(
                                      child: RoleWordsCell<T>(
                                        canEdit: false,
                                        bean: e,
                                        margin: EdgeInsets.zero,
                                        type: RoleWordsCellType.storylien,
                                        storylineIndex: widget.index,
                                        wordIndex: index,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Offstage(
                      offstage: widget.resultBean.talkSelected,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Row(
                          children: [
                            SizedBox(width: 55.w),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    useSafeArea: false,
                                    barrierDismissible: false,
                                    builder: (ctx) =>
                                        ChangeNotifierProvider.value(
                                      value: context.read<T>(),
                                      child: RoleEditDailog<T>(
                                        type: RoleEditType.roleQuotes,
                                        cellType: RoleWordsCellType.storylien,
                                        roleWordsBean:
                                            widget.resultBean.talk.first,
                                        commentaryItemBean: widget.resultBean,
                                        storylineIndex: widget.index,
                                        commentary: true,
                                        showConfirm: true,
                                      ),
                                    ),
                                  );
                                },
                                child: ByWidgetsUtil.commonContainer(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 13.h,
                                  ),
                                  borerRadius: 8.w,
                                  bgColor: const Color(0xFFF5F8F9),
                                  child: ByWidgetsUtil.commonRichText(
                                    texts: [
                                      TextSpan(
                                        text: widget
                                            .resultBean.commentary.commentary,
                                      ),
                                      WidgetSpan(
                                          child: Image.asset(
                                        "assets/home/icon_words_edit.png",
                                        width: 12,
                                        height: 12,
                                      ))
                                    ],
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(height: 5.h, color: const Color(0xFFF5F8F9)),
      ],
    );
  }

  Future<String> _getSnapshots(BuildContext context) async {
    return "";
    // final dynamic asset = context.read<T>().assetSpeedy!;
    // final file = await _parseVideoUrl(asset);
    // final time = widget.resultBean.talk.first.startTime.toString();
    // final path = file?.path ?? "";
    // final result = await ChannelOperate.getVideoImage(time, path);
    // final snapshotFilePath = result["videoLocalFilePathParameter"] ?? "";
    // return snapshotFilePath;
  }

  Future<File?> _parseVideoUrl(dynamic asset) async {
    if (asset is AssetEntity) {
      return asset.file;
    }
    return asset as File;
  }
}
