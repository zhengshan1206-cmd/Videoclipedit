import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/modules/profile/widgets/by_special_text_builder.dart';

class AiCartoonProhibitedInputView extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final void Function(String)? onChanged;
  final void Function(String)? onFinished;
  final String contents;

  const AiCartoonProhibitedInputView({
    super.key,
    this.padding,
    this.onChanged,
    required this.contents,
    this.onFinished,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WordsCounter(),
      child: AiCartoonProhibitedInputViewInner(
        key: UniqueKey(),
        padding: padding,
        onChanged: onChanged,
        contents: contents,
        onFinished: onFinished,
      ),
    );
  }
}

class AiCartoonProhibitedInputViewInner extends StatefulWidget {
  const AiCartoonProhibitedInputViewInner({
    super.key,
    this.padding,
    this.onChanged,
    required this.contents,
    this.onFinished,
  });

  final EdgeInsetsGeometry? padding;
  final void Function(String)? onChanged;
  final void Function(String)? onFinished;
  final String contents;

  @override
  State<AiCartoonProhibitedInputViewInner> createState() =>
      _AiCartoonProhibitedInputViewInnerState();
}

class _AiCartoonProhibitedInputViewInnerState
    extends State<AiCartoonProhibitedInputViewInner> {
  late TextEditingController controller;
  final FocusNode focusNode = FocusNode();
  final int maxLen = 200;
  @override
  void dispose() {
    controller.removeListener(_textChanged);

    focusNode.removeListener(_focusNodeStatusChanged);
    super.dispose();
  }

  @override
  void initState() {
    controller = TextEditingController(text: widget.contents)
      ..addListener(_textChanged);
    focusNode.addListener(_focusNodeStatusChanged);
    super.initState();
  }

  _focusNodeStatusChanged() {
    if (!focusNode.hasFocus) {
      widget.onFinished?.call(controller.text);
    }
  }

  _textChanged() {
    final wordsCount = controller.text.length;
    if (wordsCount > maxLen) {
      controller.text = controller.text.substring(0, maxLen);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WordsCounter>().changeWordsCount(controller.text.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ByColorUtil.WhiteColor,
      child: buildTextArea(context),
    );
  }

  /// 输入框
  buildTextArea(BuildContext context) {
    return ExtendedTextField(
      maxLines: null,
      expands: false,
      controller: controller,
      focusNode: focusNode,
      autofocus: false,
      onChanged: (String value) {
        context.read<WordsCounter>().changeWordsCount(value.length);
        widget.onChanged?.call(value);
      },
      style: TextStyle(
        fontSize: 14.sp,
        color: ByColorUtil.CommonTextColor,
      ),
      specialTextSpanBuilder: BySpecialTextBuilder(),
      decoration: InputDecoration(
        isDense: true,
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

class MyNotification extends Notification {
  final String message;
  MyNotification(
    this.message,
  );
}
