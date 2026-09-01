import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';

class AiClipMaterialTabView extends StatelessWidget {
  const AiClipMaterialTabView({
    super.key,
    required this.controller,
    required this.items,
  });

  final PageController controller;
  final List<String> items;
  @override
  Widget build(BuildContext context) {
    final currentType = context.select<AiMaterialProvider, AiMaterialType>(
        (value) => value.currentType);
    return Container(
      height: 44.h,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.w),
        child: Row(
          children: items.map(
            (e) {
              final index = items.indexOf(e);
              final selected = items.length == 2
                  ? (index ==
                      ((currentType == AiMaterialType.mine)
                          ? currentType.rawValue - 2
                          : currentType.rawValue - 1))
                  : (index == currentType.rawValue - 1);
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final provider = context.read<AiClipProvider>();
                    // final providerMaterial = context.read<AiMaterialProvider>();
                    switch (index) {
                      case 0:
                        // providerMaterial.selectedShowId = -1;
                        // providerMaterial.updateSelectedShowListItemBeans([]);
                        // providerMaterial
                        //     .updateSelectedMineMaterialItemBeans([]);
                        break;
                      case 1:
                        if (items.length != 2) {
                          final ratioBean = provider.videoRatioBeans
                              .firstWhere((e) => e.scale == "9:16");
                          provider.updateSelectedRatioId(ratioBean.id);
                          final configBean = provider
                              .configBeanFromType(AiCartoonItemBeanType.ratio);
                          if (configBean != null) {
                            provider.updateSectionConfigBeansFrom(
                              configBean,
                              ratioBean.scale,
                            );
                          }

                          // providerMaterial.updateSelectedClipMaterials([]);
                          // providerMaterial
                          //     .updateSelectedMineMaterialItemBeans([]);
                        }

                        break;
                      case 2:
                        // providerMaterial.selectedShowId = -1;
                        // providerMaterial.updateSelectedClipMaterials([]);
                        // providerMaterial.updateSelectedShowListItemBeans([]);
                        break;
                      default:
                    }

                    controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.fastEaseInToSlowEaseOut,
                    );

                    if (items.length != 2) {
                      context.read<AiMaterialProvider>().updateMaterialType(
                            AiMaterialTypeExt.typeFromRawValue(index + 1),
                          );
                    } else {
                      context.read<AiMaterialProvider>().updateMaterialType(
                            AiMaterialTypeExt.typeFromRawValue(
                                index == 0 ? index + 1 : index + 2),
                          );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 0.5),
                    color: selected
                        ? ByColorUtil.TabTextColorSelected
                        : const Color(0xFFEAEEFF),
                    alignment: Alignment.center,
                    child: ByWidgetsUtil.commonText(
                      text: e,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      textColor: selected
                          ? ByColorUtil.WhiteColor
                          : ByColorUtil.CommonTextColor,
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
