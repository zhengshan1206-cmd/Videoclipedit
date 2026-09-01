import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/base_view.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/minorMode/controllers/minor_controller.dart';
import 'package:video_clip_edit/v2/minorMode/widgets/minor_feature_row.dart';
import 'package:video_clip_edit/widgets/common_button.dart';

class MinorPage extends GetView<MinorController> {
  const MinorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      isTransparentAppBar: true,
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              MinorController.backgroundAsset,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(child: _buildContent()),
                _buildBottomSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          Image.asset(
            MinorController.headerAsset,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          SizedBox(height: 36.h),
          ...List.generate(
            controller.features.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index == controller.features.length - 1 ? 0 : 28.h,
              ),
              child: MinorFeatureRow(item: controller.features[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNoticeText(),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: CommonButton(
              padding: EdgeInsets.zero,
              minSize: 50.h,
              borderRadius: BorderRadius.circular(12.h),
              color: const Color(0xFFFE2B54),
              onPressed: controller.enableMinorMode,
              child: BYText.instance(
                MinorController.enableButtonText,
                17.sp,
                color: ByColorUtil.WhiteColor,
                fontWeight: BYFontWeight.semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeText() {
    return SizedBox(
      width: double.infinity,
      child: Text.rich(
        TextSpan(
          text: MinorController.noticePrefix,
          style: BYTextStyle.instance(
            13.sp,
            color: ByColorUtil.CommonTextColor.withOpacity(0.45),
          ),
          children: [
            TextSpan(
              text: MinorController.noticeTitle,
              style: BYTextStyle.instance(13.sp, color: const Color(0xFF4B7CFF)),
              recognizer: TapGestureRecognizer()
                ..onTap = controller.openMinorNotice,
            ),
          ],
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}
