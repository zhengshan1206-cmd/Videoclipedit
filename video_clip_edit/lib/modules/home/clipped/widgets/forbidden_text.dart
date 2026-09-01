import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';

class ForbiddenText extends SpecialText {
  final int start;
  final String forbiddenWord;

  ForbiddenText({
    required this.start,
    required this.forbiddenWord,
    required TextStyle textStyle,
    SpecialTextGestureTapCallback? onTap,
  }) : super(forbiddenWord, ' ', textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    byDebugPrint(forbiddenWord, tag: "违禁词-finishText：");
    return TextSpan(
      text: forbiddenWord,
      style: textStyle?.copyWith(
        color: Colors.red,
      ),
    );
  }
}
