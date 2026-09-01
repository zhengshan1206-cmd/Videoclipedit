import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

import '../../../routes/app_pages.dart';

typedef VoidCallback = void Function();

class DrawingView extends StatefulWidget {
  const DrawingView({
    super.key,
    this.fetchData,
    this.onRecords,
    this.onViewLater,
    required this.progressTitle,
  });

  final VoidCallback? fetchData;
  final VoidCallback? onRecords;
  final VoidCallback? onViewLater;
  final String progressTitle;

  @override
  State<DrawingView> createState() => _DrawingViewState();
}

class _DrawingViewState extends State<DrawingView> {
  @override
  void initState() {
    super.initState();

    /// 加载数据
    widget.fetchData?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Container(
          alignment: Alignment.center,
          child: Image.asset(
            "assets/common/loading_large.gif",
            width: 120.w,
            height: 124.h,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 40.h),
        ByWidgetsUtil.commonText(
          text: widget.progressTitle,
          fontSize: 16.sp,
          fontWeight: BYFontWeight.semiBold
        ),
        SizedBox(height: 10.h),
        ByWidgetsUtil.commonText(
          text: '预计10分钟左右完成，请耐心等待...',
          fontSize: 14.sp,
        ),
        SizedBox(height: 195.h),
        ByWidgetsUtil.commonRichText(
          texts: [
            const TextSpan(text: "去体验更多AI玩法，稍后在"),
            TextSpan(
              text: "【生成记录】",
              style: const TextStyle(color: ByColorUtil.LoginBtnBgColor),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.toNamed(Routes.storyManagementPage);
                  // widget.onRecords?.call();
                },
            ),
            const TextSpan(text: "中查看"),
          ],
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          textColor: ByColorUtil.CommonTextColor,
        ),
        SizedBox(height: 35.h),
        ByWidgetsUtil.physicalModel(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(
              top: 8.h,
              left: 12.w,
              right: 12.w,
              bottom: 8.h + ByScreenUtils.bottomSafeHeight,
            ),
            child: SizedBox(
              height: 50.h,
              child: ByWidgetsUtil.commonBtn(
                title: "稍后查看",
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                bgColor: ByColorUtil.LoginBtnBgColor,
                padding: EdgeInsets.zero,
                borderRadius: 12.w,
                onClick: () {
                  widget.onViewLater?.call();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
