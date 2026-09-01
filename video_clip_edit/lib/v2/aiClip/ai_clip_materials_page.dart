import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/commn_alert_dailog.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_string_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_sample_page.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_material_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_sample_provider.dart';
import 'package:video_clip_edit/v2/aiClip/widgets/ai_clip_material_bottom_bar.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/widgets/ai_clip_material_cateory_tab_view.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_ratio_bean.dart';


///选择混剪素材页面修改
class AiClipMaterialsPage extends StatefulWidget {
  const AiClipMaterialsPage({
    super.key,
    this.isHotReplica = false,
    this.shareUrl = "",
  });

  final bool isHotReplica;
  final String shareUrl;

  @override
  State<AiClipMaterialsPage> createState() => _AiClipMaterialsPageState();
}

class _AiClipMaterialsPageState extends State<AiClipMaterialsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final EasyRefreshController _controller = EasyRefreshController(
      controlFinishRefresh: true, controlFinishLoad: true);

  CancelToken _cancelToken = CancelToken();

  @override
  void dispose() {
    EasyLoading.dismiss();
    super.dispose();
  }

  void _showPromptDialog(ratio) {
    showDialog(
      context: context,
      builder: (context) {
        return CommonAlertDialog(
          title: '温馨提示',
          contents: "当前视频比例为$ratio，为了达到爆款效果，请尽量选择$ratio的视频素材",
          confirmBtnTitle: "确定",
          showCancel: false,
          confirmCallback: (p0) {},
        );
      },
    );
  }

  @override
  void initState() {
    if (widget.isHotReplica && widget.shareUrl.isNotEmpty) {
      final providerClip = context.read<AiClipProvider>();
      providerClip.parseShareUrl(
        widget.shareUrl,
        onSuccess: (data) {
          final ratio = data["video_info"]["scale"] ?? "";
          _showPromptDialog(ratio);
          if (providerClip.videoRatioBeans.isNotEmpty) {
            final ratioBean = providerClip.videoRatioBeans
                .firstWhere((e) => e.scale == ratio);
            final selectedRatioId = providerClip.selectedRatioId;
            if (selectedRatioId != ratioBean.id) {
              providerClip.updateSelectedRatioId(ratioBean.id);
              final providerMaterial = context.read<AiMaterialProvider>();
              providerMaterial.updateSelectedClipMaterials([]);
            }
            _loadMaterials(context, reset: true, controller: _controller);
            // _controller.callRefresh();
          }
        },
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Stack(
        children: [
          _buildContents(context),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Positioned _buildBottomBar() {
    return const Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ByAiClipMaterialBottomBar(),
    );
  }

  Widget _buildContents(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 95.h + ByScreenUtils.bottomSafeHeight,
      child: EasyRefresh(
        refreshOnStart: true,
        controller: _controller,
        onRefresh: () {
          _loadMaterials(context, reset: true, controller: _controller);
        },
        onLoad: () {
          _loadMaterials(context, reset: false, controller: _controller);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 素材视频比例
                  Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(
                        top: 15.h,
                        left: 12.w,
                        right: 12.w,
                        bottom: 12.h,
                      ),
                      child: _buildHeaderTitle(
                        iconPath:
                            "assets/ai/clip/ai_clip_header_icon_ratio.svg",
                        title: "素材视频比例",
                        required: true,
                      )),

                  AiClipMaterialRatioView(controller: _controller),

                  /// 素材类型
                  Stack(
                    children: [
                      Container(
                        color: Colors.white,
                        height: 44.h,
                      ),
                      Positioned.fill(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: ByColorUtil.CommonPageBgColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(18.w),
                              topRight: Radius.circular(18.w),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildHeaderTitle(
                                    iconPath:
                                        "assets/ai/clip/ai_clip_header_icon_category.svg",
                                    title: "选择素材分类"),
                              ),
                              SizedBox(
                                width: 120.w,
                                height: 32.h,
                                child: const AiClipMaterialCateoryTabView(
                                    items: ["单素材", "多素材"]),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const AiClipMaterialListView(),
            // const FooterLocator.sliver(),
            // SliverToBoxAdapter(
            //     child: SizedBox(
            //   height: 95.h + ByScreenUtils.bottomSafeHeight,
            // )),
          ],
        ),
      ),
    );
  }

  void _loadMaterials(
    BuildContext context, {
    bool reset = false,
    required EasyRefreshController controller,
  }) {
    final provider = context.read<AiMaterialProvider>();
    final providerClip = context.read<AiClipProvider>();
    _cancelToken.cancel();
    _cancelToken = CancelToken();
    provider.aiMaterialsList(
      reset: reset,
      type: provider.currentType.rawValue,
      scale: providerClip.selectedRatioId,
      cancelToken: _cancelToken,
      controller: controller,
    );
  }

  Widget _buildHeaderTitle({
    required String iconPath,
    required String title,
    bool required = false,
  }) {
    return Row(
      children: [
        ByWidgetsUtil.svgAsset(
          filePath: iconPath,
          width: 15,
          height: 15,
        ),
        SizedBox(width: 5.w),
        ByWidgetsUtil.commonText(
          text: title,
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        ),
        if (required)
          ByWidgetsUtil.commonText(
            text: "*",
            fontWeight: FontWeight.bold,
            textColor: const Color(0xFFF74B63),
            fontSize: 16.sp,
          ),
      ],
    );
  }
}

class AiClipMaterialListView extends StatelessWidget {
  const AiClipMaterialListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final itemBeans =
        context.select<AiMaterialProvider, List<AiMaterialItemBean>>(
      (value) => value.clipMaterialItemBeans,
    );
    return SliverList.builder(
      itemCount: itemBeans.length,
      itemBuilder: (context, index) {
        if (index >= itemBeans.length) return const SizedBox();
        return AiClipMaterialCategoryCell(index: index, bean: itemBeans[index]);
      },
    );
  }
}

class AiClipMaterialRatioView extends StatelessWidget {
  const AiClipMaterialRatioView({
    super.key,
    required this.controller,
  });

  final EasyRefreshController controller;

  @override
  Widget build(BuildContext context) {
    final ratioBeans =
        context.select<AiClipProvider, List<AiCartoonVideoRatioBean>>(
      (value) => value.videoRatioBeans,
    );
    return Container(
      color: Colors.white,
      height: 59.h,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        bottom: 15.h,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: ratioBeans.length,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 0,
          crossAxisSpacing: 11.w,
        ),
        itemBuilder: (context, index) {
          return AiClipMaterialRatioCell(
            index: index,
            bean: ratioBeans[index],
            controller: controller,
          );
        },
      ),
    );
  }
}

class AiClipMaterialCategoryCell extends StatefulWidget {
  const AiClipMaterialCategoryCell({
    super.key,
    required this.index,
    required this.bean,
  });
  final int index;
  final AiMaterialItemBean bean;

  @override
  State<AiClipMaterialCategoryCell> createState() =>
      _AiClipMaterialCategoryCellState();
}

class _AiClipMaterialCategoryCellState
    extends State<AiClipMaterialCategoryCell> {
  void goToSamplePage(BuildContext context) {
    ByNavRouterUtils.push(
      context,
      ChangeNotifierProvider(
        create: (BuildContext context) => AiClipSampleProvider(),
        child: AiClipSamplePage(pid: widget.bean.id),
      ),
    );
  }

  static const maxCount = 8;

  @override
  Widget build(BuildContext context) {
    final folde = widget.bean.folde;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(
            horizontal: 12.w,
          ),
          height: 0.5,
          color: ByColorUtil.CommonTextColor.withOpacity(0.05),
        ),
        Row(
          children: [
            SizedBox(width: 12.w),
            Container(
              width: 3.w,
              height: 14.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              child: ByWidgetsUtil.commonContainer(
                  bgColor: ByColorUtil.LoginBtnBgColor,
                  borerRadius: 2.w,
                  child: Container()),
            ),
            SizedBox(width: 4.w),
            ByWidgetsUtil.commonText(
              text: widget.bean.cateName,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                goToSamplePage(context);
              },
              child: ByWidgetsUtil.svgAsset(
                filePath: "assets/ai/clip/ai_clip_icon_sample_video.svg",
                width: 13,
                height: 13,
              ),
            ),
            SizedBox(width: 5.w),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                goToSamplePage(context);
              },
              child: ByWidgetsUtil.commonText(
                text: "素材样片",
                textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                fontSize: 12.sp,
              ),
            ),
            SizedBox(width: 12.w),
          ],
        ),
        GridView.builder(
          itemCount: folde
              ? widget.bean.materialPack.length > maxCount
                  ? maxCount
                  : widget.bean.materialPack.length
              : widget.bean.materialPack.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 0, bottom: 0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 85 / 32,
          ),
          itemBuilder: (context, index) {
            return AiClipMaterialCell(
              index: index,
              bean: widget.bean.materialPack[index],
            );
          },
        ),
        SizedBox(height: 15.h),
        Offstage(
          offstage: widget.bean.materialPack.length <= maxCount,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final provider = context.read<AiMaterialProvider>();
              provider.changeFoldStatsAtIndex(widget.index);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ByWidgetsUtil.commonText(
                  text: folde ? "更多" : "收起",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                ),
                SizedBox(width: 5.w),
                ByWidgetsUtil.svgAsset(
                  filePath: folde
                      ? "assets/ai/clip/ai_clip_icon_more.svg"
                      : "assets/ai/clip/ai_clip_icon_fold.svg",
                  width: 11,
                  height: 10,
                ),
              ],
            ),
          ),
        ),
        Offstage(
            offstage: widget.bean.materialPack.length <= maxCount,
            child: SizedBox(height: 15.h)),
      ],
    );
  }
}

class AiClipMaterialCell extends StatelessWidget {
  const AiClipMaterialCell({
    super.key,
    required this.index,
    required this.bean,
  });

  final int index;
  final MaterialPack bean;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AiClipProvider>();
    final ratios = provider.videoRatioBeans;
    final selectedRatio =
        ratios.firstWhere((ratio) => ratio.id == provider.selectedRatioId);
    final scale = selectedRatio.scale;
    final isProt = ByStringUtils.isPort(scale);
    final selectedClipMaterials =
        context.select<AiMaterialProvider, List<MaterialPack>>(
      (value) => value.selectedClipMaterials,
    );
    final selected = selectedClipMaterials.map((e) => e.id).contains(bean.id);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final provider = context.read<AiMaterialProvider>();
        provider.selectedShowId = -1;
        provider.updateSelectedShowListItemBeans([]);
        provider.updateSelectedMineMaterialItemBeans([]);
        final modeSingle =
            provider.categoryType == AiMaterialCategoryType.single;
        final selectedClipMaterials = provider.selectedClipMaterials;
        if (!selected && selectedClipMaterials.length >= 5) {
          BotToast.showText(text: "最多选择5个素材");
          return;
        }
        if (modeSingle && selectedClipMaterials.isNotEmpty && !selected) {
          // BotToast.showText(text: "单素材模式下只能选择一个素材");
          provider.updateSelectedClipMaterials([bean]);
        } else {
          provider.updateSelectedClipMaterialsWithMaterialBean(bean);
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: ByWidgetsUtil.commonContainer(
              bgColor: const Color(0xFFFFFFFF),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              borerRadius: 12.w,
              border: Border.all(
                width: 1,
                color: selected
                    ? ByColorUtil.TabTextColorSelected
                    : const Color(0xFFF3F5F9),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.w),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: bean.coverUrl,
                          width: 44.w,
                          height: 44.w,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 24,
                            child: ByWidgetsUtil.gradientBgContainer(
                                borderRadius: 0,
                                gradient: ByColorUtil.lineareGradient(
                                  colorStart:
                                      const Color(0xFF000000).withOpacity(0.8),
                                  colorEnd:
                                      const Color(0xFF000000).withOpacity(0),
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                padding: EdgeInsets.only(bottom: 2.h),
                                alignment: Alignment.bottomCenter,
                                child: ByWidgetsUtil.commonText(
                                  text: isProt ? "竖屏" : "横屏",
                                  textColor: ByColorUtil.WhiteColor,
                                  fontSize: 11.sp,
                                )))
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            // ByWidgetsUtil.commonContainer(
                            //   borerRadius: 3.w,
                            //   bgColor:
                            //       ByColorUtil.CommonTextColor.withOpacity(0.3),
                            //   padding: EdgeInsets.symmetric(
                            //       horizontal: 3.w, vertical: 1.h),
                            //   child: ByWidgetsUtil.commonText(
                            //     text: isProt ? "竖屏" : "横屏",
                            //     textColor: ByColorUtil.WhiteColor,
                            //     fontSize: 10.sp,
                            //   ),
                            // ),
                            // SizedBox(width: 4.w),
                            Expanded(
                              child: ByWidgetsUtil.commonText(
                                  text: bean.materialName,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                        SizedBox(height: 10.h),
                        ByWidgetsUtil.commonRichText(
                          texts: [
                            const TextSpan(text: "云端时长"),
                            TextSpan(
                              text: bean.duration,
                              style: const TextStyle(
                                color: ByColorUtil.TabTextColorSelected,
                              ),
                            ),
                          ],
                          textColor: const Color(0xFFA0A3AE),
                          fontSize: 10.sp,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Offstage(
              offstage: !selected,
              child: ByWidgetsUtil.svgAsset(
                filePath: "assets/ai/clip/ai_clip_icon_ratio_selected.svg",
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AiClipMaterialRatioCell extends StatelessWidget {
  const AiClipMaterialRatioCell({
    super.key,
    required this.index,
    required this.bean,
    required this.controller,
  });
  final int index;
  final AiCartoonVideoRatioBean bean;

  final EasyRefreshController controller;

  @override
  Widget build(BuildContext context) {
    final selectedRatioId = context.select<AiClipProvider, int>(
      (value) => value.selectedRatioId,
    );
    final selected = bean.id == selectedRatioId;
    final icon =
        "assets/ai/ai_cartoon_video_ratio_${bean.scale.replaceAll(":", "_")}.png";
    final ratio = bean.scale;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        log("===点击了===");
        final provider = context.read<AiClipProvider>();
        provider.updateSelectedRatioId(bean.id);
        final configBean =
            provider.configBeanFromType(AiCartoonItemBeanType.ratio);
        if (configBean != null) {
          provider.updateSectionConfigBeansFrom(configBean, bean.scale);
        }
        // EasyLoading.show();
        final providerMaterial = context.read<AiMaterialProvider>();
        providerMaterial.resetClipPage();
        providerMaterial.updateSelectedClipMaterials([]);
        // controller.callRefresh();
      },
      child: Stack(
        children: [
          SizedBox(
            height: 44.h,
            child: ByWidgetsUtil.commonContainer(
              bgColor: const Color(0xFFF8FAFB),
              borerRadius: 12.w,
              border: Border.all(
                color: selected
                    ? ByColorUtil.TabTextColorSelected
                    : const Color(0xFFF8FAFB),
                width: 2,
              ),
              child: Row(
                children: [
                  SizedBox(width: 20.w),
                  Image.asset(
                    icon,
                    width: 24,
                    height: 24,
                  ),
                  SizedBox(width: 15.w),
                  ByWidgetsUtil.commonText(
                    text: ratio,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ),
          if (selected)
            Positioned(
              right: 0,
              top: 0,
              child: ByWidgetsUtil.svgAsset(
                filePath: "assets/ai/clip/ai_clip_icon_ratio_selected.svg",
                width: 24,
                height: 24,
              ),
            ),
        ],
      ),
    );
  }
}
