import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/tool_box/beans/video_tutor_bean.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({
    super.key,
    required this.bean,
    required this.index,
  });
  final VideoTutorBean bean;
  final int index;
  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: ByColorUtil.BlackColor,
          alignment: Alignment.center,
          child: Hero(
            tag: "${widget.bean.id}_${widget.index}",
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.w),
              child: VideoPlayerWidget(
                url: widget.bean.videoUrl,
                autoPlay: true,
              ),
            ),
          ),
        ),
        Positioned(
          left: 12.w,
          top: ByScreenUtils.topSafeHeight + 10.h,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(context, true);
            },
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/purchase/dailog_bonus_close.png",
                width: 32,
                height: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
