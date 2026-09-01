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
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';

class AiCartoonRegenerateInputView extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final void Function(String)? onChanged;
  final bool? useProvider;
  const AiCartoonRegenerateInputView({
    super.key,
    this.padding,
    this.onChanged,
    this.useProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WordsCounter(),
      child: AiCartoonRegenerateInputViewInner(
        padding: padding,
        useProvider: useProvider == null ? true : useProvider!,
        onChanged: onChanged,
      ),
    );
  }
}

class AiCartoonRegenerateInputViewInner extends StatefulWidget {
  const AiCartoonRegenerateInputViewInner({
    super.key,
    this.padding,
    this.extractCallback,
    this.hideExtractBtn = false,
    this.onChanged,
    required this.useProvider,
  });

  final EdgeInsetsGeometry? padding;
  final void Function()? extractCallback;
  final bool hideExtractBtn;
  final void Function(String)? onChanged;
  final bool useProvider;

  @override
  State<AiCartoonRegenerateInputViewInner> createState() =>
      _AiCartoonRegenerateInputViewInnerState();
}

class _AiCartoonRegenerateInputViewInnerState
    extends State<AiCartoonRegenerateInputViewInner> {
  late TextEditingController controller;
  final FocusNode focusNode = FocusNode();
  final int maxWords = 2000;

  @override
  void dispose() {
    controller.removeListener(_textChanged);

    if (widget.useProvider) {
      focusNode.removeListener(_focusNodeStatusChanged);
    }
    super.dispose();
  }

  @override
  void initState() {
    controller = TextEditingController(
        text: widget.useProvider ? context.read<AiCartoonProvider>().desc : "")
      ..addListener(_textChanged);
    if (widget.useProvider) {
      focusNode.addListener(_focusNodeStatusChanged);
    }
    super.initState();
  }

  /// 失去焦点时更新provider的描述信息
  _focusNodeStatusChanged() {
    final provider = context.read<AiCartoonProvider>();

    if (!focusNode.hasFocus) {
      provider.updateDesc(controller.text);
    }
  }

  /// 更新字数
  _textChanged() {
    final wordsCount = controller.text.length;
    if (wordsCount > maxWords) {
      controller.text = controller.text.substring(0, maxWords);
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
            left: 11.w,
            right: 11.w,
            bottom: 14.h + ByScreenUtils.bottomSafeHeight,
          ),
      color: ByColorUtil.WhiteColor,
      child: Stack(
        children: [
          /// 背景色
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8F9),
              borderRadius: BorderRadius.circular(12.w),
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
    if (widget.useProvider) {
      final desc = context.select<AiCartoonProvider, String>((p) => p.desc);
      byDebugPrint("---", tag: "buildTextArea:");
      controller.text = desc;
    }
    return Positioned.fill(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        child: Container(
          margin: EdgeInsets.only(bottom: 30.h),
          child: ExtendedTextField(
            maxLines: null,
            expands: false,
            controller: controller,
            focusNode: focusNode,
            autofocus: false,
            onChanged: (String value) {
              widget.onChanged?.call(value);
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                color: ByColorUtil.CommonTextColor,
              ),
              hintText: "请直接用短句或词语简洁描述出你想要的画面特征...",
              hintStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                color: ByColorUtil.CommonTextColor.withOpacity(0.3),
              ),
            ),
            cursorColor: ByColorUtil.CommonTextColor,
          ),
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
            _buildIconBtn(
              title: '粘贴  |',
              icon: 'assets/ai/ai_cartoon_input_paste.png',
              onClick: () async {
                ClipboardData? data = await Clipboard.getData('text/plain');
                final text = data?.text;
                if (data == null || (data.text ?? "").isEmpty) {
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
                    text!,
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
                }
              },
            ),
            _buildIconBtn(
              title: '  清空',
              icon: 'assets/ai/ai_cartoon_input_delete.png',
              onClick: () {
                controller.text = "";
              },
            ),
            const Spacer(),
            WordsCounterView(maxWords: maxWords),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBtn({
    required String title,
    required String icon,
    required void Function() onClick,
  }) {
    return GestureDetector(
      onTap: onClick,
      child: SizedBox(
          height: 24.h,
          child: ByWidgetsUtil.commonText(
            text: title,
            fontSize: 12.sp,
            textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
          )),
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
