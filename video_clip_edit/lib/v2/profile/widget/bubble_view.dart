import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

class BubbleView extends StatefulWidget {
  const BubbleView({
    super.key,
    required this.tips,
  });

  final String tips;

  @override
  State<BubbleView> createState() => _BubbleViewState();
}

class _BubbleViewState extends State<BubbleView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  var _showChild = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);
    _animationController.addStatusListener(
          (status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _showChild = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var imageHeight = 170.w * 40 / 170;
    var marginTop = imageHeight * 17 / 40;
    var marginBottom = imageHeight * 8 / 40;
    return GestureDetector(
      onTap: () {
        _animationController.forward();
      },
      child: FadeTransition(
        opacity: _animation,
        child: _showChild
            ? Stack(
                children: [
                  Image.asset(Assets.commonIconBubbleBg, width: 170.w, height: imageHeight, fit: BoxFit.cover),
                  Positioned(
                    left: 7.w,
                    top: marginTop,
                    right: 7.5.w,
                    bottom: marginBottom,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BYText.instance(widget.tips, 14.sp,
                            color: ByColorUtil.LoginBtnBgColor, height: 1.0),
                        Image.asset(Assets.commonIconBubbleClose,
                            width: 15.w, height: 15.w),
                      ],
                    ),
                  ),
                ],
              )
            : Container(),
      ),
    );
  }
}
