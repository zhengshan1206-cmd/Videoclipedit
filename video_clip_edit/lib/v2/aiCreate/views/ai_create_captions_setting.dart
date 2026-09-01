import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/base_view.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/data/model/aiCreate/ai_create_request.dart';
import 'package:video_clip_edit/flavors/app_values.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/ai_create_captions_setting_controller.dart';
import 'package:video_clip_edit/widgets/common_button.dart';
import 'package:video_clip_edit/widgets/image/by_image_view.dart';

class AiCreateCaptionsSetting
    extends GetView<AiCreateCaptionsSettingController> {
  const AiCreateCaptionsSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AiCreateCaptionsSettingController>(builder: (controller) {
      return BaseView(
        title: '字幕设置',
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///todo 民间故事 字幕设置图片
                    Container(
                        width: double.infinity,
                        height: 260.h,
                        color: ByColorUtil.CommonPageBgColor,
                        child: BYImageView(
                          imageUrl: controller.captionSettingImg,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        )),
                    _buildPositionGridView(),
                    _buildRatioTagView(),
                    _buildStyleTagView(),
                    _buildFontTypeGridView(),
                    _buildFontSizeSliderView(),
                  ],
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      );
    });
  }

  ///字幕位置
  _buildPositionGridView() {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BYText.instance('字幕位置', 16.sp, fontWeight: BYFontWeight.semiBold),
          SizedBox(height: 12.h),
          if (controller.captionsConfigBean.position != null)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10.w,

                /// 水平间隔
                mainAxisSpacing: 12.h,

                /// 垂直间隔
                mainAxisExtent: 36.h,
              ),
              itemCount: controller.captionsConfigBean.position!.length,
              itemBuilder: (BuildContext context, int index) {
                final position = controller.captionsConfigBean.position![index];
                return Obx(() {
                  return GestureDetector(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.h),
                        color: controller.selectPosition.value == position
                            ? ByColorUtil.LoginBtnBgColor
                            : ByColorUtil.colorF4F8F9,
                      ),
                      child: BYText.instance('${position.desc}', 14.sp,
                          color: controller.selectPosition.value == position
                              ? Colors.white
                              : ByColorUtil.CommonTextColor),
                    ),
                    onTap: () {
                      controller.selectPosition.value = position;
                      controller.getCaptionSettingImg();
                    },
                  );
                });
              },
            )
        ],
      ),
    );
  }

  ///视频比例
  _buildRatioTagView() {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BYText.instance('视频比例', 16.sp, fontWeight: BYFontWeight.semiBold),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 10.w,

            ///水平方向间距
            runSpacing: 12.h,

            ///垂直方向间距
            children: controller.videoRatioList.map((ratioBean) {
              return Obx(() {
                return GestureDetector(
                  child: Container(
                    width: 60.w,
                    height: 36.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.h),
                      color: controller.selectRatioBean.value == ratioBean
                          ? ByColorUtil.LoginBtnBgColor
                          : ByColorUtil.colorF4F8F9,
                    ),
                    child: BYText.instance('${ratioBean.scale}', 14.sp,
                        color: controller.selectRatioBean.value == ratioBean
                            ? Colors.white
                            : ByColorUtil.CommonTextColor),
                  ),
                  onTap: () {
                    controller.selectRatioBean.value = ratioBean;
                    controller.getCaptionSettingImg();
                  },
                );
              });
            }).toList(),
          ),
        ],
      ),
    );
  }

  ///字幕样式
  _buildStyleTagView() {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BYText.instance('字幕样式', 16.sp, fontWeight: BYFontWeight.semiBold),
          SizedBox(height: 12.h),
          if (controller.captionsConfigBean.style != null)
            Wrap(
              spacing: 10.w,

              ///水平方向间距
              runSpacing: 12.h,

              ///垂直方向间距
              children: controller.captionsConfigBean.style!.map((styleBean) {
                return Obx(() {
                  return GestureDetector(
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ByColorUtil.colorF4F8F9,
                        borderRadius: BorderRadius.circular(8.h),
                        border: Border.all(
                          color: controller.selectStyle.value == styleBean
                              ? ByColorUtil.TabTextColorSelected
                              : Colors.transparent,
                          width: 1.w,
                        ),
                      ),
                      child: BYImageView.normal(
                          imageUrl: styleBean.icon, width: 24.w, height: 24.w),
                    ),
                    onTap: () {
                      controller.selectStyle.value = styleBean;
                      controller.getCaptionSettingImg();
                    },
                  );
                });
              }).toList(),
            ),
        ],
      ),
    );
  }

  ///字体类型
  _buildFontTypeGridView() {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BYText.instance('字体类型', 16.sp, fontWeight: BYFontWeight.semiBold),
          SizedBox(height: 12.h),
          if (controller.captionsConfigBean.fontType != null)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.w,

                /// 水平间隔
                mainAxisSpacing: 12.h,

                /// 垂直间隔
                childAspectRatio: 17 / 5,
              ),
              itemCount: controller.captionsConfigBean.fontType!.length,
              itemBuilder: (BuildContext context, int index) {
                final fontType = controller.captionsConfigBean.fontType![index];
                return Obx(() {
                  return GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.h),
                        border: Border.all(
                          color: controller.selectFontType.value == fontType
                              ? ByColorUtil.TabTextColorSelected
                              : Colors.transparent,
                          width: 1.w,
                        ),
                        color: ByColorUtil.colorF4F8F9,
                      ),
                      child: BYImageView.normal(
                        imageUrl: fontType.url,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                    onTap: () {
                      controller.selectFontType.value = fontType;
                      controller.getCaptionSettingImg();
                    },
                  );
                });
              },
            )
        ],
      ),
    );
  }

  ///字体大小
  _buildFontSizeSliderView() {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.h),
        color: ByColorUtil.colorF8FAFB,
      ),
      child: Row(
        children: [
          BYText.instance('字号', 14.sp, fontWeight: BYFontWeight.medium),
          // Expanded(
          //   child: Obx((){
          //     return CupertinoSlider(
          //       min: 12.0,
          //       max: 16.0,
          //       value: controller.sliderValue.value,
          //       divisions: 4,
          //       activeColor: ByColorUtil.TabTextColorSelected,
          //       thumbColor: ByColorUtil.TabTextColorSelected,
          //       onChanged: (value) {
          //         controller.sliderValue.value = value;
          //       },
          //     );
          //   }),
          // ),
          Expanded(
            child: Obx(() {
              return Slider(
                min: 28.0,
                max: 52.0,
                value: controller.sliderValue.value,
                divisions: 6,
                activeColor: ByColorUtil.TabTextColorSelected,
                inactiveColor: ByColorUtil.CommonTextColor.withOpacity(0.1),
                onChanged: (value) {
                  controller.sliderValue.value = value;
                  controller.getCaptionSettingImg();
                },
              );
            }),
          ),
          Obx(
            () {
              final value = controller.sliderValue.value;
              return BYText.instance('${value.toInt()}', 14.sp);
            },
          ),
        ],
      ),
    );
  }

  _buildBottomButton() {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: PhysicalModel(
        color: Colors.black,
        child: Container(
          width: double.infinity,
          color: ByColorUtil.WhiteColor,
          padding: EdgeInsets.only(
              left: 12.w,
              top: 8.h,
              right: 12.w,
              bottom: safeAreaBottomDistance(15.h)),
          child: CommonButton(
            padding: EdgeInsets.zero,
            minSize: 50.h,
            borderRadius: BorderRadius.circular(12.h),
            color: ByColorUtil.LoginBtnBgColor,
            onPressed: () {
              final captionsSettingBean = CaptionsSettingBean(
                position: controller.selectPosition.value,
                style: controller.selectStyle.value,
                fontType: controller.selectFontType.value,
                fontSize: controller.sliderValue.value.toInt(),
                ratioBean: controller.selectRatioBean.value,
              );
              Get.back(result: captionsSettingBean);
            },
            child: BYText.instance('确定', 16.sp,
                color: ByColorUtil.WhiteColor, fontWeight: BYFontWeight.medium),
          ),
        ),
      ),
    );
  }
}
