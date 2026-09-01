import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/common_ui.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_picture_style_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/picture/ai_create_picture_style_preview.dart';
import 'package:video_clip_edit/widgets/common_button.dart';
import 'package:video_clip_edit/widgets/image/by_image_view.dart';

///画面风格
class PictureStyleCell extends StatelessWidget {
  const PictureStyleCell({
    super.key,
    required this.pictureStyleBean,
    required this.selectStyleBean,
    this.selectAction,
    this.themeColor,
  });

  final AICreatePictureStyleBean pictureStyleBean;

  final Rx<AICreatePictureStyleBean?> selectStyleBean;

  final ValueChanged<AICreatePictureStyleBean>? selectAction;

  final Color? themeColor;

  @override
  Widget build(BuildContext context) {
    Color displayColor = themeColor ?? ByColorUtil.TabTextColorSelected;
    return Obx(() {
      final selectId = selectStyleBean.value?.id;
      final isSelected = selectId != null && selectId == pictureStyleBean.id;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isSelected) return;
          selectAction?.call(pictureStyleBean);
        },
        child: Container(
          width: 108.w,
          height: 108.w,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? displayColor : Colors.white,
              width: 2.w,
            ),
            borderRadius: BorderRadius.circular(12.h),
          ),
          child: Center(
            child: SizedBox(
              width: 100.w,
              height: 100.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.h),
                child: Stack(
                  children: [
                    BYImageView.normal(
                      alignment: Alignment.topCenter,
                      imageUrl: pictureStyleBean.url,
                      width: 100.w,
                      height: 100.w,
                    ),
                    // Positioned.fill(
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(12.h),
                    //       border: isSelected
                    //           ? Border.all(
                    //               color: ByColorUtil.TabTextColorSelected,
                    //               width: 1.5.w,
                    //             )
                    //           : null,
                    //     ),
                    //   ),
                    // ),
                    // if (isSelected)
                    //   Positioned(
                    //     top: 0,
                    //     right: 0,
                    //     child: Image.asset(
                    //       Assets.aiAiCarttonSelected,
                    //       width: 24.w,
                    //       height: 24.w,
                    //       fit: BoxFit.contain,
                    //     ),
                    //   ),
                    if (isSelected)
                      Positioned.fill(
                        child: Center(
                          child: SizedBox(
                            width: 63.w,
                            height: 23.h,
                            child: CommonButton(
                              minSize: 23.h,
                              padding: EdgeInsets.zero,
                              borderRadius: BorderRadius.zero,
                              onPressed: () {
                                if (pictureStyleBean.cases != null && pictureStyleBean.cases?.isNotEmpty == true) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (ctx) => AiCreatePictureStylePreview(
                                      styleBean: pictureStyleBean,
                                    ),
                                  );
                                }
                              },
                              child: (pictureStyleBean.cases != null && pictureStyleBean.cases?.isNotEmpty == true) ? Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: ByColorUtil.colorEAEEFF.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(11.5.h),
                                ),
                                child: BYText.instance('点击查看', 12.sp,
                                    color: displayColor,
                                    fontWeight: BYFontWeight.medium),
                              ) : Container(),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: generalGradient(isReverse: true),
                        ),
                        constraints: BoxConstraints(minHeight: 30.h),
                        child: BYText.instance(
                          pictureStyleBean.title ?? '',
                          14.sp,
                          color: ByColorUtil.WhiteColor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
