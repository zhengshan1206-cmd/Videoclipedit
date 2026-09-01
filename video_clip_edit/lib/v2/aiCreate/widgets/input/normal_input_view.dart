import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/input/words_counter_controller.dart';

class NormalInputView extends StatefulWidget {
  final int maxWords;
  final bool canInput;
  final String? initialValue;
  final String? placeholder;
  final EdgeInsetsGeometry? padding;
  final void Function(String)? onChanged;
  final void Function(String)? onFinished;
  final Widget Function(BuildContext context)? toolBarBuilder;
  final bool scrollToBottom;
  final bool focusNode;
  final FocusNode? externalFocusNode;

  const NormalInputView({
    super.key,
    this.padding,
    this.placeholder,
    this.toolBarBuilder,
    this.canInput = true,
    required this.maxWords,
    this.initialValue = "",
    this.onChanged,
    this.onFinished,
    this.scrollToBottom = false,
    this.focusNode = true,
    this.externalFocusNode,
  });

  @override
  State<NormalInputView> createState() => _NormalInputViewState();
}

class _NormalInputViewState extends State<NormalInputView> {
  @override
  void initState() {
    final counterController = WordsCounterController();
    counterController.maxWords.value = widget.maxWords;
    counterController.count.value = (widget.initialValue ?? "").length;
    Get.put(counterController);

    super.initState();
  }

  @override
  dispose() {
    Get.delete<WordsCounterController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NormalInputViewInner(
      padding: widget.padding,
      canInput: widget.canInput,
      onChanged: widget.onChanged,
      onFinished: widget.onFinished,
      placeholder: widget.placeholder,
      initialValue: widget.initialValue,
      toolBarBuilder: widget.toolBarBuilder,
      scrollToBottom: widget.scrollToBottom,
      focusNode: widget.focusNode,
      externalFocusNode: widget.externalFocusNode,
    );
  }
}

class NormalInputViewInner extends StatefulWidget {
  const NormalInputViewInner({
    super.key,
    this.padding,
    this.onChanged,
    this.placeholder,
    this.initialValue,
    this.toolBarBuilder,
    this.extractCallback,
    this.canInput = true,
    this.hideExtractBtn = false,
    this.onFinished,
    this.scrollToBottom = false,
    this.focusNode = true,
    this.externalFocusNode,
  });

  final bool canInput;
  final String? placeholder;
  final bool hideExtractBtn;
  final String? initialValue;
  final EdgeInsetsGeometry? padding;
  final void Function()? extractCallback;
  final void Function(String)? onChanged;
  final void Function(String)? onFinished;
  final Widget Function(BuildContext context)? toolBarBuilder;
  final bool scrollToBottom;
  final bool focusNode;
  final FocusNode? externalFocusNode;

  @override
  State<NormalInputViewInner> createState() => _NormalInputViewInnerState();
}

class _NormalInputViewInnerState extends State<NormalInputViewInner> {
  late TextEditingController controller;
  late final FocusNode focusNode;
  late final bool _ownsFocusNode;
  final ScrollController scrollController = ScrollController();

  late var inputValue = (widget.initialValue ?? "").obs;
  late var placeholder = (widget.placeholder ?? "请输入内容").obs;

  final WordsCounterController counterController =
      Get.find<WordsCounterController>();

  @override
  void dispose() {
    controller.removeListener(_textChanged);
    focusNode.removeListener(_focusNodeStatusChanged);
    if (_ownsFocusNode) {
      focusNode.dispose();
    }
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _ownsFocusNode = widget.externalFocusNode == null;
    focusNode = widget.externalFocusNode ?? FocusNode();
    controller = TextEditingController(text: inputValue.value)
      ..addListener(_textChanged);

    Future.microtask(() {
      focusNode.addListener(_focusNodeStatusChanged);
      if (widget.focusNode) {
        focusNode.requestFocus();
      }
      
      if (widget.scrollToBottom && inputValue.value.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    super.initState();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// 失去焦点时更新provider的描述信息
  _focusNodeStatusChanged() {
    // final provider = context.read<AiClipProvider>();
    if (!focusNode.hasFocus) {
      widget.onFinished?.call(controller.text);
    }
  }

  /// 更新字数
  _textChanged() {
    final wordsCount = controller.text.length;
    final maxValue = counterController.maxWords.value;
    if (wordsCount > maxValue) {
      controller.text = controller.text.substring(0, maxValue);
    }

    counterController.count.value = controller.text.length;
    widget.onChanged?.call(controller.text);

    if (widget.scrollToBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: widget.padding,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F8F9),
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Column(
          children: [
            /// 输入框
            Expanded(
              child: buildTextArea(context),
            ),

            /// 工具条
            buildToolBar(context),
            SizedBox(
              height: 5.w,
            ),
          ],
        ),
      ),
    );
  }

  /// 输入框
  Widget buildTextArea(BuildContext context) {
    if (!widget.canInput) {
      return Padding(
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          top: 5.h,
          bottom: 5.h,
        ),
        child: SizedBox(
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              ByWidgetsUtil.commonText(
                text: inputValue.value,
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                textColor: ByColorUtil.CommonTextColor,
                maxLines: 1000000,
              )
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: TextField(
        selectionControls: MaterialTextSelectionControls(),
        maxLines: null,
        autofocus: false,
        focusNode: focusNode,
        scrollController: scrollController,
        // 避免聚焦时系统/框架再上推视图，把顶部标题顶出安全区
        scrollPadding: EdgeInsets.zero,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: ByColorUtil.CommonTextColor,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          isCollapsed: true,
          border: InputBorder.none,
          hintText: placeholder.value,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
            color: ByColorUtil.CommonTextColor.withOpacity(0.3),
          ),
          labelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
            color: ByColorUtil.CommonTextColor,
          ),
        ),
        onChanged: (String value) {},
        controller: controller,
      ),
    );
  }

  /// 输入框内的底部工具条
  Widget buildToolBar(BuildContext context) {
    return widget.toolBarBuilder != null
        ? widget.toolBarBuilder!(context)
        : SizedBox(
            width: ByScreenUtils.screenWidth - 24.w,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                const WordsCounterView(),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    controller.text = "";
                    inputValue.value = controller.text;
                  },
                  child: Container(
                    height: 29.h,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: ByWidgetsUtil.commonText(
                      text: "清空",
                      fontSize: 12.sp,
                      textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                    ),
                  ),
                )
                // SizedBox(width: 5.w),
              ],
            ),
          );
  }
}

class WordsCounterView extends StatelessWidget {
  const WordsCounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WordsCounterController>();
    return Obx(() => Container(
          height: 29.h,
          alignment: Alignment.center,
          child: ByWidgetsUtil.commonText(
            text: "${controller.count.value}/${controller.maxWords.value}",
            fontSize: 12.sp,
            textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
          ),
        ));
  }
}
