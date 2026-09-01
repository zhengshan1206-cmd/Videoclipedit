import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/words/beans/audio_result_bean.dart';
import 'package:video_clip_edit/modules/home/words/words_extraction_result_page.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class AudioHandlePage extends StatefulWidget {
  final String requestID;
  const AudioHandlePage({
    super.key,
    required this.requestID,
  });

  @override
  State<AudioHandlePage> createState() => _AudioHandlePageState();
}

class _AudioHandlePageState extends State<AudioHandlePage> {
  @override
  void initState() {
    super.initState();

    _loadParsingProgress();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.WhiteColor,
      appBar: ByWidgetsUtil.appBar(context: context, title: "进度查询"),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 153.h),
            Image.asset(
              "assets/common/loading_large.gif",
              width: 120.w,
              height: 124.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 45.h),
            ByWidgetsUtil.commonRichText(
              texts: [
                const TextSpan(text: "识别中，请稍等..."),
              ],
              fontSize: 15.sp,
            ),
            const Spacer(),
            SizedBox(height: 30.h + ByScreenUtils.bottomSafeHeight),
          ],
        ),
      ),
    );
  }

  void _loadParsingProgress() {
    final provider = context.read<WordsExtractProvider>();
    ByFfmpegUtil.queryAudioRecognitionTask(
      requestID: widget.requestID,
      onSuccess: (data) {
        byDebugPrint(data["status"], tag: "解析状态：");
        final status = data["status"];
        if (status == 2) {
          Future.delayed(const Duration(seconds: 1), () {
            _loadParsingProgress();
          });
        } else if (status == 3) {
          final List beansData = data["content"] ?? [];
          List<AudioResultBean> beans =
              beansData.map((e) => AudioResultBean.fromJson(e)).toList();
          var res = "";
          for (var e in beans) {
            final text = e.text;
            if (text.isNotEmpty) {
              res += "$text\n";
            }
          }

          byDebugPrint(res, tag: "识别结果：");
          // provider.updateExtractedContent(res);
          provider.extractedContent = res;
          provider.loadRecords();
          ByNavRouterUtils.pushReplacement(
            context,
            WordsExtractionResultPage(contents: res),
          );
        }
      },
    );
  }
}
