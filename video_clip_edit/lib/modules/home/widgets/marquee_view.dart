import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:video_clip_edit/core/util/extension.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/modules/home/beans/home_broadcast_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

class MarqueeView extends StatelessWidget {
  final List<HomeBroadcastBean> broadcastBeans;

  final Image? image;

  final bool showBg;

  final String? tips;

  final EdgeInsetsGeometry? padding;

  const MarqueeView({
    super.key,
    required this.broadcastBeans,
    this.image,
    this.showBg = true,
    this.padding,
    this.tips,
  });

  List<TextSpan> _parseBroadcastbeans() {
    return broadcastBeans.map((bean) {
      final title = bean.title;
      final List<String> components = title.split("{");

      return TextSpan(text: components[0], children: [
        TextSpan(
          text: "${components[1].replaceAll("}", "")}  ",
          style: const TextStyle(
            fontSize: 12,
            color: ByColorUtil.TabTextColorMarquee,
          ),
        ),
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (showBg)
          Positioned.fill(
            child: Image.asset(
              "assets/home/home_marquee_bg.png",
              fit: BoxFit.fill,
            ),
          ),
        Padding(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          child: Row(
            children: [
              image ??
                  Image.asset(
                    Assets.homeHomeBell,
                    width: 18.w,
                    height: 18.w,
                    fit: BoxFit.cover,
                  ),
              SizedBox(width: 8.w),
              if (tips.isNotEmptyString())
                Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: BYText.instance(tips!, 12.sp),
                ),
              Expanded(
                child: MarqueeText(
                  text: TextSpan(
                    children: _parseBroadcastbeans(),
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: ByColorUtil.MainTextColor,
                  ),
                  speed: 30,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
