import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';

class BandedWordsDectInputView extends StatefulWidget {
  const BandedWordsDectInputView({
    super.key,
    required this.index,
    required this.contents,
  });

  final int index;
  final String contents;

  @override
  State<BandedWordsDectInputView> createState() =>
      _BandedWordsDectInputViewState();
}

class _BandedWordsDectInputViewState extends State<BandedWordsDectInputView> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.contents);

  @override
  Widget build(BuildContext context) {
    final List<String> bandedWords =
        context.select<AiCartoonProvider, List<String>>(
      (value) => value.bandedWords,
    );
    bandedWords.sort(
      (v1, v2) => v1.length - v2.length,
    );
    return TextField(
      controller: _controller,
      maxLines: null,
      expands: false,
      onChanged: (text) {},
      decoration: InputDecoration(
        hintText: '输入文本内容',
        border: InputBorder.none,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: ByColorUtil.CommonTextColor,
        ),
        hintStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: ByColorUtil.CommonTextColor.withOpacity(0.3),
        ),
      ),
      style: TextStyle(
        color: ByColorUtil.CommonTextColor,
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
      ),
      // buildCounter: (
      //   BuildContext ctx, {
      //   int? currentLength,
      //   bool? isFocused,
      //   int? maxLength,
      // }) {
      //   return _highlightText(_controller.text, context, bandedWords);
      // },
    );
  }

  // 生成高亮文本
  Widget _highlightText(
    String text,
    BuildContext context,
    List<String> bandedWords,
  ) {
    final List<TextSpan> spans = [];
    String pattern = bandedWords.map((e) => RegExp.escape(e)).join('|');
    RegExp regex = RegExp('($pattern)');
    List<String> result = [];
    text.splitMapJoin(
      regex,
      onMatch: (match) {
        // 将匹配到的分隔符添加到结果中
        result.add(match.group(0)!);
        return match.group(0)!;
      },
      onNonMatch: (nonMatch) {
        // 将非分隔符部分添加到结果中
        if (nonMatch.isNotEmpty) {
          result.add(nonMatch);
        }
        return nonMatch;
      },
    );

    for (var word in result) {
      if (bandedWords.contains(word)) {
        // 如果是违禁词，用红色标记
        spans.add(TextSpan(
          text: '$word ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
            color: ByColorUtil.BandedWordsColor,
          ),
        ));
      } else {
        // 其他文本用默认颜色
        spans.add(TextSpan(
          text: '$word ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
            color: ByColorUtil.CommonTextColor,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
