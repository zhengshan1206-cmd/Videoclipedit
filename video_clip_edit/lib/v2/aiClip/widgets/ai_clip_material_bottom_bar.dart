import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_material_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';

class ByAiClipMaterialBottomBar extends StatelessWidget {
  const ByAiClipMaterialBottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PhysicalModel(
          color: Colors.white,
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
                    TextSpan(
                        text:
                            "【${context.select<AiMaterialProvider, AiMaterialCategoryType>(
                                  (value) => value.categoryType,
                                ).description}】",
                        style: const TextStyle(
                          color: ByColorUtil.TabTextColorSelected,
                        )),
                    const TextSpan(text: "模式，共计"),
                    TextSpan(
                      text:
                          "${context.select<AiMaterialProvider, List<MaterialPack>>(
                                (value) => value.selectedClipMaterials,
                              ).length}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ByColorUtil.TabTextColorSelected,
                      ),
                    ),
                    const TextSpan(text: "个素材包。"),
                  ],
                  textColor: const Color(0xFFA0A3AE),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                )
              ],
            ),
          ),
        ),
        Positioned(
          right: 12.w,
          top: -12.h,
          child: Offstage(
            offstage: context
                .select<AiMaterialProvider, List<MaterialPack>>(
                  (value) => value.selectedClipMaterials,
                )
                .isEmpty,
            child: SizedBox(
              height: 24.h,
              child: ByWidgetsUtil.commonContainer(
                bgColor: const Color(0xFFFF2A70),
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                alignment: Alignment.center,
                child: ByWidgetsUtil.commonText(
                  text:
                      "已选${context.select<AiMaterialProvider, List<MaterialPack>>(
                            (value) => value.selectedClipMaterials,
                          ).length}个",
                  fontSize: 12.sp,
                  textColor: const Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
