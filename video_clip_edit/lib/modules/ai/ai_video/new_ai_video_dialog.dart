import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../v2/aiVideo/models/ai_video_square_model.dart';
import '../../tool_box/videoExtraction/widgets/video_player_widget.dart';

class NewAiVideoDialog extends StatefulWidget {
  final AiVideoSquareModel model;
  const NewAiVideoDialog({
    super.key,
    required this.model,
  });

  @override
  State<NewAiVideoDialog> createState() => _NewAiVideoDialogState();
}

class _NewAiVideoDialogState extends State<NewAiVideoDialog> {
  final GlobalKey<VideoPlayerWidgetState> _playerKey =
      GlobalKey<VideoPlayerWidgetState>();
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                    width: 1.sw,
                    height: 400.h,
                    margin: EdgeInsets.only(right: 37.5.w, left: 37.5.w),
                    decoration: BoxDecoration(
                      // color: Colors.blue,
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.w),
                      child: VideoPlayerWidget(
                        key: _playerKey,
                        url: widget.model.videoUrl,
                        aspectRatio: (1.sw - 75.w) / 400.h,
                        autoPlay: true,
                      ),
                    )
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      children: [
                        Container(
                          width:(1.sw-150.w),
                          alignment: Alignment.center,
                          child:  Text(
                            "${widget.model.prompt}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                overflow: TextOverflow.clip
                            ),
                            maxLines: 1,
                          ),
                        ),
                       GestureDetector(
                         onTap: (){
                           Get.back(result: widget.model);
                         },
                         child:  Container(
                           width: 1.sw,
                           alignment: Alignment.center,
                           margin: EdgeInsets.only(
                               left: 52.5.w,
                               right: 52.5.w,
                               bottom: 15.w,
                               top: 5.w),
                           padding: EdgeInsets.only(top: 15.w, bottom: 15.w),
                           decoration: BoxDecoration(
                               color: const Color(0XFF5A4BF7),
                               borderRadius: BorderRadius.circular(12.w)),
                           child: Text(
                             "使用特效",
                             style: TextStyle(
                                 color: Colors.white,
                                 fontSize: 14.sp,
                                 fontWeight: FontWeight.w500),
                           ),
                         ),
                       )
                      ],
                    )),
                Positioned(
                    right: 47.5.w,
                    top: 10.w,
                    child: GestureDetector(
                      onTap: () {
                        _playerKey.currentState?.changeMuteStatus(true);
                      },
                      child: Image.asset(
                        "assets/ai/aiVideo/new_video_stop_music_icon.png",
                        width: 32.w,
                        height: 32.w,
                      ),
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
