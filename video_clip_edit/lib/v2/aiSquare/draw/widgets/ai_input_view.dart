import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';

class AiInputView extends StatelessWidget {
  final EdgeInsetsGeometry? padding;

  const AiInputView({
    super.key,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WordsCounter(),
      child: AiInputViewInner(padding: padding),
    );
  }
}

class AiInputViewInner extends StatefulWidget {
  const AiInputViewInner({
    super.key,
    this.padding,
    this.extractCallback,
    this.hideExtractBtn = false,
  });

  final EdgeInsetsGeometry? padding;
  final void Function()? extractCallback;
  final bool hideExtractBtn;

  @override
  State<AiInputViewInner> createState() => _AiInputViewInnerState();
}

class _AiInputViewInnerState extends State<AiInputViewInner> {
  late TextEditingController controller;
  final FocusNode focusNode = FocusNode();
  final int maxWords = 500;

  @override
  void dispose() {
    controller.removeListener(_textChanged);

    focusNode.removeListener(_focusNodeStatusChanged);
    super.dispose();
  }

  @override
  void initState() {
    controller =
        TextEditingController(text: context.read<AiDrawProvider>().desc)
          ..addListener(_textChanged);
    _textChanged();
    focusNode.addListener(_focusNodeStatusChanged);
    super.initState();
  }

  /// 失去焦点时更新provider的描述信息
  _focusNodeStatusChanged() {
    final provider = context.read<AiDrawProvider>();

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
              color: const Color(0xFFF5F8F9),
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
    final desc = context.select<AiDrawProvider, String>((p) => p.desc);
    byDebugPrint("---", tag: "buildTextArea:");
    controller.text = desc;
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
            onChanged: (String value) {},
            decoration: InputDecoration(
              border: InputBorder.none,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                color: ByColorUtil.CommonTextColor,
              ),
              hintText: "请输入描述词~",
              hintStyle: TextStyle(
                fontSize: 14.sp,
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
      bottom: 6.h,
      child: SizedBox(
        width: ByScreenUtils.screenWidth - 24.w,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: () {
                _randomInput(context);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 29.h,
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/ai/ai_cartoon_icon_random.png",
                  width: 12.w,
                  height: 14.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                ByNavigatorUtil.checkLogin(
                  context: context, 
                  nextStepEvent: (){
                    _randomInput(context);
                  });
                
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 29.h,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: ByWidgetsUtil.commonText(
                  text: "随机输入~",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: ByColorUtil.TabTextColorSelected,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
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
                final provider = context.read<AiDrawProvider>();
                provider.updateDesc(controller.text);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 29.h,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: ByWidgetsUtil.commonText(
                  text: "粘贴",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                ),
              ),
            ),
            Container(
              height: 29.h,
              alignment: Alignment.center,
              child: ByWidgetsUtil.commonText(
                text: "|",
                fontSize: 12.sp,
              ),
            ),
            GestureDetector(
              onTap: () {
                controller.text = "";
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 29.h,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: ByWidgetsUtil.commonText(
                  text: "清空",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                ),
              ),
            ),
            WordsCounterView(maxWords: maxWords),
          ],
        ),
      ),
    );
  }

  _randomInput(BuildContext context) {
    final provider = context.read<AiDrawProvider>();
    final styleCases = provider.drawConfigBean?.imgStyles ?? [];
    // print("styleCases====> $styleCases");
    if (styleCases.isEmpty) return;
    final currentId = provider.selectedStyleId;
    final List<String> prompts = styleCases.firstWhere((e) => e.id == currentId).prompts;
    if (prompts.isEmpty) return;
    String prompt = prompts[Random().nextInt(prompts.length)];
    if (prompts.length > 1) {
      while (provider.desc == prompt) {
        prompt = prompts[Random().nextInt(prompts.length)];
      }
    }
    provider.updateDesc(prompt);
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
