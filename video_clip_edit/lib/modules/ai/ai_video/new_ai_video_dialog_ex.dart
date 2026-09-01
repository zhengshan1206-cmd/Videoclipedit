import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import '../../../v2/aiVideo/models/ai_video_square_model.dart';
import '../../tool_box/videoExtraction/widgets/video_player_widget.dart';
import 'new_ai_video_controller.dart';

class NewAiVideoDialogEx extends StatefulWidget {
  final AiVideoSquareModel model;

  ///0=>图生视频，1=>文生视频，
  final int? type;

  const NewAiVideoDialogEx({
    super.key,
    required this.model,
    this.type,
  });

  @override
  State<NewAiVideoDialogEx> createState() => _NewAiVideoDialogState();
}

class _NewAiVideoDialogState extends State<NewAiVideoDialogEx> {
  final GlobalKey<VideoPlayerWidgetState> _playerKey =
      GlobalKey<VideoPlayerWidgetState>();

  bool isStopMusic = true;

  double calculateTextHeight(
      String text, int maxLines, double fontSize, double maxWidth) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0XFF0B1843).withOpacity(0.5),
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: '...',
    )..layout(maxWidth: maxWidth);

    return textPainter.size.height;
  }

  @override
  Widget build(BuildContext context) {
    String url = widget.model.coverUrl;
    if (widget.model.multiImage?.isNotEmpty == true) {
      url = widget.model.multiImage!.first;
    }
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(18.w)),
            width: double.infinity,
            padding: EdgeInsets.only(top: 15.w, left: 12.5.w, right: 12.5.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 143.5.w,
                    ),
                    Text(
                      "热门同款",
                      style: TextStyle(
                          color: const Color(0XFF0B1843),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    InkResponse(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          // color: Colors.red,
                          width: 30.w,
                          height: 30.w,
                          child: Icon(Icons.close),
                        )),
                  ],
                ),
                SizedBox(
                  height: 25.w,
                ),
                Row(
                  children: [
                    Image.asset(
                      "assets/ai/aiVideo/image_example_icon.png",
                      width: 14.w,
                      height: 14.w,
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    Text(
                      widget.type == 1 ? "参考文案" : "参考图",
                      style: TextStyle(
                          color: const Color(0XFF0B1843),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.5.w,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 2,
                      height: widget.type == 1
                          ? calculateTextHeight(
                              "${widget.model.prompt}", 2, 12.sp, 1.sw - 60.w)
                          : (widget.model.prompt?.isNotEmpty == true
                                  ? calculateTextHeight(
                                      "${widget.model.prompt}",
                                      2,
                                      12.sp,
                                      1.sw - 60.w)
                                  : 0) +
                              10.w +
                              70.w,
                      color: Color(0XFFEBEBEB),
                      margin: EdgeInsets.only(right: 11.w),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.type != 1)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(4.w),
                                  child: CachedNetworkImage(
                                    imageUrl: url,
                                    height: 70.w,
                                    fit: BoxFit.fitHeight,
                                  )),
                              // Positioned(
                              //   top: 5.w,
                              //   right: 5.w,
                              //   child: Image.asset(
                              //     "assets/ai/aiVideo/expand_video_icon.png",
                              //     width: 18.w,
                              //     height: 18.w,
                              //   ),
                              // )
                            ],
                          ),
                        if (widget.type != 1 &&
                            widget.model.prompt?.isNotEmpty == true)
                          SizedBox(height: 10.w),
                        if (widget.model.prompt?.isNotEmpty == true)
                          SizedBox(
                              width: 1.sw - 60.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 0.w),
                                    child: Text(
                                      maxLines: 2,
                                      "${widget.model.prompt}",
                                      style: TextStyle(
                                        color:
                                            Color(0XFF0B1843).withOpacity(0.5),
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                ],
                              ))
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 15.w,
                ),
                Row(
                  children: [
                    Image.asset(
                      "assets/ai/aiVideo/new_ai_hint_icon.png",
                      width: 12.w,
                      height: 12.w,
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    Text(
                      "成片效果",
                      style: TextStyle(
                          color: const Color(0XFF0B1843),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.w,
                ),
                Stack(
                  children: [
                    Container(
                        height: 301.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: const Color(0XFFF9FAFF),
                            border: Border.all(
                                color: const Color(0XFFEAEEFF), width: 2.w),
                            borderRadius: BorderRadius.circular(12.w)),
                        child: Stack(
                          children: [
                            Container(
                                margin: EdgeInsets.only(
                                    right: 12.w,
                                    left: 12.w,
                                    top: 10.w,
                                    bottom: 10.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.w),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.w),
                                  child: VideoPlayerWidget(
                                    key: _playerKey,
                                    url: widget.model.videoUrl,
                                    autoPlay: true,
                                  ),
                                )),
                            isStopMusic
                                ? Positioned(
                                    right: 15.w,
                                    top: 15.w,
                                    child: GestureDetector(
                                      onTap: () {
                                        _playerKey.currentState
                                            ?.changeMuteStatus(true);
                                        setState(() {
                                          isStopMusic = false;
                                        });
                                      },
                                      child: Image.asset(
                                        "assets/ai/aiVideo/new_video_stop_music_icon.png",
                                        width: 32.w,
                                        height: 32.w,
                                      ),
                                    ))
                                : Positioned(
                                    right: 15.w,
                                    top: 15.w,
                                    child: GestureDetector(
                                      onTap: () {
                                        _playerKey.currentState
                                            ?.changeMuteStatus(false);
                                        setState(() {
                                          isStopMusic = true;
                                        });
                                      },
                                      child: Image.asset(
                                        "assets/ai/aiVideo/new_video_open_music_icon.png",
                                        width: 32.w,
                                        height: 32.w,
                                      ),
                                    )),
                          ],
                        )),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    ByNavigatorUtil.checkLogin(
                      context: context,
                      nextStepEvent: (){
                        Get.back(result: widget.model);
                        Get.find<NewAiVideoController>().updateButtonState();
                      });
                  },
                  child: Container(
                    width: 1.sw,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(
                        left: 0.w, right: 0.w, bottom: 0.w, top: 10.w),
                    padding: EdgeInsets.only(top: 15.w, bottom: 15.w),
                    decoration: BoxDecoration(
                        color: const Color(0XFF5A4BF7),
                        borderRadius: BorderRadius.circular(12.w)),
                    child: Text(
                      "去试试",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(
                  height: 18.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
