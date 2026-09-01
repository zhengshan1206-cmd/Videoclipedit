import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/core/util/manager/auth.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_time_utils.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/ai_sample_play_page.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_local_bean.dart';

class AiClipMineMaterialPage extends StatefulWidget {
  const AiClipMineMaterialPage({
    super.key,
    this.paddingTop,
    this.isOpening = false,
  });
  final double? paddingTop;
  final bool isOpening;
  @override
  State<AiClipMineMaterialPage> createState() => _AiClipMineMaterialPageState();
}

class _AiClipMineMaterialPageState extends State<AiClipMineMaterialPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final EasyRefreshController _controller = EasyRefreshController(
      controlFinishRefresh: true, controlFinishLoad: true);

  @override
  void dispose() {
    final provider = context.read<AiMaterialProvider>();
    provider.resetMinePage();
    provider.resetOpeningPage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: _buildContents(context),
    );
  }

  _buildContents(BuildContext context) {
    final mineMaterialItemBeans =
        context.select<AiMaterialProvider, List<AiCartoonBgmLocalBean>>(
            (value) => widget.isOpening
                ? value.openingMaterialItemBeans
                : value.mineMaterialItemBeans);
    final isEmpty = mineMaterialItemBeans.isEmpty;
    if (isEmpty) {
      return Column(
        children: [
          Expanded(
            child: EasyRefresh(
              refreshOnStart: true,
              controller: _controller,
              onRefresh: () {
                _loadMaterials(context, reset: true, controller: _controller);
              },
              onLoad: () {
                _loadMaterials(context, reset: false, controller: _controller);
              },
              child: ByWidgetsUtil.commonListNoDataView(
                prompts: "当前素材库无内容，请先上传素材",
                promptsColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
              ),
            ),
          ),
          SizedBox(
            height: 66.h + ByScreenUtils.bottomSafeHeight,
            width: double.infinity,
            child: PhysicalModel(
              color: ByColorUtil.BlackColor,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                  top: 8.h,
                  bottom: 8.h + ByScreenUtils.bottomSafeHeight,
                ),
                child: ByWidgetsUtil.btnWithSvgIcon(
                  title: "上传素材",
                  iconPath: "assets/ai/clip/ai_clip_icon_upload_white.svg",
                  iconW: 20,
                  iconH: 16,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  onClick: () {
                    byDebugPrint("上传素材");
                    _selectVideo(context);
                  },
                ),
              ),
            ),
          ),
        ],
      );
    }
    final count = context
        .select<AiMaterialProvider, List<AiCartoonBgmLocalBean>>((value) =>
            widget.isOpening
                ? value.selectedOpeningMaterialItemBeans
                : value.selectedMineMaterialItemBeans)
        .length;
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 66.h + ByScreenUtils.bottomSafeHeight,
          child: EasyRefresh(
            refreshOnStart: true,
            controller: _controller,
            onRefresh: () {
              _loadMaterials(context, reset: true, controller: _controller);
            },
            onLoad: () {
              _loadMaterials(context, reset: false, controller: _controller);
            },
            child: GridView.builder(
              padding: EdgeInsets.only(
                bottom: 66.h + 44.h,
                left: 12.w,
                right: 12.w,
                top: widget.paddingTop ?? 10.h,
              ),
              itemCount: mineMaterialItemBeans.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 11.w,
                mainAxisSpacing: 10.h,
              ),
              itemBuilder: (context, index) {
                return AiClipMineMateriaListCell(
                  index: index,
                  controller: _controller,
                  isOpening: widget.isOpening,
                  bean: mineMaterialItemBeans[index],
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 66.h + ByScreenUtils.bottomSafeHeight,
          child: PhysicalModel(
            color: ByColorUtil.BlackColor,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                top: 8.h,
                bottom: 8.h + ByScreenUtils.bottomSafeHeight,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ByWidgetsUtil.btnWithSvgIcon(
                      title: "上传素材",
                      iconW: 20,
                      iconH: 16,
                      iconPath: "assets/ai/clip/ai_clip_icon_upload.svg",
                      fontSize: 16.sp,
                      contentGap: 11.w,
                      borderRadius: 12.w,
                      fontWeight: FontWeight.w500,
                      bgColor: const Color(0xFFEAEEFF),
                      textColor: ByColorUtil.TabTextColorSelected,
                      onClick: () {
                        _selectVideo(context);
                      },
                    ),
                  ),
                  SizedBox(width: 11.w),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        ByNavRouterUtils.goBack(context);
                      },
                      child: ByWidgetsUtil.commonContainer(
                        borerRadius: 12.w,
                        alignment: Alignment.center,
                        bgColor: ByColorUtil.TabTextColorSelected,
                        child: ByWidgetsUtil.commonRichText(
                          texts: [
                            const TextSpan(text: "确定"),
                            TextSpan(
                                text: "(已选$count)",
                                style: TextStyle(fontSize: 12.sp)),
                          ],
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          textColor: ByColorUtil.WhiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _selectVideo(BuildContext context) {
    AuthManager.materialAuth(onSuccess: () {
      ByCommonUtils.pickAssetsByType(
      context,
      type: RequestType.video,
      maxCount: 1,
      onSelectedCallback: (asstes, {List<String>? urls}) async {
        final provider = context.read<AiMaterialProvider>();
        File? file;
        AssetEntity? asset;
        if (urls != null && urls.isNotEmpty) {
          file = File(urls.first);
          if (!file.existsSync()) {
            BotToast.showText(text: "选择文件时出错，请重新选择");
            return;
          }
        } else if (asstes.isNotEmpty) {
          asset = asstes.first;
          file = await asset.file;
        }
        if (file == null) {
          BotToast.showText(text: "选择文件时出错，请重新选择");
          return;
        }
        if (mounted) {
          provider.uploadMaterial(
              asset: asset, file: file, controller: _controller);
        }
      },
    );
    },);
  }

  void _loadMaterials(
    BuildContext context, {
    bool reset = false,
    required EasyRefreshController controller,
  }) {
    final provider = context.read<AiMaterialProvider>();
    provider.aiMineMaterialsList(
      reset: reset,
      controller: controller,
      isOpening: widget.isOpening,
    );
  }
}

class AiClipMineMateriaListCell extends StatelessWidget {
  const AiClipMineMateriaListCell({
    super.key,
    required this.bean,
    required this.index,
    required this.isOpening,
    required this.controller,
  });

  final int index;
  final bool isOpening;
  final AiCartoonBgmLocalBean bean;
  final EasyRefreshController controller;
  @override
  Widget build(BuildContext context) {
    final provider = context.read<AiMaterialProvider>();
    // ignore: unused_local_variable
    final selectedMineMaterialItemBeans =
        context.select<AiMaterialProvider, List<AiCartoonBgmLocalBean>>(
      (value) => isOpening
          ? value.selectedOpeningMaterialItemBeans
          : value.selectedMineMaterialItemBeans,
    );
    final selected = isOpening
        ? provider.checkOpeningMaterialItemBeanSelected(bean)
        : provider.checkMineMaterialItemBeanSelected(bean);
    final underReview = bean.status == 1;
    if (underReview) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/ai/ai_cartoon_video_bg.png",
                fit: BoxFit.fitWidth,
              ),
            ),
            Positioned.fill(
              child: Column(
                children: [
                  const Spacer(),
                  ByWidgetsUtil.svgAsset(
                    filePath: "assets/ai/clip/ai_clip_icon_under_review.svg",
                    width: 32,
                    height: 32,
                  ),
                  SizedBox(height: 18.h),
                  ByWidgetsUtil.commonText(
                    fontSize: 12.sp,
                    text: "审核中，约1-5分钟",
                    textColor: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    height: 28.h,
                    width: 100.w,
                    child: ByWidgetsUtil.btnWithSvgIcon(
                      title: "刷新状态",
                      fontSize: 12.sp,
                      iconH: 11,
                      iconW: 11,
                      bgColor: ByColorUtil.WhiteColor,
                      borderRadius: 30,
                      padding: EdgeInsets.zero,
                      fontWeight: FontWeight.normal,
                      textColor: ByColorUtil.CommonTextColor,
                      iconPath: "assets/ai/clip/ai_clip_icon_refresh.svg",
                      onClick: () {
                        controller.callRefresh();
                      },
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if(bean.url.isEmpty){
          BotToast.showText(text: "该视频已经违规，请重新上传素材");
          return;
        }
        provider.selectedShowId = -1;
        provider.updateSelectedClipMaterials([]);
        provider.updateSelectedShowListItemBeans([]);

        // Get.log("选中== bean==> ${bean}");



        /// 修改选中状态
        if (isOpening) {
          provider.updateSelectedOpeningMaterialItemBeansWithBean(bean);
        } else {
          provider.updateSelectedMineMaterialItemBeansWithBean(bean);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: bean.cover,
                fit: BoxFit.cover,
              ),
            ),
            GestureDetector(
              onTap: () {
                byDebugPrint("play");
                if(bean.url.isEmpty){
                  BotToast.showText(text: "该视频已经违规，请重新上传素材");
                  return;
                }
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (ctx) => AiSamplePlayPage(videoUrl: bean.url),
                );
              },
              child: Center(
                child: Image.asset(
                  "assets/ai/clip/ai_clip_icon_sample_play.png",
                  width: 40.w,
                  height: 40.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 50.h,
              child: ByWidgetsUtil.gradientBgContainer(
                gradient: ByColorUtil.lineareGradient(
                  colorStart: const Color(0xFF000000).withOpacity(0),
                  colorEnd: const Color(0xFF000000).withOpacity(0.7),
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                alignment: Alignment.bottomLeft,
                borderRadius: 0,
                padding: EdgeInsets.only(
                  left: 6.w,
                  bottom: 8.h,
                  right: 5.w,
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: ByWidgetsUtil.commonText(
                      text: bean.name ?? "我的素材",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      textColor: const Color(0xFFFFFFFF),
                    )),
                    SizedBox(width: 5.w),
                    ByWidgetsUtil.commonText(
                      text:
                          "约${ByTimeUtils.formatWithSeconds(double.parse(bean.duration))}",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.normal,
                      textColor: const Color(0xFFFFFFFF),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 50.h,
              child: ByWidgetsUtil.gradientBgContainer(
                gradient: ByColorUtil.lineareGradient(
                  colorStart: const Color(0xFF000000).withOpacity(0),
                  colorEnd: const Color(0xFF000000).withOpacity(0),
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                alignment: Alignment.topRight,
                borderRadius: 0,
                padding: EdgeInsets.only(right: 10.w, top: 10.h),
                child: ByWidgetsUtil.svgAsset(
                  filePath: selected
                      ? "assets/ai/clip/ai_clip_icon_selected.svg"
                      : "assets/ai/clip/ai_clip_icon_unselected.svg",
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
