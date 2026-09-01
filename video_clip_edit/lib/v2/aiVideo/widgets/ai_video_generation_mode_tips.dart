import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

Future<void> showAiVideoGenerationModeTips(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) => const AiVideoGenerationModeTips()
  );
}

class AiVideoGenerationModeTips extends StatefulWidget {
  const AiVideoGenerationModeTips({super.key});

  @override
  State<AiVideoGenerationModeTips> createState() => _AiVideoGenerationModeTipsState();
}

class _AiVideoGenerationModeTipsState extends State<AiVideoGenerationModeTips> {
  late VideoPlayerController _videoPlayerController;
  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.asset("assets/ai/aiVideo/demo-nice-Di6ivZwN.mp4")
      ..setLooping(true)
      ..initialize().then((_) => _videoPlayerController.play());
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('生成模式', textAlign: TextAlign.center),
      titleTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16.sp,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Image.asset(
                  "assets/ai/aiVideo/radio_checked@2x.png",
                  scale: 2,
                  color: Theme.of(context).colorScheme.onSurface,
              ),
              SizedBox(width: 4.sp),
              Text(
                  '标准：生成速度更快！创作成本更低！',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14.sp,
                  ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Image.asset(
                "assets/ai/aiVideo/radio_checked@2x.png",
                scale: 2,
                color: Color(0xFF5B4BF7),
              ),
              SizedBox(width: 4.sp),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF5B4BF7),
                      Color(0xFFFF2BB2),
                    ]
                ).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: Text(
                  '高品质：视频画面质量更佳！',
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 280.w,
              height: 157.5.h,
              child: VideoPlayer(
                _videoPlayerController,
              ),
            ),
          )
        ],
      ),
    );
  }
}