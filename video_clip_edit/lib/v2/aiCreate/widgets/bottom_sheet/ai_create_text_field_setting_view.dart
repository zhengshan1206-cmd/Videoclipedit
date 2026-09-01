import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/flavors/app_values.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/ai_create_text_field_setting_controller.dart';
import 'package:video_clip_edit/widgets/common_button.dart';

typedef PaperWorkAction = void Function(String? storyTheme, String? mainPlot);

///ai创作自动生成文案设置
class AiCreateTextFieldSettingView extends StatefulWidget {
  const AiCreateTextFieldSettingView({
    super.key,
    required this.valueAction,
    required this.themeId,
  });

  final PaperWorkAction valueAction;
  final String themeId;

  static void show(PaperWorkAction valueAction, String themeId) {
    Get.bottomSheet(
      AiCreateTextFieldSettingView(valueAction: valueAction, themeId: themeId,),
      barrierColor: ByColorUtil.BlackColor.withOpacity(0.3),
      ignoreSafeArea: true,
      isScrollControlled: true,
    );
  }

  @override
  State<AiCreateTextFieldSettingView> createState() =>
      _AiCreateTextFieldSettingViewState();
}

class _AiCreateTextFieldSettingViewState
    extends State<AiCreateTextFieldSettingView> {
  final controller = Get.put(AiCreateTextFieldSettingController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AiCreateTextFieldSettingController>(
        builder: (controller) {
      return Container(
        margin: EdgeInsets.only(top: 12.h),
        padding: EdgeInsets.only(
            left: 12.w, right: 12.w, bottom: safeAreaBottomDistance(15.h)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.h), topRight: Radius.circular(18.h)),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: BYText.instance('AI故事创作', 16.sp,
                      fontWeight: BYFontWeight.semiBold),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: CommonButton(
                    padding: EdgeInsets.only(
                        left: 10.w, top: 20.h, right: 3.w, bottom: 20.h),
                    minSize: 0,
                    borderRadius: BorderRadius.zero,
                    onPressed: Get.back,
                    child: Image.asset(Assets.commonIconBottomSheetClose,
                        width: 14.w, height: 14.w),
                  ),
                ),
              ],
            ),
            BYText.instance('1、故事主题', 14.sp, fontWeight: BYFontWeight.medium),
            _buildStoryThemeField(),
            _buildMainPlotTitle(),
            _buildMainPlotField(),
            _buildButton(),
          ],
        ),
      );
    });
  }

  ///故事主题
  _buildStoryThemeField() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
      constraints: BoxConstraints(minHeight: 44.h, maxHeight: 60.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.h),
          color: ByColorUtil.colorF4F8F9),
      child: Stack(
        children: [
          Obx(() {
            return TextField(
              scrollController: controller.scrollController,
              focusNode: controller.focusNode,
              controller: controller.storyThemeController,
              selectionControls: MaterialTextSelectionControls(),
              maxLines: null,
              enabled: !controller.isGenerating.value,
              style: BYTextStyle.instance(14.sp,
                  color: ByColorUtil.CommonTextColor),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
                border: InputBorder.none,
                hintStyle: BYTextStyle.instance(14.sp,
                    color: ByColorUtil.CommonTextColor.withOpacity(0.5)),
              ),
              onChanged: (value) {
                controller.inputText.value = value;
              },
            );
          }),
          Obx(() {
            return controller.showHintText
                ? Positioned(
                    top: 0,
                    left: 0,
                    child: RichText(
                      text: TextSpan(
                        style: BYTextStyle.instance(14.sp,
                            color:
                                ByColorUtil.CommonTextColor.withOpacity(0.5)),
                        children: [
                          TextSpan(
                            text: '请输入故事主题，没有灵感',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                controller.focusNode.requestFocus();
                              },
                          ),
                          TextSpan(
                            text: 'DeepSeek帮我写',
                            style: BYTextStyle.instance(14.sp,
                                color: ByColorUtil.LoginBtnBgColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                controller.aiAutoGeneration(
                                  storyId: widget.themeId
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox();
          }),
        ],
      ),
    );
  }

  ///故事内容
  _buildMainPlotField() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
      height: 160.h,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.h),
          color: ByColorUtil.colorF4F8F9),
      child: TextField(
        controller: controller.mainPlotController,
        selectionControls: MaterialTextSelectionControls(),
        maxLines: null,
        style: BYTextStyle.instance(14.sp, color: ByColorUtil.CommonTextColor),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          isCollapsed: true,
          border: InputBorder.none,
          hintMaxLines: 6,
          hintText:
              '请输入故事的主要情节，AI讲围绕您给出的主要故事情节进行创作。',
          hintStyle: BYTextStyle.instance(14.sp,
              color: ByColorUtil.CommonTextColor.withOpacity(0.3)),
        ),
      ),
    );
  }

  _buildMainPlotTitle() {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      child: RichText(
        text: TextSpan(
          style: BYTextStyle.instance(14.sp),
          children: [
            const TextSpan(
              text: '2、故事主要情节',
            ),
            TextSpan(
              text: '（选填）',
              style: BYTextStyle.instance(12.sp,
                  color: ByColorUtil.CommonTextColor.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }

  _buildButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 8.h),
      child: CommonButton(
        padding: EdgeInsets.zero,
        minSize: 50.h,
        borderRadius: BorderRadius.circular(12.h),
        color: ByColorUtil.LoginBtnBgColor,
        onPressed: () {
          if (controller.storyThemeController.text.isEmpty) {
            BotToast.showText(text: "请输入故事主题");
            return;
          }
          Get.back();
          widget.valueAction.call(controller.storyThemeController.text,
              controller.mainPlotController.text);
        },
        child: BYText.instance('确定', 16.sp,
            color: Colors.white, fontWeight: BYFontWeight.medium),
      ),
    );
  }
}
