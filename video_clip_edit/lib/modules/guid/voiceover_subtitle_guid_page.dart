// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/guid/hyber_content_guid_page.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/widgets/pan_to_unfocus.dart';
import 'dart:math';

class VoiceoverSubtitleGuidPage extends StatefulWidget {
  const VoiceoverSubtitleGuidPage({super.key});

  @override
  State<VoiceoverSubtitleGuidPage> createState() =>
      _VoiceoverSubtitleGuidPageState();
}

class _VoiceoverSubtitleGuidPageState extends State<VoiceoverSubtitleGuidPage> {
  String words = "952-1119";
  @override
  void initState() {
    super.initState();
  }

  final index = Random().nextInt(100) % 5;

  @override
  void dispose() {
    EasyLoading.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ByNavRouterUtils.pushReplacement(
          context,
          ChangeNotifierProvider(
            create: (context) => ShowRecreateProvider(),
            child: HyberContentGuidPage(
              index: index,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: ByColorUtil.WhiteColor,
            appBar: _buildAppBar(context, false),
            resizeToAvoidBottomInset: false,
            body: PanToUnfocus(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 12.w,
                      right: 12.w,
                      top: 8.h,
                      bottom: 0,
                    ),
                    child: ByWidgetsUtil.commonRichTextTipsBar(textSpans: [
                      const TextSpan(text: "建议文案字数"),
                      TextSpan(
                        text: words,
                        style: const TextStyle(
                          color: Color(0xFFF62B60),
                        ),
                      ),
                      const TextSpan(text: "字，可基本适配画面时长。"),
                    ]),
                  ),
                  _buildContets(context),
                ],
              ),
            ),
          ),
          Positioned.fill(
              child: Container(
            color: ByColorUtil.BlackColor.withOpacity(0.5),
          )),
          Positioned(
            top: ByScreenUtils.topSafeHeight + (56.h - 20.h) * 0.5,
            left: 10.w,
            right: 2.w,
            child: Image.asset(
              "assets/guid/guid_recreate_voice_subtitle_tips_top_$index.png",
              fit: BoxFit.fitWidth,
            ),
          ),
          ByWidgetsUtil.closeBtnForGuid(
            onTap: () {
              ByNavRouterUtils.goBack(context);
            },
          ),
          Positioned(
            top: ByScreenUtils.topSafeHeight + 30.h,
            right: 0.w,
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

  Expanded _buildContets(BuildContext context) {
    return Expanded(
      child: Container(
        color: ByColorUtil.WhiteColor,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildActionsOne(context),
            SizedBox(height: 10.h),
            _buildActionsTwo(context),
            SizedBox(height: ByScreenUtils.bottomSafeHeight),
          ],
        ),
      ),
    );
  }

  /// 按钮行
  Row _buildActionsTwo(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: aloneBtnWithIcon(
              iconH: 16.w,
              iconW: 16.w,
              title: "选择音色",
              textColor: ByColorUtil.LoginBtnBgColor,
              iconPath: "assets/home/icon_one_key_dubbing.png",
              bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
              onClick: () {},
            ),
          ),
        ),
        SizedBox(width: 11.w),
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: aloneBtnWithIcon(
              iconH: 16.w,
              iconW: 16.w,
              title: "语音输入文字",
              textColor: ByColorUtil.LoginBtnBgColor,
              iconPath: "assets/home/icon_input_voice.png",
              bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
              onClick: () async {},
            ),
          ),
        ),
      ],
    );
  }

  /// 按钮行
  Row _buildActionsOne(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: aloneBtnWithIcon(
              iconH: 16.w,
              iconW: 16.w,
              title: "违禁词检测",
              textColor: ByColorUtil.LoginBtnBgColor,
              iconPath: "assets/home/icon_prohibited_words.png",
              bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
              onClick: () {},
            ),
          ),
        ),
        SizedBox(width: 11.w),
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: aloneBtnWithIcon(
              iconH: 16.w,
              iconW: 16.w,
              title: "风格改写",
              textColor: ByColorUtil.LoginBtnBgColor,
              iconPath: "assets/home/icon_style_edit.png",
              bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
              onClick: () {},
            ),
          ),
        ),
      ],
    );
  }

  /// App Bar
  AppBar _buildAppBar(BuildContext context, bool isSpeedy) {
    return AppBar(
      centerTitle: true,
      leading: Container(),
      title: ByWidgetsUtil.commonText(
        text: "解说文案",
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
