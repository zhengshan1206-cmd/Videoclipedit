import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_material_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_show_list_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';

class AiClipMaterialShowsBottomBar extends StatelessWidget {
  const AiClipMaterialShowsBottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final selectedShowId = context.select<AiMaterialProvider, int>(
      (value) => value.selectedShowId,
    );
    String selectedShowName = "";
    if (selectedShowId != -1) {
      final List<AiMaterialItemBean> showMaterialItemBeans =
          context.read<AiMaterialProvider>().showMaterialItemBeans;
      for (var e in showMaterialItemBeans) {
        for (var show in e.materialPack) {
          if (show.id == selectedShowId) {
            selectedShowName = show.materialName;
          }
        }
      }
    }
    final count = context
        .select<AiMaterialProvider, List<AiShowListItemBean>>(
            (value) => value.selectedShowListBeans)
        .length;
    return PhysicalModel(
      color: Colors.black,
      child: ByWidgetsUtil.commonContainer(
        borerRadius: 0,
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          top: 8.h,
          bottom: 8.h + ByScreenUtils.bottomSafeHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50.h,
              child: ByWidgetsUtil.commonBtn(
                title: "确定选择",
                fontSize: 16.sp,
                borderRadius: 12.w,
                fontWeight: FontWeight.w500,
                onClick: () {
                  ByNavRouterUtils.goBack(context);
                },
              ),
            ),
            SizedBox(height: 10.h),
            ByWidgetsUtil.commonRichText(
              texts: [
                const TextSpan(text: "已选择短剧"),
                TextSpan(
                    text: "【$selectedShowName】",
                    style: const TextStyle(
                      color: ByColorUtil.TabTextColorSelected,
                    )),
                const TextSpan(text: "中"),
                TextSpan(
                  text: "$count",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ByColorUtil.TabTextColorSelected,
                  ),
                ),
                const TextSpan(text: "个片段。"),
              ],
              textColor: const Color(0xFFA0A3AE),
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
            )
          ],
        ),
      ),
    );
  }
}
