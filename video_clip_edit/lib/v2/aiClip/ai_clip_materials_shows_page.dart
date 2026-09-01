import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_sample_page.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_material_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_show_list_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_sample_provider.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_materials_shows_list_page.dart';
import 'package:video_clip_edit/v2/aiClip/widgets/ai_clip_material_shows_bottom_bar.dart';

class AiClipMaterialsShowsPage extends StatefulWidget {
  const AiClipMaterialsShowsPage({super.key});

  @override
  State<AiClipMaterialsShowsPage> createState() =>
      _AiClipMaterialsShowsPageState();
}

class _AiClipMaterialsShowsPageState extends State<AiClipMaterialsShowsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final EasyRefreshController _controller = EasyRefreshController(
      controlFinishRefresh: true, controlFinishLoad: true);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Stack(
        clipBehavior: Clip.none,
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
      child: AiClipMaterialShowsBottomBar(),
    );
  }

  Widget _buildContents(BuildContext context) {
    final showMaterialItemBeans =
        context.select<AiMaterialProvider, List<AiMaterialItemBean>>(
      (value) => value.showMaterialItemBeans,
    );
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
        child: ListView.builder(
          padding: EdgeInsets.only(
              bottom: 95.h + ByScreenUtils.bottomSafeHeight + 44.h),
          itemCount: showMaterialItemBeans.length,
          itemBuilder: (context, index) {
            final itemBean = showMaterialItemBeans[index];
            return AiShowMaterialCell(bean: itemBean);
          },
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
    provider.aiShowMaterialsList(
      reset: reset,
      type: provider.currentType.rawValue,
      scale: 4,
      controller: controller,
    );
  }
}

class AiShowMaterialCell extends StatelessWidget {
  final AiMaterialItemBean bean;
  const AiShowMaterialCell({
    super.key,
    required this.bean,
  });

  void _goToSamplePage(BuildContext context) {
    ByNavRouterUtils.push(
      context,
      ChangeNotifierProvider(
        create: (BuildContext context) => AiClipSampleProvider(),
        child: AiClipSamplePage(pid: bean.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// 素材类型
        Stack(
          children: [
            Container(
              color: Colors.white,
              height: 44.h,
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 12.h,
              child: Container(
                  decoration: BoxDecoration(
                    color: ByColorUtil.CommonPageBgColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.w),
                      topRight: Radius.circular(18.w),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
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
                        text: bean.cateName,
                        fontSize: 14.sp,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.bold,
                      ),
                      // SizedBox(width: 5.w),
                      // ByWidgetsUtil.commonText(
                      //   text: "(更多请查看授权专区)",
                      //   fontSize: 12.sp,
                      //   textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                      //   fontWeight: FontWeight.bold,
                      // ),
                      const Spacer(),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _goToSamplePage(context);
                        },
                        child: ByWidgetsUtil.svgAsset(
                          width: 13,
                          height: 13,
                          filePath:
                              "assets/ai/clip/ai_clip_icon_sample_video.svg",
                        ),
                      ),
                      SizedBox(width: 5.w),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _goToSamplePage(context);
                        },
                        child: ByWidgetsUtil.commonText(
                          text: "素材样片",
                          textColor:
                              ByColorUtil.CommonTextColor.withOpacity(0.5),
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                    ],
                  )),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          itemCount: bean.materialPack.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 85 / 32,
          ),
          itemBuilder: (context, index) {
            return AiClipMaterialCell(
              index: index,
              itemBean: bean.materialPack[index],
            );
          },
        )
      ],
    );
  }
}

class AiClipMaterialCell extends StatelessWidget {
  const AiClipMaterialCell({
    super.key,
    required this.index,
    required this.itemBean,
  });

  final int index;
  final MaterialPack itemBean;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AiMaterialProvider>();
    final selectedShowId = context
        .select<AiMaterialProvider, int>((value) => value.selectedShowId);
    final selected = selectedShowId == itemBean.id;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!selected) {
          provider.updateSelectedShowListItemBeans([]);
        }
        provider.selectedShowId = itemBean.id;
        provider.updateSelectedClipMaterials([]);
        provider.updateSelectedMineMaterialItemBeans([]);
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider.value(
              value: provider,
              child: AiClipMaterialsShowsListPage(itemBean: itemBean)),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
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
                    child: CachedNetworkImage(
                      imageUrl: itemBean.coverUrl,
                      width: 44.w,
                      height: 44.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ByWidgetsUtil.commonText(
                            text: itemBean.materialName,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600),
                        SizedBox(height: 10.h),
                        ByWidgetsUtil.commonRichText(
                          texts: [
                            const TextSpan(text: "云端时长"),
                            TextSpan(
                              text: itemBean.duration,
                              style: const TextStyle(
                                color: ByColorUtil.TabTextColorSelected,
                              ),
                            ),
                            // const TextSpan(text: "小时"),
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
            right: 0,
            top: -8.h,
            child: Offstage(
              offstage: !(selected &&
                  context
                      .select<AiMaterialProvider, List<AiShowListItemBean>>(
                        (value) => value.selectedShowListBeans,
                      )
                      .isNotEmpty),
              child: SizedBox(
                height: 16.h,
                child: ByWidgetsUtil.commonContainer(
                  bgColor: const Color(0xFFFF2A70),
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  alignment: Alignment.center,
                  child: ByWidgetsUtil.commonText(
                    text:
                        "已选*${context.select<AiMaterialProvider, List<AiShowListItemBean>>(
                              (value) => value.selectedShowListBeans,
                            ).length}",
                    fontSize: 10.sp,
                    textColor: const Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
