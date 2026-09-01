import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class WordsExtractionResultPage extends StatelessWidget {
  const WordsExtractionResultPage({
    super.key,
    required this.contents,
  });
  final String contents;
  @override
  Widget build(BuildContext context) {
    final safeBottomH = context.byBottomSafeHeight;
    // final extractedContent = context.select<WordsExtractProvider, String>(
    //   (p) => p.extractedContent,
    // );
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "提取文字"),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Stack(
        children: [
          ListView.builder(
            itemCount: 1,
            padding: EdgeInsets.only(bottom: safeBottomH + 68.w),
            itemBuilder: (ctx, index) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
                child: ByWidgetsUtil.commonText(
                  text: contents.isEmpty ? "未识别到文本内容" : contents,
                  maxLines: 100000,
                ),
              );
            },
          ),
          _buildBottomBar(safeBottomH, context),
        ],
      ),
    );
  }

  Positioned _buildBottomBar(double safeBottomH, BuildContext context) {
    return Positioned(
      bottom: 0,
      child: Container(
        height: 68.w + safeBottomH,
        width: context.byScreenWidth,
        color: ByColorUtil.WhiteColor,
        padding: EdgeInsets.fromLTRB(
          12.w,
          12.w,
          12.w,
          12.w + safeBottomH,
        ),
        child: ByWidgetsUtil.commonBtn(
          fontSize: 16.sp,
          title: "复制内容",
          onClick: () {
            // 将文本写入剪切板

            if (contents.isNotEmpty && contents != "未识别到文本内容") {
              Clipboard.setData(ClipboardData(text: contents));
              BotToast.showText(text: "复制成功");
            } else {
              BotToast.showText(text: "未识别到文本内容");
            }
          },
        ),
      ),
    );
  }
}
