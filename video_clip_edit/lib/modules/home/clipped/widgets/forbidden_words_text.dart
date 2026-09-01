import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ForbiddenWordsText extends SpecialText {
  ForbiddenWordsText(
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap, {
    this.start,
  }) : super(
          flag,
          flag,
          textStyle,
          onTap: onTap,
        );
  static const String flag = '\$';
  final int? start;
  @override
  InlineSpan finishText() {
    final String text = getContent();

    return SpecialTextSpan(
        text: text,
        actualText: toString(),
        start: start!,
        deleteAll: true,
        style: textStyle?.copyWith(color: Colors.red),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            if (onTap != null) {
              onTap!(toString());
            }
          });
  }
}
