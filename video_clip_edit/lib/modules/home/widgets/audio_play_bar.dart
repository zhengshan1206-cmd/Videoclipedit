import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class AudioPlayBar extends StatefulWidget {
  final String recordingFilePath;

  const AudioPlayBar(
    this.recordingFilePath, {
    super.key,
  });

  @override
  State<AudioPlayBar> createState() => _AudioPlayBarState();
}

class _AudioPlayBarState extends State<AudioPlayBar> {
  String isPlayingIcon = "assets/home/audio_bar_play.png";
  late ByAudioPlayer byAudioPlayer;

  @override
  void initState() {
    super.initState();
    byAudioPlayer = ByAudioPlayer.sharedInstance;
    byAudioPlayer.listener((s) {
      if (PlayerState.playing == s) {
        if (mounted) {
          setState(() {
            isPlayingIcon = "assets/home/audio_bar_pause.png";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isPlayingIcon = "assets/home/audio_bar_play.png";
            ///解决会出现循环播放音频的bug
            ByAudioPlayer.sharedInstance.stop();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (ByAudioPlayer.sharedInstance.isPlaying) {
          ByAudioPlayer.sharedInstance.stop();
        } else {
          ByAudioPlayer.sharedInstance.play(widget.recordingFilePath);
        }
      },
      child: ByWidgetsUtil.gradientBgContainer(
        gradient: ByColorUtil.lineareGradient(
          colorStart: const Color(0xFF6978FD),
          colorEnd: const Color(0xFFAF30FF),
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        padding: EdgeInsets.all(10.w),
        child: Row(
          key: UniqueKey(),
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              alignment: Alignment.centerLeft,
              child: Image.asset(
                isPlayingIcon,
                width: 24.w,
                height: 24.h,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 20.w),
            Image.asset(
              "assets/home/icon_audio_wave.png",
              width: 204.w,
              height: 20.h,
              fit: BoxFit.contain,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    byAudioPlayer.stop();
    super.dispose();
  }
}



// class AudioPlayBar extends StatelessWidget {
//   const AudioPlayBar({
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ByWidgetsUtil.gradientBgContainer(
//       gradient: ByColorUtil.lineareGradient(
//         colorStart: const Color(0xFF6978FD),
//         colorEnd: const Color(0xFFAF30FF),
//         begin: Alignment.centerLeft,
//         end: Alignment.centerRight,
//       ),
//       padding: EdgeInsets.all(10.w),
//       child: Row(
//         children: [
//           Image.asset(
//             "assets/home/icon_audio_play.png",
//             width: 24.w,
//             height: 24.h,
//             fit: BoxFit.contain,
//           ),
//           SizedBox(width: 20.w),
//           Image.asset(
//             "assets/home/icon_audio_wave.png",
//             width: 204.w,
//             height: 20.h,
//             fit: BoxFit.contain,
//           ),
//           const Spacer(),
//         ],
//       ),
//     );
//   }
// }
