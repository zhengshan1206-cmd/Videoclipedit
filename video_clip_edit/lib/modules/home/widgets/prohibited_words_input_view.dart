// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:video_clip_edit/modules/home/providers/forbidden_words_provider.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';

class ProhibitedInputView<T extends MaterialBaseProvider>
    extends StatelessWidget {
  final bool hideExtractBtn;
  final EdgeInsetsGeometry? padding;
  final void Function()? extractCallback;
  int? contentLength;
  bool inputAutofocus;
  ProhibitedInputView({
    super.key,
    this.contentLength,
    this.padding,
    this.inputAutofocus = true,
    this.extractCallback,
    this.hideExtractBtn = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WordsCounter(),
      child: ProhibitedInputViewInner<T>(
        padding: padding,
        contentLength: contentLength,
        extractCallback: extractCallback,
        inputAutofocus: inputAutofocus,
        hideExtractBtn: hideExtractBtn,
      ),
    );
  }
}

class ProhibitedInputViewInner<T extends MaterialBaseProvider>
    extends StatefulWidget {
  int? contentLength;
  bool? inputAutofocus;

  ProhibitedInputViewInner({
    super.key,
    this.padding,
    this.contentLength,
    this.inputAutofocus,
    this.extractCallback,
    this.hideExtractBtn = false,
  });

  final EdgeInsetsGeometry? padding;
  final void Function()? extractCallback;
  final bool hideExtractBtn;

  @override
  State<ProhibitedInputViewInner<T>> createState() =>
      _ProhibitedInputViewInnerState<T>();
}

class _ProhibitedInputViewInnerState<T extends MaterialBaseProvider>
    extends State<ProhibitedInputViewInner<T>> {
  late TextEditingController controller;
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    controller.removeListener(_textChanged);

    focusNode.removeListener(_focusNodeStatusChanged);
    super.dispose();
  }

  @override
  void initState() {
    final provider = context.read<T>();
    controller = TextEditingController(
      text: provider.subtitlesBean.wordsOrigin,
    )..addListener(_textChanged);
    focusNode.addListener(_focusNodeStatusChanged);

    // if (widget.content != null) {
    //   controller.text = widget.content!;
    // }
    super.initState();
  }

  _focusNodeStatusChanged() {
    final provider = context.read<T>();
    if (provider is ForbiddenWordsProvider) {
      (provider as ForbiddenWordsProvider).forbidden = false;
    }
    if (!focusNode.hasFocus) {
      updateProviderData(provider, controller.text);
    }
  }

  _textChanged() {
    final wordsCount = controller.text.length;
    if (wordsCount > (widget.contentLength ?? 2000)) {
      controller.text = controller.text.substring(0, widget.contentLength);
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
    final provider = context.read<T>();
    final wordsOrigin = provider.subtitlesBean.wordsOrigin;
    if (controller.text != wordsOrigin) {
      controller.text = wordsOrigin;
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
            autofocus: widget.inputAutofocus ?? true,
            onChanged: (String value) {
              context.read<WordsCounter>().changeWordsCount(value.length);
              provider.updateSubtitle(value);
            },
            // specialTextSpanBuilder: BySpecialTextBuilder(),
            decoration: InputDecoration(
              border: InputBorder.none,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                color: ByColorUtil.CommonTextColor,
              ),
              hintText: "请输入文字内容...",
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: ByColorUtil.CommonTextColor.withOpacity(0.5),
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
    bool isClip = MaterialProviderTypeExt.providerTypeFromType(T) ==
        MaterialProviderType.clip;
    final provider = context.read<T>();
    return Positioned(
      bottom: 6.h,
      child: SizedBox(
        width: ByScreenUtils.screenWidth - 24.w,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () async {
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

                  provider.subtitlesBean.wordsOrigin = newText;

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
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 29.h,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: ByWidgetsUtil.commonText(
                  text: "粘贴",
                  fontSize: 12.sp,
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
                context.read<T>().updateSubtitle("");
              },
              behavior: HitTestBehavior.opaque,
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
            ),
            if (isClip) const Spacer(),
            if (isClip && !widget.hideExtractBtn)
              ByWidgetsUtil.outlinedBtn(
                title: "一键提取视频文案",
                bgColor: Colors.transparent,
                onClick: () async {
                  widget.extractCallback?.call();
                },
              ),
            const Spacer(),
            Container(
              height: 29.h,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: ByWidgetsUtil.commonText(
                text:
                    "${context.watch<WordsCounter>().count}/${widget.contentLength ?? 2000}",
                fontSize: 12.sp,
                textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 更新输入框的显示文本，为违禁词添加高亮显示，并更新光标的位置
  void updateProviderData(T provider, String value) {
    /// 更新字幕
    provider.updateSubtitle(value);
  }
}

class WordsCounter extends BaseProvider {
  int count = 0;

  changeWordsCount(int c) {
    count = c;
    notifyListeners();
  }
}

class MyNotification extends Notification {
  final String message;

  MyNotification(
    this.message,
  );
}
