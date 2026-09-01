import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_video_mode_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_prohibited_words_input_view.dart';

///分段处理页面
class AiCartoonParagraphPage extends StatefulWidget {
  const AiCartoonParagraphPage({super.key});

  @override
  State<AiCartoonParagraphPage> createState() => _AiCartoonParagraphPageState();
}

class _AiCartoonParagraphPageState extends State<AiCartoonParagraphPage> {
  static const tips =
      "1、若出现“图片违规”任务将转为手动模式，请在“草稿箱”中处理后生成视频。\n2、图片根据分段生成，可使用“手动换行”调整文章分段。\n3、修改图片时上传的素材请和所选智能视频尺寸相同。";

  @override
  void initState() {
    super.initState();

    final provider = context.read<AiCartoonProvider>();
    provider.articleSplit();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> paragraphs = context
        .select<AiCartoonProvider, List<String>>((value) => value.paragraphs);
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: "分段处理",
        showBottmLine: true,
      ),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body:  Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              children: [
                // SizedBox(height: 8.h),
                // Padding(
                //   padding: EdgeInsets.only(top: 8.h, bottom: 5.5.h),
                //   child: ByWidgetsUtil.commonTipsBar2(
                //     title: "温馨提示",
                //     tips: tips,
                //   ),
                // ),
                // SizedBox(height: 5.5.h),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 66.h),
                    itemCount: paragraphs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h, bottom: 5.5.h),
                          child: ByWidgetsUtil.commonTipsBar2(
                            title: "温馨提示",
                            tips: tips,
                          ),
                        );
                      }
                      return AiCartoonParagraphCell(index: index - 1);
                    },
                  ),
                )
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height:Platform.isAndroid? 66.h:86.h,
            child: PhysicalModel(
              color: ByColorUtil.BlackColor,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical:Platform.isAndroid? 8.h:20.h),
                child: ByWidgetsUtil.commonBtn(
                  title: "下一步",
                  borderRadius: 12.w,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  onClick: () {
                    /// 违禁词检测
                    final AiCartoonProvider provider =
                    context.read<AiCartoonProvider>();
                    String paragraphs = provider.paragraphs.join("");
                    provider.detect(
                      context,
                      paragraphs,
                      onSuccess: () {
                        if (provider.bandedWords.isNotEmpty) {
                          BotToast.showText(text: "当前存在违禁词");
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  ChangeNotifierProvider.value(
                                      value: provider,
                                      child: const AiCartoonVideoModeDialog()));
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}

class AiCartoonParagraphCell extends StatelessWidget {
  const AiCartoonParagraphCell({
    super.key,
    required this.index,
  });
  final int index;

  final maxLen = 100;

  @override
  Widget build(BuildContext context) {
    final List<String> paragraphs = context
        .select<AiCartoonProvider, List<String>>((val) => val.paragraphs);
    final content = paragraphs[index];
    final contents =
        content.length > maxLen ? content.substring(0, maxLen) : content;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: ByWidgetsUtil.commonContainer(
              margin: EdgeInsets.symmetric(
                vertical: 2.5.h,
              ),
              border: Border.all(
                color: const Color(0xFFF3F5F9),
                width: 0.5,
              ),
              padding: EdgeInsets.only(
                left: 11.w,
                right: 11.w,
                top: 12.h,
                bottom: 15.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ByWidgetsUtil.commonText(
                    fontSize: 12.sp,
                    text: "场景${index + 1}",
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                  ),
                  SizedBox(height: 8.h),
                  AiCartoonProhibitedInputView(
                    contents: contents,
                    padding: EdgeInsets.zero,
                    onChanged: (p0) {
                      if (p0.trim().contains("\n")) {
                        final provider = context.read<AiCartoonProvider>();
                        final words = List<String>.from(provider.paragraphs);
                        final comps = p0.trim().split("\n");

                        words[index] = comps.first;
                        words.insert(index + 1, comps[1]);
                        provider.updateParagraphs(words);
                      }
                    },
                    onFinished: (val) {
                      byDebugPrint("$val----$index", tag: "onFinished");
                      final provider = context.read<AiCartoonProvider>();
                      final words = List<String>.from(provider.paragraphs);
                      words[index] = val;
                      provider.updateParagraphs(words);
                    },
                  ),
                  SizedBox(height: 15.h),
                  ByWidgetsUtil.commonText(
                    fontSize: 14.sp,
                    text: "${contents.length}/$maxLen",
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 10.w,
            bottom: 0,
            width: 24.w,
            height: 12.h,
            child: Offstage(
              offstage: index >= paragraphs.length - 1,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _mergeWithNext(context);
                },
                child: Image.asset(
                  "assets/ai/ai_cartoon_link_top.png",
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            right: 10.w,
            top: 0,
            width: 24.w,
            height: 12.h,
            child: Offstage(
              offstage: index == 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _mergeWithPrevious(context);
                },
                child: Image.asset(
                  "assets/ai/ai_cartoon_link_bottom.png",
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _mergeWithPrevious(BuildContext context) {
    final provider = context.read<AiCartoonProvider>();
    final paragraphsCopy = provider.paragraphs;
    final paragraphs = List.from(paragraphsCopy);
    paragraphs[index] = paragraphs[index] + paragraphs[index - 1];
    paragraphs.removeAt(index - 1);
    provider.updateParagraphs(List<String>.from(paragraphs.map((e) => e)));
  }

  _mergeWithNext(BuildContext context) {
    final provider = context.read<AiCartoonProvider>();
    final paragraphsCopy = provider.paragraphs;
    final paragraphs = List.from(paragraphsCopy);
    paragraphs[index] = paragraphs[index] + paragraphs[index + 1];
    paragraphs.removeAt(index + 1);
    provider.updateParagraphs(List<String>.from(paragraphs.map((e) => e)));
  }
}
