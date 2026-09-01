import 'package:flutter/material.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

class AiCommentaryProgressBar extends StatelessWidget {
  const AiCommentaryProgressBar({
    super.key,
    this.progressColor,
    this.trackColor,
    this.progress,
  });

  final Color? progressColor;
  final Color? trackColor;
  final double? progress;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: trackColor ?? const Color(0xFFF4F7F8),
            ),
          ),
          FractionallySizedBox(
            widthFactor: progress ?? 0.5,
            heightFactor: 1,
            child: Container(
              decoration: BoxDecoration(
                  color: progressColor ?? ByColorUtil.LoginBtnBgColor,
                  borderRadius: BorderRadius.circular(100)),
            ),
          ),
        ],
      ),
    );
  }
}
