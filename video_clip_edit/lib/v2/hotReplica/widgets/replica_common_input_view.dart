// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_input_mixin.dart';

class ReplicaCommonInputView<T extends AiInputMixin> extends StatelessWidget {
  final EdgeInsetsGeometry? padding;

  const ReplicaCommonInputView({
    super.key,
    this.padding,
    this.onFoucusChanged,
    required this.maxWords,
  });

  final int maxWords;
  final void Function(bool, String)? onFoucusChanged;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WordsCounter(),
      child: ReplicaCommonInputViewInner<T>(
        padding: padding,
        maxWords: maxWords,
        onFoucusChanged: onFoucusChanged,
      ),
    );
  }
}

class ReplicaCommonInputViewInner<T extends AiInputMixin>
    extends StatefulWidget {
  const ReplicaCommonInputViewInner({
    super.key,
    this.padding,
    this.extractCallback,
    this.onFoucusChanged,
    this.hideExtractBtn = false,
    required this.maxWords,
  });

  final EdgeInsetsGeometry? padding;
  final void Function()? extractCallback;
  final void Function(bool, String)? onFoucusChanged;
  final bool hideExtractBtn;
  final int maxWords;

  @override
  State<ReplicaCommonInputViewInner> createState() =>
      _ReplicaCommonInputViewInnerState<T>();
}

class _ReplicaCommonInputViewInnerState<T extends AiInputMixin>
    extends State<ReplicaCommonInputViewInner<T>> {
  late TextEditingController controller;
  late final FocusNode focusNode = FocusNode();
  // final int maxWords = 2000;

  @override
  void dispose() {
    controller.removeListener(_textChanged);

    focusNode.removeListener(_focusNodeStatusChanged);
    super.dispose();
  }

  @override
  void initState() {
    controller = TextEditingController(text: context.read<T>().inputValue)
      ..addListener(_textChanged);

    Future.microtask(() {
      focusNode.unfocus();
      focusNode.addListener(_focusNodeStatusChanged);
    });

    super.initState();
  }

  /// 失去焦点时更新provider的描述信息
  _focusNodeStatusChanged() {
    final provider = context.read<T>();
    widget.onFoucusChanged?.call(focusNode.hasFocus, controller.text);

    if (!focusNode.hasFocus) {
      provider.updateInputValue(controller.text);
    }
  }

  /// 更新字数
  _textChanged() {
    final wordsCount = controller.text.length;
    if (wordsCount > widget.maxWords) {
      controller.text = controller.text.substring(0, widget.maxWords);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WordsCounter>().changeWordsCount(controller.text.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: widget.padding ??
          EdgeInsets.only(
            top: 10.h,
            left: 10.w,
            right: 10.w,
            bottom: 14.h,
          ),
      child: Stack(
        children: [
          /// 背景色
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8F9),
              borderRadius: BorderRadius.circular(12.w),
              border: Border.all(
                color: const Color(0xFFEDEFF4),
                width: 1,
              ),
            ),
          ),

          /// 输入框
          buildTextArea(context),

          /// 工具条
          buildToolBar(context),
        ],
      ),
    );
  }

  /// 输入框
  Positioned buildTextArea(BuildContext context) {
    final desc = context.select<T, String>((p) => p.inputValue);
    byDebugPrint("---", tag: "buildTextArea:");
    controller.text = desc;
    return Positioned.fill(
      child: Container(
        padding: EdgeInsets.only(
          left: 10.w,
          right: 10.w,
          top: 10.h,
          bottom: 29.h,
        ),
        child: ExtendedTextField(
          maxLines: null,
          expands: false,
          controller: controller,
          focusNode: focusNode,
          autofocus: false,
          onChanged: (String value) {},
          decoration: InputDecoration(
            border: InputBorder.none,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: ByColorUtil.CommonTextColor,
            ),
            hintText: "请粘贴或者输入视频分享链接",
            hintStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: ByColorUtil.CommonTextColor.withOpacity(0.3),
            ),
          ),
          cursorColor: ByColorUtil.CommonTextColor,
        ),
      ),
    );
  }

  /// 输入框内的底部工具条
  Positioned buildToolBar(BuildContext context) {
    return Positioned(
      bottom: 5.h,
      child: SizedBox(
        width: ByScreenUtils.screenWidth - 24.w,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 10.w),
            WordsCounterView(maxWords: widget.maxWords),
            const Spacer(),
            _buildIconBtn(
              title: '粘贴',
              icon: 'assets/replica/replica_input_paste.svg',
              onClick: () async {
                ClipboardData? data = await Clipboard.getData('text/plain');
                final text = data?.text;
                if (data == null || text == null || text.isEmpty) {
                  BotToast.showText(text: "当前没有复制任何内容");
                  return;
                }

                final value = controller.value;
                // 获取当前光标位置
                final selection = value.selection;
                final cursorPosition = selection.start;
                // 如果光标有效，则在光标处插入文本
                if (cursorPosition != -1) {
                  final newText = value.text.replaceRange(
                    cursorPosition,
                    cursorPosition,
                    text,
                  );

                  // 更新文本并设置新的光标位置
                  controller.value = value.copyWith(
                    text: newText,
                    selection: TextSelection.collapsed(
                      // 设置光标到粘贴内容末尾
                      offset: cursorPosition + text.length,
                    ),
                  );
                  // controller.
                } else {
                  controller.text = text;
                }
                final provider = context.read<T>();
                provider.updateInputValue(controller.text);
              },
            ),
            SizedBox(width: 5.w),
            _buildIconBtn(
              title: '清空',
              icon: 'assets/replica/replica_input_clear.svg',
              onClick: () {
                controller.text = "";
                context.read<T>().updateInputValue("");
              },
            ),
            SizedBox(width: 10.w),
          ],
        ),
      ),
    );
  }

  SizedBox _buildIconBtn({
    required String title,
    required String icon,
    required void Function() onClick,
  }) {
    return SizedBox(
      height: 24.h,
      child: ByWidgetsUtil.btnWithSvgIcon(
        title: title,
        iconPath: icon,
        iconW: 12.w,
        iconH: 12.h,
        onClick: onClick,
        fontSize: 12.sp,
        contentGap: 4.w,
        borderRadius: 20.w,
        fontWeight: FontWeight.normal,
        bgColor: ByColorUtil.WhiteColor,
        textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
      ),
    );
  }
}

class WordsCounterView extends StatelessWidget {
  const WordsCounterView({
    super.key,
    required this.maxWords,
  });

  final int maxWords;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 29.h,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: ByWidgetsUtil.commonText(
        text: "${context.watch<WordsCounter>().count}/$maxWords",
        fontSize: 12.sp,
        textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
      ),
    );
  }
}

class WordsCounter extends BaseProvider {
  int count = 0;
  changeWordsCount(int c) {
    count = c;
    notifyListeners();
  }
}
