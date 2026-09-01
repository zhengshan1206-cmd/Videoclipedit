// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_page.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_material_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_show_list_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_mine_materials_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_opening_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/v2/aiClip/widgets/ai_commentary_rewrite_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:video_clip_edit/v2/hotCreate/widgets/short_play_detail_list_cell.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/short_show_details_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/commn_alert_dailog.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';

///现在正在使用的短剧列表页面
class ShortPlayListPage extends StatefulWidget {
  final bool fromPrompt;
  final CloudVideoListBean videoListBean;
  const ShortPlayListPage({
    super.key,
    this.fromPrompt = false,
    required this.videoListBean,
  });

  @override
  State<ShortPlayListPage> createState() => _CloudMaterialsPageState();
}

class _CloudMaterialsPageState extends State<ShortPlayListPage> {
  @override
  void initState() {
    super.initState();

    /// 加载云端素材列表
    _loadCloudVideos();
  }

  ///系统默认按钮 history: 3.10.9-暂时屏蔽
  Widget _systemConfirmBtn() {
    return Expanded(
      child: ByWidgetsUtil.commonBtn(
        title: "系统默认",
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        bgColor: const Color(0xFF1CCB71),
        padding: EdgeInsets.zero,
        borderRadius: 12.w,
        onClick: () async {
          final provider = context.read<ShortShowDetailsProvider>();
          final videoDetailBeans = provider.videoDetailBeans;
          if (videoDetailBeans.isEmpty) {
            BotToast.showText(text: "当前没有视频素材，请先选择其他短剧");
            return;
          }

          /// 选中前3个视频
          provider.updateSelectedVideoIdxs(List.generate(
              videoDetailBeans.length > 3 ? 3 : videoDetailBeans.length,
              (index) => index));

          final providerClip = AiClipProvider();
          final prompts = provider.getSelectedVideoContents();
          final ids = provider.getSelectedVideoIds();
          byDebugPrint(prompts);

          /// 改写文案
          final result = await showDialog(
            context: context,
            builder: (ctx) => ChangeNotifierProvider.value(
              value: providerClip,
              child: AiCommentaryRewriteDialog(
                // provider: providerClip,
                commentaryDesc: prompts,
                ids: ids,
              ),
            ),
          );
          byDebugPrint("文案解析结果: $result");
          byDebugPrint(prompts);
          if (result == false) return;
          providerClip.commentaryDesc = prompts;
          providerClip.entranceSource = EntranceSource.shortPlay;
          final providerMaterial = AiMaterialProvider();

          providerMaterial.selectedShowId = widget.videoListBean.id;
          final selectedVideoIdxs = provider.selectedVideoIdxs;
          providerMaterial.selectedClipMaterials = [
            MaterialPack.fromCloudVideoListBean(widget.videoListBean)
          ];
          providerMaterial.currentType = AiMaterialType.show;
          providerMaterial.selectedShowListBeans = selectedVideoIdxs
              .map(
                  (idx) => AiShowListItemBean.fromDetail(videoDetailBeans[idx]))
              .toList();

          ByNavRouterUtils.pushReplacement(
            context,
            ChangeNotifierProvider(
              create: (context) => StroyCreateProvider(),
              child: MultiProvider(
                  providers: [
                    ChangeNotifierProvider(create: (context) => providerClip),
                    ChangeNotifierProvider(
                      create: (BuildContext context) => providerMaterial,
                    ),
                    ChangeNotifierProvider(
                      create: (BuildContext context) => AiClipOpeningProvider(),
                    ),
                    ChangeNotifierProvider(
                      create: (BuildContext context) =>
                          AiClipMineMaterialsProvider(),
                    ),
                  ],
                  child: AiClipPage(
                    title: "短剧创作",
                    loadCommentary: false,
                    fromPrompt: widget.fromPrompt,
                    source: EntranceSource.shortPlay,
                  )),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoDetailBeans =
        context.select<ShortShowDetailsProvider, List<Detail>>(
            (value) => value.videoDetailBeans);

    final selectedVideoIdxs =
        context.select<ShortShowDetailsProvider, List<int>>(
            (value) => value.selectedVideoIdxs);
    const maxCount = 5;
    final selectedCount = selectedVideoIdxs.length;
    return Scaffold(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      appBar: _buildAppbar(context),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: ByWidgetsUtil.commonTipsBar("请选择1-5个素材片段，如不选择将随机使用素材。"),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                itemCount: videoDetailBeans.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10.w,
                    crossAxisSpacing: 10.w,
                    childAspectRatio: 0.75),
                itemBuilder: (context, index) {
                  return ShortPlayDetailListCell(
                    index: index,
                    videoBean: videoDetailBeans[index],
                    maxCount: maxCount,
                    canPreview: true,
                  );
                },
              ),
            ),
            ByWidgetsUtil.physicalModel(
              color: Colors.white,
              child: Container(
                height: 66.h,
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                margin: EdgeInsets.only(bottom: 15.h),
                child: Row(
                  children: [
                    // Expanded(child: _systemConfirmBtn()),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ByWidgetsUtil.commonBtnWithRichText(
                        padding: EdgeInsets.zero,
                        borderRadius: 12.w,
                        title: IgnorePointer(
                          child: ByWidgetsUtil.commonRichText(
                            texts: selectedCount > 0
                                ? [
                                    const TextSpan(
                                      text: "确定",
                                    ),
                                    TextSpan(
                                      text: "(已选$selectedCount)",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ]
                                : [
                                    const TextSpan(
                                      text: "请选择视频素材",
                                    ),
                                  ],
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            textColor: ByColorUtil.WhiteColor,
                          ),
                        ),
                        onClick: () async {
                          if (widget.fromPrompt) {
                            final provider =
                                context.read<ShortShowDetailsProvider>();
                            final ids = provider.getSelectedVideoIds();
                            ByNavigatorUtil.reportDataPoint(
                              pageTag: "drama_creation_page_reselect_btn",
                              operateType: "click",
                              funcDetailTag: widget.videoListBean.id.toString(),
                              funcDetailImg: widget.videoListBean.coverUrl,
                              extra: {
                                "drama_detail_ids": ids,
                              },
                            );
                          }
                          final provider =
                              context.read<ShortShowDetailsProvider>();
                          if (provider.selectedVideoIdxs.isEmpty) {
                            // BotToast.showText(text: "请选择视频素材");
                            showDialog(
                                context: context,
                                builder: (ctx) {
                                  return CommonAlertDialog(
                                    title: '温馨提示',
                                    contents: "请先选择素材后再进行创作。",
                                    confirmBtnTitle: "确定",
                                    showCancel: false,
                                    confirmCallback: (p0) {},
                                  );
                                });
                            // BotToast.showText(text: "请先选择素材后再进行创作。");
                            return;
                          } else {
                            ///todo 返回新选择的剧本
                            // final providerClip = AiClipProvider();
                            final ids = provider.getSelectedVideoIdsList();
                            // final prompts = provider.getSelectedVideoContents();
                            Get.back(result: ids);
                            Get.log("ids====> ${ids} ");
                            return;
                          }
                          final providerClip = AiClipProvider();
                          final prompts = provider.getSelectedVideoContents();
                          final ids = provider.getSelectedVideoIds();

                          /// 改写文案
                          final result = await showDialog(
                            context: context,
                            builder: (ctx) => ChangeNotifierProvider.value(
                              value: providerClip,
                              child: AiCommentaryRewriteDialog(
                                // provider: providerClip,
                                commentaryDesc: prompts,
                                ids: ids,
                              ),
                            ),
                          );
                          byDebugPrint("文案解析结果: $result");
                          byDebugPrint(prompts);
                          if (result == false) return;

                          providerClip.commentaryDesc = prompts;
                          providerClip.entranceSource =
                              EntranceSource.shortPlay;
                          final providerMaterial = AiMaterialProvider();

                          providerMaterial.selectedShowId =
                              widget.videoListBean.id;
                          final selectedVideoIdxs = provider.selectedVideoIdxs;
                          final videoDetailBeans = provider.videoDetailBeans;
                          providerMaterial.selectedClipMaterials = [
                            MaterialPack.fromCloudVideoListBean(
                                widget.videoListBean)
                          ];
                          providerMaterial.currentType = AiMaterialType.show;
                          providerMaterial.selectedShowListBeans =
                              selectedVideoIdxs
                                  .map((idx) => AiShowListItemBean.fromDetail(
                                      videoDetailBeans[idx]))
                                  .toList();

                          ByNavRouterUtils.pushReplacement(
                            context,
                            ChangeNotifierProvider(
                              create: (context) => StroyCreateProvider(),
                              child: MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider(
                                        create: (context) => providerClip),
                                    ChangeNotifierProvider(
                                      create: (BuildContext context) =>
                                          providerMaterial,
                                    ),
                                    ChangeNotifierProvider(
                                      create: (BuildContext context) =>
                                          AiClipOpeningProvider(),
                                    ),
                                    ChangeNotifierProvider(
                                      create: (BuildContext context) =>
                                          AiClipMineMaterialsProvider(),
                                    ),
                                  ],
                                  child: AiClipPage(
                                    title: "短剧创作",
                                    loadCommentary: false,
                                    ratioChangeable: false,
                                    fromPrompt: widget.fromPrompt,
                                    source: EntranceSource.shortPlay,
                                  )),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppbar(BuildContext context) {
    const typeName = "热门短剧";
    const maxCount = 5;
    String textInfo = '请选择1-$maxCount个$typeName片段';
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.2,
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          EasyLoading.dismiss();
          ByNavRouterUtils.goBack(context);
        },
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          child: Image.asset(
            "assets/home/icon_back.png",
            width: 16,
            height: 16,
          ),
        ),
      ),
      title: const Text(
        "选择短剧素材",
        style: TextStyle(
          color: ByColorUtil.CommonTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      //  Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     Text(
      //       (widget.videoListBean.materialName.isNotEmpty)
      //           ? widget.videoListBean.materialName
      //           : "热门短剧",
      //       style: const TextStyle(
      //         color: ByColorUtil.CommonTextColor,
      //         fontSize: 16,
      //         fontWeight: FontWeight.w700,
      //       ),
      //     ),
      //     Container(
      //       margin: const EdgeInsets.only(top: 5),
      //       child: Text(
      //         textInfo,
      //         style: const TextStyle(
      //           color: Colors.grey,
      //           fontSize: 10,
      //         ),
      //       ),
      //     )
      //   ],
      // ),
    );
  }

  /// 加载云端素材列表
  void _loadCloudVideos() {
    final provider = context.read<ShortShowDetailsProvider>();
    provider.loadCloudVideosForName(
      id: widget.videoListBean.id.toString(),
      onSuccess: (List<Detail> beans) {},
    );
  }
}
