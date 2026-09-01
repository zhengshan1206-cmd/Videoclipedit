import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/forbidden_text.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';

class ForbiddenTextSpanBuilder extends SpecialTextSpanBuilder {
  final List<String> forbiddenWords;

  ForbiddenTextSpanBuilder({required this.forbiddenWords});

  @override
  SpecialText? createSpecialText(
    String flag, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
    required int index,
  }) {
    byDebugPrint("start:$flag",
        tag: "ForbiddenTextSpanBuilder - createSpecialText:");
    for (var word in forbiddenWords) {
      byDebugPrint(word, tag: "ForbiddenTextSpanBuilder - createSpecialText:");
      if (flag.startsWith(word)) {
        return ForbiddenText(
          textStyle: textStyle!,
          onTap: onTap,
          start: index,
          forbiddenWord: word,
        );
      }
    }
    return null;
  }

  @override
  TextSpan build(String data, {TextStyle? textStyle, onTap}) {
    byDebugPrint(data, tag: "ForbiddenTextSpanBuilder - build:");
    return super.build(data, textStyle: textStyle, onTap: onTap);
  }
}
