import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

enum VideoType {
  tweets,
  clip,
}

class VideoTypeSelectDialog extends StatelessWidget {
  const VideoTypeSelectDialog({
    super.key,
    required this.onSelected,
  });

  final void Function(VideoType type) onSelected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15.h, width: double.infinity),
            ByWidgetsUtil.commonText(
              fontSize: 16.sp,
              text: "选择视频类型",
              fontWeight: FontWeight.bold,
              textColor: ByColorUtil.CommonTextColor,
            ),
            SizedBox(height: 14.h),
            _buildSelectItem(
              context: context,
              title: "文字成片",
              desc: "小说文章自动转漫画视频。",
              iconPath: "assets/ai/hot/icon_tweets.png",
              type: VideoType.tweets,
            ),
            _buildSelectItem(
              context: context,
              title: "智能混剪",
              desc: "海量素材，极速成片。",
              iconPath: "assets/ai/hot/icon_clip.png",
              type: VideoType.clip,
            ),
            SizedBox(height: 18.h + ByScreenUtils.bottomSafeHeight),
          ],
        ),
        Positioned(
          right: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
              child: ByWidgetsUtil.svgAsset(
                filePath: "assets/ai/hot/icon_close.svg",
                width: 14,
                height: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectItem({
    required String title,
    required String desc,
    required String iconPath,
    required VideoType type,
    required BuildContext context,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).pop();
        onSelected(type);
      },
      child: ByWidgetsUtil.commonContainer(
        bgColor: const Color(0xFFF4F7F8),
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Row(
          children: [
            Image.asset(iconPath,
                width: 80.w, height: 80.w, fit: BoxFit.contain),
            SizedBox(width: 5.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ByWidgetsUtil.commonText(
                    fontSize: 18.sp,
                    text: title,
                    fontWeight: FontWeight.bold,
                    textColor: ByColorUtil.CommonTextColor,
                  ),
                  SizedBox(height: 5.h),
                  ByWidgetsUtil.commonText(
                    text: desc,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.normal,
                    textColor: ByColorUtil.CommonTextColor.withOpacity(0.6),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 32.h,
              child: ByWidgetsUtil.commonBtn(
                title: "去创作",
                fontSize: 14.sp,
                borderRadius: 100,
                fontWeight: FontWeight.w600,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                onClick: () {
                  Navigator.of(context).pop();
                  onSelected(type);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
