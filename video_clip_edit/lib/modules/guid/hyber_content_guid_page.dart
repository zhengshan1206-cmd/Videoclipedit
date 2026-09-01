// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/guid/hyber_clip_guid_content_view.dart';
import 'package:video_clip_edit/modules/guid/video_loading_guid_page.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class HyberContentGuidPage extends StatefulWidget {
  final int index;
  const HyberContentGuidPage({
    super.key,
    required this.index,
  });

  @override
  State<HyberContentGuidPage> createState() => _HyberContentGuidPageState();
}

class _HyberContentGuidPageState extends State<HyberContentGuidPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ByNavRouterUtils.pushReplacement(
            context,
            const VideoLoadingGuidPage(
              isRecreate: true,
            ));
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: ByColorUtil.WhiteColor,
            appBar: _buildAppBar(context, false),
            resizeToAvoidBottomInset: false,
            body: HyberClipGuidContentView(
              index: widget.index,
            ),
          ),
          Positioned.fill(
              child: Container(
            color: ByColorUtil.BlackColor.withOpacity(0.5),
          )),
          Positioned(
            right: 12.w,
            left: 10.w,
            bottom: 8.w,
            child: Image.asset(
              "assets/guid/guid_recreate_hyber_content_tips_bottom.png",
              fit: BoxFit.fitWidth,
            ),
          ),
          ByWidgetsUtil.closeBtnForGuid(
            onTap: () {
              ByNavRouterUtils.goBack(context);
            },
          ),
          Positioned(
            bottom: 0,
            right: 50.w,
            child: ScaleTransitionWidget(
              child: Image.asset(
                "assets/purchase/icon_pointer.png",
                width: 45.w,
                height: 43.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// App Bar
  AppBar _buildAppBar(BuildContext context, bool isSpeedy) {
    return AppBar(
      centerTitle: true,
      leading: Container(),
      title: ByWidgetsUtil.commonText(
        text: "短剧二创",
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
      ),
    );
  }

  GestureDetector aloneBtnWithIcon({
    required String title,
    required String iconPath,
    required void Function() onClick,
    double? iconW,
    double? iconH,
    double? fontSize,
    double? borderRadius,
    FontWeight? fontWeight,
    EdgeInsetsGeometry? padding,
    Color? textColor = ByColorUtil.WhiteColor,
    Color? bgColor = ByColorUtil.LoginBtnBgColor,
    BoxDecoration? boxDecoration,
  }) {
    boxDecoration ??= BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius ?? 8.w),
      color: bgColor,
    );

    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 50.h,
        alignment: Alignment.centerLeft,
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
        decoration: boxDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              iconPath,
              fit: BoxFit.contain,
              width: iconW ?? 18.w,
              height: iconH ?? 18.w,
            ),
            SizedBox(width: 7.w),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize ?? 14.sp,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
