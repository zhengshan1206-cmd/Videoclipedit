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
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';

class AiClipInputView extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final bool canInput;
  final Widget Function(BuildContext context)? toolBarBuilder;
  const AiClipInputView({
    super.key,
    this.padding,
    this.canInput = true,
    this.toolBarBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WordsCounter(),
      child: AiClipInputViewInner(
        padding: padding,
        canInput: canInput,
        toolBarBuilder: toolBarBuilder,
      ),
    );
  }
}

class AiClipInputViewInner extends StatefulWidget {
  const AiClipInputViewInner({
    super.key,
    this.padding,
    this.canInput = true,
    this.toolBarBuilder,
    this.extractCallback,
    this.hideExtractBtn = false,
  });

  final bool canInput;
  final bool hideExtractBtn;
  final EdgeInsetsGeometry? padding;
  final void Function()? extractCallback;
  final Widget Function(BuildContext context)? toolBarBuilder;
  @override
  State<AiClipInputViewInner> createState() => _AiClipInputViewInnerState();
}

class _AiClipInputViewInnerState extends State<AiClipInputViewInner> {
  late TextEditingController controller;
  late final FocusNode focusNode = FocusNode();
  final int maxWords = 2000;

  @override
  void dispose() {
    controller.removeListener(_textChanged);

    focusNode.removeListener(_focusNodeStatusChanged);
    super.dispose();
  }

  @override
  void initState() {
    controller =
        TextEditingController(text: context.read<AiClipProvider>().desc)
          ..addListener(_textChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WordsCounter>().changeWordsCount(controller.text.length);
    });

    Future.microtask(() {
      focusNode.addListener(_focusNodeStatusChanged);
      focusNode.unfocus();
    });

    super.initState();
  }

  /// 失去焦点时更新provider的描述信息
  _focusNodeStatusChanged() {
    final provider = context.read<AiClipProvider>();

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
    final generatingCommentary = context.select<AiClipProvider, bool>(
        (AiClipProvider provider) => provider.generatingCommentary);
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

            buildCommentaryTips(generatingCommentary: generatingCommentary),

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
    final desc = context.select<AiClipProvider, String>((p) => p.desc);
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
            padding: EdgeInsets.zero,
            children: [
              ByWidgetsUtil.commonText(
                text: desc,
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
    final generatingCommentary = context.select<AiClipProvider, bool>(
        (AiClipProvider provider) => provider.generatingCommentary);
    byDebugPrint("---generating commentary - $generatingCommentary",
        tag: "buildTextArea:");
    controller.text = desc;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: TextField(
        selectionControls: MaterialTextSelectionControls(),
        maxLines: null,
        autofocus: false,
        focusNode: focusNode,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          isCollapsed: true,
          border: InputBorder.none,
          hintText: generatingCommentary ? "" : "请粘贴或者输入您的小说内容，最多可输入2000字",
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
                SizedBox(width: 10.w),
                WordsCounterView(maxWords: maxWords),
                const Spacer(),
                // _buildIconBtn(
                //   title: '导入',
                //   icon: 'assets/ai/ai_cartoon_input_import.png',
                //   onClick: () {
                //     showDialog(
                //       context: context,
                //       barrierDismissible: false,
                //       builder: (ctx) {
                //         return MultiProvider(providers: [
                //           ChangeNotifierProvider(
                //               create: (context) => AiCartoonImportProvider()),
                //           ChangeNotifierProvider.value(
                //               value: context.read<AiCartoonProvider>())
                //         ], child: const AiCartoonImportDialog());
                //       },
                //     );
                //   },
                // ),
                SizedBox(width: 5.w),
                _buildIconBtn(
                  title: '粘贴',
                  icon: 'assets/ai/ai_cartoon_input_paste.png',
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
                    final provider = context.read<AiClipProvider>();
                    provider.updateDesc(controller.text);
                  },
                ),
                SizedBox(width: 5.w),
                _buildIconBtn(
                  title: '清空',
                  icon: 'assets/ai/ai_cartoon_input_delete.png',
                  onClick: () {
                    controller.text = "";
                    context.read<AiClipProvider>().updateDesc("");
                  },
                ),
                SizedBox(width: 5.w),
              ],
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
      child: ByWidgetsUtil.btnWithIcon(
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

// ignore: camel_case_types
class buildCommentaryTips extends StatelessWidget {
  const buildCommentaryTips({
    super.key,
    required this.generatingCommentary,
  });

  final bool generatingCommentary;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: generatingCommentary == false,
      child: Row(
        children: [
          SizedBox(
            width: 22.w,
            height: 10.w,
            child: ByWidgetsUtil.activityIndicator(radius: 8.w),
          ),
          SizedBox(width: 3.w),
          Text(
            "文案正在解说中...",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: ByColorUtil.CommonTextColor.withOpacity(0.6),
            ),
          ),
        ],
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
