import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/app_util.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/ai_create_text_field_controller.dart';
import 'package:video_clip_edit/widgets/common_button.dart';

///ai创作-文案
class AiCreateTextFieldView extends StatefulWidget {
  const AiCreateTextFieldView({
    super.key,
    this.maxHeight,
    this.limit = 2000,
    this.showExpand = true,
    this.scrollController,
    this.onValueChanged,
    this.onDone,
  });

  final double? maxHeight;
  final int limit;
  final bool showExpand;

  final ScrollController? scrollController;
  final ValueChanged<dynamic>? onValueChanged;
  final VoidCallback? onDone;

  @override
  State<AiCreateTextFieldView> createState() => _AiCreateTextFieldViewState();
}

class _AiCreateTextFieldViewState extends State<AiCreateTextFieldView> {
  final controller = Get.find<AiCreateTextFieldController>();

  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.limit = widget.limit;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AiCreateTextFieldController>(builder: (controller) {
      return Container(
        constraints: widget.maxHeight == null
            ? null
            : BoxConstraints(maxHeight: widget.maxHeight!),
        padding: EdgeInsets.only(top: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ByColorUtil.colorF9FAFF,
          border: Border.all(color: ByColorUtil.colorEAEEFF, width: 0.5.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.showExpand
                ? Obx(() {
                    return controller.showExpand
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: KeyboardDismissOnTap(
                                  dismissOnCapturedTaps: true,
                                  child: CommonButton(
                                    padding: EdgeInsets.only(
                                        left: 10.w, right: 12.w, bottom: 10.h),
                                    minSize: 0,
                                    borderRadius: BorderRadius.zero,
                                    onPressed: () {
                                      Get.toNamed(
                                          Routes.aiCreatePreviewTextFieldPage);
                                    },
                                    child: Image.asset(
                                        Assets.aiIconAiCreateTextExpand,
                                        width: 24.w,
                                        height: 24.w),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container();
                  })
                : Container(),
            _buildTextField(),
            _buildGeneratingView(),
            _buildOperateView(),
          ],
        ),
      );
    });
  }

  ///输入框
  _buildTextField() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Obx(() {
                return TextField(
                  focusNode: focusNode,
                  scrollController:
                      widget.scrollController ?? controller.scrollController,
                  controller: controller.textController,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(widget.limit),
                  ],
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
                    controller.textChanged(value);
                  },
                );
              }),
            ),
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
                              text: '请输入故事内容或者使用',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  focusNode.requestFocus();
                                },
                            ),
                            TextSpan(
                              text: '【AI创作故事】',
                              style: BYTextStyle.instance(14.sp,
                                  color: ByColorUtil.LoginBtnBgColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  ByNavigatorUtil.checkLogin(
                                    context: context, 
                                    nextStepEvent: (){
                                      controller.aiAutoGeneration(
                                      onValueChanged: widget.onValueChanged,
                                      onDone: widget.onDone);
                                    });
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
      ),
    );
  }

  ///生成中视图
  _buildGeneratingView() {
    return Obx(() {
      return controller.isGenerating.value
          ? IntrinsicWidth(
              child: Padding(
                padding: EdgeInsets.only(left: 12.w, top: 4.h),
                child: CommonButton(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  minSize: 24.h,
                  borderRadius: BorderRadius.circular(6.h),
                  spacing: 6.w,
                  suffixDirectional: SuffixDirectional.right,
                  suffixWidget: ByWidgetsUtil.activityIndicator(radius: 8.w),
                  color: ByColorUtil.color3753FF.withOpacity(0.1),
                  child: BYText.instance('正在创作中', 12.sp,
                      color: ByColorUtil.LoginBtnBgColor),
                ),
              ),
            )
          : Container();
    });
  }

  ///操作按钮视图
  _buildOperateView() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(13.r),
          bottomRight: Radius.circular(13.r),
        ),
      ),
      padding: EdgeInsets.only(left: 5.w, top: 5.h, right: 10.w, bottom: 5.h),
      child: Row(
        children: [
          Obx(() {
            return !controller.showRegenerate
                ? Container()
                : KeyboardDismissOnTap(
                    dismissOnCapturedTaps: true,
                    child: CommonButton(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      minSize: 24.h,
                      spacing: 4.w,
                      borderRadius: BorderRadius.circular(12.h),
                      suffixDirectional: SuffixDirectional.left,
                      suffixWidget: Image.asset(
                        Assets.aiIconAiCreateTextAuto,
                        width: 12.w,
                        height: 12.w,
                      ),
                      color: ByColorUtil.colorF0F2F9,
                      onPressed: () {
                        controller.subsequentAuto(
                          storyTheme: controller.storyTheme,
                          mainPlot: controller.mainPlot,
                          onValueChanged: widget.onValueChanged,
                          onDone: widget.onDone,
                        );
                      },
                      child: BYText.instance('重新生成', 12.sp,
                          color: ByColorUtil.CommonTextColor.withOpacity(0.5)),
                    ),
                  );
          }),
          SizedBox(width: 5.w),
          Obx(() {
            return controller.isGenerating.value
                ? Container()
                : KeyboardDismissOnTap(
                    dismissOnCapturedTaps: true,
                    child: CommonButton(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      minSize: 24.h,
                      spacing: 4.w,
                      borderRadius: BorderRadius.circular(12.h),
                      suffixDirectional: SuffixDirectional.left,
                      // suffixWidget: Image.asset(
                      //   Assets.aiIconAiCreateTextPaste,
                      //   width: 12.w,
                      //   height: 12.w,
                      // ),
                      color: ByColorUtil.colorF0F2F9,
                      onPressed: controller.paste,
                      child: BYText.instance('粘贴', 12.sp,
                          color: ByColorUtil.CommonTextColor.withOpacity(0.5)),
                    ),
                  );
          }),
          const Spacer(),
          Obx(
            () {
              final textCount = controller.inputText.value.length;
              return BYText.instance('$textCount/${widget.limit}', 12.sp,
                  color: ByColorUtil.CommonTextColor.withOpacity(0.5));
            },
          ),
          SizedBox(width: 8.w),
          Obx(() {
            return controller.isGenerating.value
                ? Container()
                : KeyboardDismissOnTap(
                    dismissOnCapturedTaps: true,
                    child: CommonButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: clearORNot,
                      child: BYText.instance('清空', 12.sp,
                          color: ByColorUtil.CommonTextColor.withOpacity(0.5),
                          height: 1.0),
                    ),
                  );
          }),
        ],
      ),
    );
  }

  //输入框清空操作
  clearORNot(){
    if (controller.isGenerating.value || controller.inputText.value.isNotEmpty) {
      Get.normalDialog(
        width: Get.width * 0.85,
        title: '温馨提示',
        content: '文案生成中，清空后无法保存，\n确定要清空吗？',
        confirmText: '确定',
        confirmAction: () {
          controller.clear();
        },
      );
      return;
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}
