import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_material_opening_page.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_oepning_video_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_opening_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_local_bean.dart';

class AIClipMaterilaOpeningSelectView extends StatelessWidget {
  const AIClipMaterilaOpeningSelectView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currentType =
        context.select<AiClipOpeningProvider, AiMaterialOpeningType>(
      (value) => value.currentType,
    );
    bool selected = false;
    switch (currentType) {
      case AiMaterialOpeningType.cloud:
        selected = context.select<AiClipOpeningProvider, Detail?>(
              (value) => value.selectedOpeningBean,
            ) !=
            null;
        break;
      case AiMaterialOpeningType.mine:
        selected = context
            .select<AiMaterialProvider, List<AiCartoonBgmLocalBean>>(
              (value) => value.selectedOpeningMaterialItemBeans,
            )
            .isNotEmpty;
        break;
      default:
    }

    return SliverPadding(
      padding: EdgeInsets.only(top: 20.h),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Row(
              children: [
                ByWidgetsUtil.svgAsset(
                  filePath: "assets/ai/clip/ai_clip_material_opening.svg",
                  width: 16,
                  height: 16,
                ),
                SizedBox(width: 5.w),
                ByWidgetsUtil.commonText(
                  fontSize: 16.sp,
                  text: "片头素材",
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 60.h,
              child: ByWidgetsUtil.commonContainer(
                bgColor: const Color(0xFFF8FAFB),
                border: Border.all(
                  color: const Color(0xFFF3F5F9),
                  width: 0.5,
                ),
                borerRadius: 10.w,
                child: selected
                    ? _buildSelectedView(context)
                    : _buildUnselectedView(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildUnselectedView(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ByNavRouterUtils.push(
          context,
          MultiProvider(providers: [
            ChangeNotifierProvider.value(
                value: context.read<AiClipOpeningProvider>()),
            ChangeNotifierProvider.value(value: context.read<AiClipProvider>()),
            ChangeNotifierProvider.value(
                value: context.read<AiMaterialProvider>()),
          ], child: const AiClipMaterialOpeningPage()),
        );
      },
      child: Row(
        children: [
          SizedBox(width: 10.w),
          Image.asset(
            "assets/ai/clip/ai_clip_material_add.png",
            width: 24.w,
            height: 24.h,
          ),
          SizedBox(width: 6.w),
          ByWidgetsUtil.commonText(
            text: "请选择片头素材",
            fontWeight: FontWeight.w500,
          ),
          const Spacer(),
          SizedBox(
            height: 32.h,
            child: ByWidgetsUtil.commonContainer(
              bgColor: const Color(0xFFEAEEFF),
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              alignment: Alignment.center,
              borerRadius: 8.w,
              child: ByWidgetsUtil.commonText(
                text: "去选择",
                fontSize: 12.sp,
                textColor: ByColorUtil.TabTextColorSelected,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }

  _buildSelectedView(BuildContext context) {
    final paddingTop = 6.h;
    final selectedOpeningBean =
        context.read<AiClipOpeningProvider>().selectedOpeningBean;
    final currentType =
        context.select<AiClipOpeningProvider, AiMaterialOpeningType>(
      (value) => value.currentType,
    );
    final isCloud = currentType == AiMaterialOpeningType.cloud;
    final selectedOpeningMaterialItemBeans =
        context.select<AiMaterialProvider, List<AiCartoonBgmLocalBean>>(
      (value) => value.selectedOpeningMaterialItemBeans,
    );
    return Row(
      children: [
        SizedBox(width: 8.w),
        Stack(
          children: [
            Container(
              width: 50.h,
              height: 50.h,
              padding: EdgeInsets.only(top: paddingTop, right: paddingTop),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.w),
                child: CachedNetworkImage(
                  imageUrl: isCloud
                      ? selectedOpeningBean!.coverUrl
                      : selectedOpeningMaterialItemBeans.first.cover,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (isCloud) {
                    // 混剪
                    final providerOpening =
                        context.read<AiClipOpeningProvider>();
                    providerOpening.updateSelectedOpeningBean(null);
                  } else {
                    // 我的
                    final providerOpening = context.read<AiMaterialProvider>();
                    providerOpening.updateSelectedOpeningMaterialItemBeans([]);
                  }
                },
                child: Image.asset(
                  "assets/ai/ai_cartoon_config_close.png",
                  width: 12.h,
                  height: 12.h,
                ),
              ),
            )
          ],
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: paddingTop * 0.5),
            child: ByWidgetsUtil.commonText(
              text: isCloud
                  ? "[混剪]${selectedOpeningBean!.videoTitle}"
                  : "[我的]${selectedOpeningMaterialItemBeans.first.name}",
              fontWeight: FontWeight.normal,
              textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
              fontSize: 14.sp,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: () {
            ByNavRouterUtils.push(
              context,
              MultiProvider(providers: [
                ChangeNotifierProvider.value(
                    value: context.read<AiClipOpeningProvider>()),
                ChangeNotifierProvider.value(
                    value: context.read<AiClipProvider>()),
                ChangeNotifierProvider.value(
                    value: context.read<AiMaterialProvider>()),
              ], child: const AiClipMaterialOpeningPage()),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 32.h,
            child: ByWidgetsUtil.commonContainer(
              bgColor: const Color(0xFFEAEEFF),
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              alignment: Alignment.center,
              borerRadius: 8.w,
              child: ByWidgetsUtil.commonText(
                text: "重新选择",
                fontSize: 12.sp,
                textColor: ByColorUtil.TabTextColorSelected,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  // void _deleteMaterialAtIndex({
  //   required BuildContext context,
  // }) {
  //   final provider = context.read<AiMaterialProvider>();
  //   switch (provider.currentType) {
  //     case AiMaterialType.clip:
  //       provider.updateSelectedClipMaterialsWithMaterialBean(
  //           provider.selectedClipMaterials[index]);
  //       break;
  //     case AiMaterialType.show:
  //       provider.updateSelectedShowListItemBeansWithBean(
  //           provider.selectedShowListBeans[index]);
  //       break;
  //     case AiMaterialType.mine:
  //       provider.updateSelectedMineMaterialItemBeansWithBean(
  //           provider.selectedMineMaterialItemBeans[index]);
  //       break;
  //     default:
  //   }
  // }
}
