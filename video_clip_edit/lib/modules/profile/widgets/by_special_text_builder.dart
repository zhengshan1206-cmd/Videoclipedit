import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/forbidden_words_text.dart';

class BySpecialTextBuilder extends SpecialTextSpanBuilder {
  BySpecialTextBuilder({this.showAtBackground = false});
  final bool showAtBackground;

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle,
      SpecialTextGestureTapCallback? onTap,
      int? index}) {
    if (flag == '') {
      return null;
    }

    if (isStart(flag, ForbiddenWordsText.flag)) {
      return ForbiddenWordsText(
        textStyle,
        onTap,
        start: index! - (ForbiddenWordsText.flag.length - 1),
      );
    }
    return null;
  }
}
