import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_picture_style_bean.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/picture/picture_style_cell.dart';

///画面风格
class PictureStyleView extends StatelessWidget {
  const PictureStyleView({
    super.key,
    required this.pictureStyleList,
    required this.selectStyleBean,
    this.selectAction,
    this.themeColor,
  });

  final List<AICreatePictureStyleBean> pictureStyleList;

  final Rx<AICreatePictureStyleBean?> selectStyleBean;

  final ValueChanged<AICreatePictureStyleBean>? selectAction;

  final Color? themeColor;

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: Padding(
        padding: EdgeInsets.only(top: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  Assets.aiAiDrawIconStyle,
                  width: 15.w,
                  height: 15.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 6.w),
                BYText.instance('画面风格', 16.sp,
                    color: ByColorUtil.color0B1843,
                    fontWeight: BYFontWeight.semiBold),
              ],
            ),
            SizedBox(height: 11.h),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                child: Row(
                  children: pictureStyleList.map((pictureStyleBean) {
                    final index = pictureStyleList.indexOf(pictureStyleBean);
                    return Container(
                      margin: EdgeInsets.only(
                          right: index != pictureStyleList.length - 1
                              ? 8.w
                              : 0),
                      child: PictureStyleCell(
                        pictureStyleBean: pictureStyleBean,
                        selectStyleBean: selectStyleBean,
                        selectAction: selectAction,
                        themeColor: themeColor,
                      ),
                    );
                  }).toList(),
                )),
          ],
        ),
      ),
    );
  }
}
