

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/common_ui.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/Me/AboutUs/controllers/about_us_controller.dart';
import '../../../../generated/assets.dart';
import '../../../../utils/comon/by_widgets_util.dart';
import '../../../../widgets/form/custom_text_form_field.dart';

class AboutUsPage extends GetView<AboutUsController> {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "关于我们"),
      backgroundColor: ByColorUtil.colorF8FAFB,
      body: _buildView(),
    );
  }

  _buildView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 70.w),
        Image.asset(
          // "assets/images/logo.png",
          Assets.loginDenglulogo,
          width: 120.w,
          height: 120.w,
        ),
        SizedBox(height: 20.w),
        ByWidgetsUtil.commonText(
          text:  "妙笔工坊",
          fontSize: 18, 
          fontWeight: BYFontWeight.semiBold,
          textColor: ByColorUtil.color0B1843,
        ),
        SizedBox(height: 9.w),
        ByWidgetsUtil.commonText(
          text:  controller.getCurrentVersonString(),
          fontSize: 14, 
          textColor: ByColorUtil.color0B1843.withOpacity(0.5),
        ),
        SizedBox(height: 50.w),

        _buildConfigView(),

        const Spacer(),
        ByWidgetsUtil.commonText(
          text: "版权所有 © 2023 Video Clip Edit",
          fontSize: 16, 
          textColor: ByColorUtil.color0B1843.withOpacity(0.5),
        ),
        SizedBox(height: 20.w),
      ],
    );
  }

  Widget _buildConfigView() {
    return radiusView(
      // margin: EdgeInsets.only(top: 15.h),
      padding: EdgeInsets.only(left: 13.w, right: 9.5.w),
      backgroundColor: ByColorUtil.WhiteColor,
      border: Border.all(color: ByColorUtil.colorEAEEFF, width: 0.5.w),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.aboutUsList.length,
        itemBuilder: (context, index) {
          return buildTextFormView(
              controller.aboutUsList[index],
              CustomTextFieldType.choose,
              enable: true,
              padding: EdgeInsets.symmetric(vertical: 17.h),
              showDivider: index != controller.aboutUsList.length - 1,
              titleStyle:
                  BYTextStyle.instance(14.sp, fontWeight: BYFontWeight.regular),
              subTitleStyle: BYTextStyle.instance(14.sp),
              arrowWidget: Image.asset(
                Assets.commonArrowRight,
                width: 12.w,
                height: 12.w,
              ),
              onTap: () {
                controller.jumpToPage(index);
              },
            );
        },
      ),
    );
  }
}