import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';

class AiClipMaterialCateoryTabView extends StatelessWidget {
  const AiClipMaterialCateoryTabView({
    super.key,
    required this.items,
  });
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final currentType =
        context.select<AiMaterialProvider, AiMaterialCategoryType>(
            (value) => value.categoryType);
    return ClipRRect(
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
                  final provider = context.read<AiMaterialProvider>();
                  provider.updateMaterialCatgoryType(
                    AiMaterialCategoryTypeExt.typeFromRawValue(index),
                  );
                  if (index == 0 && provider.selectedClipMaterials.length > 1) {
                    provider.updateSelectedClipMaterials(
                        [provider.selectedClipMaterials.first]);
                  }
                },
                child: Container(
                  color: selected
                      ? const Color(0xFFEAEEFF)
                      : const Color(0xFFFFFFFF),
                  alignment: Alignment.center,
                  child: ByWidgetsUtil.commonText(
                    text: e,
                    fontSize: 12.sp,
                    textColor: selected
                        ? ByColorUtil.TabTextColorSelected
                        : ByColorUtil.CommonTextColor,
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
