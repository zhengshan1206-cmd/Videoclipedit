import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class LocalVideoPlayer extends StatefulWidget {
  const LocalVideoPlayer({
    super.key,
    required this.localVideoController,
  });
  final VideoPlayerController localVideoController;

  @override
  State<LocalVideoPlayer> createState() => _LocalVideoPlayerState();
}

class _LocalVideoPlayerState extends State<LocalVideoPlayer> {
  late bool isPlaying = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isPlaying) {
          widget.localVideoController.pause();
        } else {
          widget.localVideoController.play();
        }
        setState(() {
          isPlaying = !isPlaying;
        });
      },
      child: Stack(
        children: [
          Container(
            child: (widget.localVideoController.value.isInitialized)
                ? AspectRatio(
                    aspectRatio: widget.localVideoController.value.aspectRatio,
                    child: VideoPlayer(widget.localVideoController),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Positioned.fill(
            child: Offstage(
              offstage: isPlaying ||
                  (widget.localVideoController.value.isInitialized == false),
              child: Center(
                child: Image.asset(
                  "assets/home/icon_audio_play.png",
                  width: 40.w,
                  height: 40.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
