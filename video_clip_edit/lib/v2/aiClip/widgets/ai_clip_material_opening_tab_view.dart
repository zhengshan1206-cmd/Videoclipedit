import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_opening_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';

class AiClipMaterialOpeningTabView extends StatelessWidget {
  const AiClipMaterialOpeningTabView({
    super.key,
    required this.controller,
    required this.items,
  });

  final PageController controller;
  final List<String> items;
  @override
  Widget build(BuildContext context) {
    final currentType =
        context.select<AiClipOpeningProvider, AiMaterialOpeningType>(
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
              final selected = index == currentType.rawValue;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    switch (index) {
                      case 0:
                        context
                            .read<AiMaterialProvider>()
                            .updateSelectedOpeningMaterialItemBeans([]);
                        break;
                      case 1:
                        context
                            .read<AiClipOpeningProvider>()
                            .selectedOpeningBean = null;
                        break;
                      default:
                    }
                    controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                    context.read<AiClipOpeningProvider>().updateMaterialType(
                          AiMaterialOpeningTypeExt.typeFromRawValue(index),
                        );
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
