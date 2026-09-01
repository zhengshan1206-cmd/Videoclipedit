import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/ai_create_text_field_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_controller.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/slicing/widget/text_field_view.dart';
import 'package:video_clip_edit/v2/slicing/controller/slicing_home_controller.dart';
import 'package:video_clip_edit/v2/slicing/controller/contents_generating_controller.dart';

class ContentsGeneratingPage extends StatefulWidget {
  const ContentsGeneratingPage({
    super.key,
    this.hideBottomInfo = false,
    this.cartoonProvider,
    this.showExtraBtns = false,
    this.onPaste,
    this.onClear,
    this.onDone,
  });
  final bool hideBottomInfo;

  final AiCartoonProvider? cartoonProvider;

  final bool showExtraBtns;

  final ValueChanged<String>? onPaste;

  final VoidCallback? onClear;
  final VoidCallback? onDone;

  @override
  State<ContentsGeneratingPage> createState() => _ContentsGeneratingPageState();
}

class _ContentsGeneratingPageState extends State<ContentsGeneratingPage> {
  final SlicingHomeController homeController =
      Get.find<SlicingHomeController>();

  final ContentsGeneratingController controller =
      Get.put(ContentsGeneratingController());

  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    /// 设置故事主题为当前prompt
    controller.storyTheme = homeController.currentPrompt.value;

    /// 开始订阅流式输出
    _onReGenerate();
  }

  _onReGenerate() {
    homeController.contentsAiGenerated.value = "";
    widget.cartoonProvider?.desc = "";
    widget.cartoonProvider?.slicingGenerating = true;

    controller.subsequentAuto(
      storyTheme: controller.storyTheme,
      mainPlot: controller.mainPlot ?? "",
      wordsLimit: 800,
      onValueChanged: (value) {
        homeController.contentsAiGenerated.value += (value as String);
        widget.cartoonProvider?.desc = homeController.contentsAiGenerated.value;

        _scrollToBottom();
      },
      onDone: () {
        _scrollToBottom();
        _onGenerateDone();
      },
    );
  }

  void _onGenerateDone() {
    widget.cartoonProvider?.slicingGenerating = false;
    final contents = controller.textController.text;
    if (Get.isRegistered<CreateFolkStoryController>()){
      final stroyController = Get.find<CreateFolkStoryController>();
      stroyController.isSlicingGenerating.value = false;
    
      stroyController.folkStoryCreateRequest.content = contents;
      stroyController.isExpand.value = false;
    }
    
    final textFieldController = Get.find<AiCreateTextFieldController>();
    String value = contents;
    if (value.length > textFieldController.limit) {
      value = value.substring(0, textFieldController.limit);
    }

    textFieldController.textController.text = value;
    textFieldController.inputText.value = value;
    textFieldController.hasGenerating.value = true;
    textFieldController.storyTheme = controller.storyTheme;

    /// 跳转到民间故事
    // Future.delayed(const Duration(milliseconds: 100), () {
    //   Get.offNamed(
    //     Routes.createFolkStoryPage,
    //     arguments: {
    //       "contents": homeController.contentsAiGenerated.value,
    //       "expand": true,
    //       "storyTheme": controller.storyTheme,
    //     },
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SizedBox(height: 17.h),
        // ByWidgetsUtil.commonText(
        //   text: "剧本内容：",
        //   fontWeight: FontWeight.w600,
        // ),
        // SizedBox(height: 10.h),
        Expanded(
          child: ByWidgetsUtil.commonContainer(
            bgColor: ByColorUtil.colorF9FAFF,
            border: Border.all(
              color: ByColorUtil.colorEAEEFF,
              width: 0.5.w,
            ),
            borerRadius: 12.w,
            // child: Container(),
            child: TextFieldView(
              scrollController: scrollController,
              showExtraBtns: widget.showExtraBtns,
              onChanged: (value) {
                widget.cartoonProvider?.desc = value;
              },
              onValueChanged: (value) {
                _scrollToBottom();
              },
              onDone: () {
                widget.cartoonProvider?.slicingGenerating = false;
                Future.delayed(
                    const Duration(milliseconds: 70), _scrollToBottom);
                widget.onDone?.call();
              },
              onClear: () {
                widget.cartoonProvider?.desc = "";
                widget.onClear?.call();
              },
              onRegenerate: () {
                _onReGenerate();
              },
              onPaste: (value) {
                widget.cartoonProvider?.desc = value;
                widget.onPaste?.call(value);
              },
            ),
          ),
        ),
        if (!widget.hideBottomInfo) SizedBox(height: 12.h),
        if (!widget.hideBottomInfo)
          Center(
            child: ByWidgetsUtil.commonText(
              text: "内容由AI生成仅供参考，禁止利用功能从事违法活动。",
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
              textColor: ByColorUtil.color0B1843.withOpacity(0.5),
            ),
          ),
        if (!widget.hideBottomInfo) SizedBox(height: 10.h),
        if (!widget.hideBottomInfo)
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.w),
                color: const Color(0xFF2E54FF).withOpacity(0.1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/mine/icon_info.png",
                    width: 12.w,
                    height: 12.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 5.w),
                  ByWidgetsUtil.commonText(
                    text: "剧本生成中，大约需要60S，请勿退出此页面",
                    maxLines: 100,
                    fontSize: 12.sp,
                    textColor: const Color(0xFF5A4BF7),
                  ),
                ],
              ),
            ),
          ),
        if (!widget.hideBottomInfo)
          SizedBox(height: 15.h + ByScreenUtils.bottomSafeHeight),
      ],
    );
    // return BaseView(
    //   title: '民间故事',
    //   leadingAction: controller.back,
    //   hasFlexibleSpace: true,
    //   child: Padding(
    //     padding: EdgeInsets.symmetric(horizontal: 12.w),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         SizedBox(height: 17.h),
    //         ByWidgetsUtil.commonText(
    //           text: "剧本内容：",
    //           fontWeight: FontWeight.w600,
    //         ),
    //         SizedBox(height: 10.h),
    //         Expanded(
    //           child: ByWidgetsUtil.commonContainer(
    //             bgColor: ByColorUtil.colorF9FAFF,
    //             border: Border.all(
    //               color: ByColorUtil.colorEAEEFF,
    //               width: 0.5.w,
    //             ),
    //             borerRadius: 12.w,
    //             // child: Container(),
    //             child: TextFieldView(
    //               scrollController: scrollController,
    //               onValueChanged: (value) {
    //                 _scrollToBottom();
    //               },
    //               onDone: () {
    //                 Future.delayed(
    //                     const Duration(milliseconds: 70), _scrollToBottom);
    //               },
    //             ),
    //           ),
    //         ),
    //         SizedBox(height: 12.h),
    //         Center(
    //           child: ByWidgetsUtil.commonText(
    //             text: "内容由AI生成仅供参考，禁止利用功能从事违法活动。",
    //             fontSize: 12.sp,
    //             fontWeight: FontWeight.normal,
    //             textColor: ByColorUtil.color0B1843.withOpacity(0.5),
    //           ),
    //         ),

    //         /// 重新生成按钮
    //         // SizedBox(height: 14.h),
    //         // Row(
    //         //   mainAxisAlignment: MainAxisAlignment.center,
    //         //   children: [
    //         //     SizedBox(
    //         //       width: 120.w,
    //         //       height: 32.h,
    //         //       child: Obx(() {
    //         //         final isGenerating = controller.isGenerating.value;
    //         //         return ByWidgetsUtil.btnWithIcon(
    //         //           title: "重新生成",
    //         //           iconH: 15.w,
    //         //           iconW: 15.w,
    //         //           fontSize: 14.sp,
    //         //           contentGap: 4.w,
    //         //           borderRadius: 100,
    //         //           padding: EdgeInsets.zero,
    //         //           bgColor: ByColorUtil.colorEAEEFF,
    //         //           fontWeight: FontWeight.normal,
    //         //           textColor: isGenerating
    //         //               ? ByColorUtil.CommonTextColor.withOpacity(0.5)
    //         //               : ByColorUtil.LoginBtnBgColor,
    //         //           iconPath: "assets/v2/slicing/icon_refresh.png",
    //         //           iconColor: isGenerating
    //         //               ? ByColorUtil.CommonTextColor.withOpacity(0.5)
    //         //               : null,
    //         //           onClick: () {
    //         //             if (isGenerating) {
    //         //               return;
    //         //             }
    //         //             _onReGenerate();
    //         //           },
    //         //         );
    //         //       }),
    //         //     ),
    //         //   ],
    //         // ),

    //         SizedBox(height: 10.h),
    //         Center(
    //           child: Container(
    //             padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
    //             decoration: BoxDecoration(
    //               borderRadius: BorderRadius.circular(12.w),
    //               color: const Color(0xFF2E54FF).withOpacity(0.1),
    //             ),
    //             child: Row(
    //               mainAxisSize: MainAxisSize.min,
    //               children: [
    //                 Image.asset(
    //                   "assets/mine/icon_info.png",
    //                   width: 12.w,
    //                   height: 12.w,
    //                   fit: BoxFit.contain,
    //                 ),
    //                 SizedBox(width: 5.w),
    //                 ByWidgetsUtil.commonText(
    //                   text: "剧本生成中，大约需要60S，请勿退出此页面",
    //                   maxLines: 100,
    //                   fontSize: 12.sp,
    //                   textColor: const Color(0xFF5A4BF7),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //         SizedBox(height: 15.h + ByScreenUtils.bottomSafeHeight),
    //       ],
    //     ),
    //   ),
    // );
  }

  void _scrollToBottom() {
    if (!mounted) return;
    // 确保在下一帧滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
