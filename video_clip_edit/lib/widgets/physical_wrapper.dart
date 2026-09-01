import 'package:flutter/material.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

class PhysicalWrapper extends StatelessWidget {
  final double opacity;
  final Widget child;
  const PhysicalWrapper({
    super.key,
    required this.opacity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.white.withOpacity(1 - opacity),
      shadowColor: ByColorUtil.CommonPageBgColor.withOpacity(1 - opacity),
      elevation: 5,
      child: child,
    );
  }
}
