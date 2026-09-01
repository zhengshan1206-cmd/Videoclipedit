// ignore_for_file: use_build_context_synchronously

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/voice_input_start_dailog.dart';

class VoiceInputDailog<T extends MaterialBaseProvider> extends StatefulWidget {
  const VoiceInputDailog({super.key});

  @override
  State<VoiceInputDailog> createState() => _VoiceInputDailogState<T>();
}

class _VoiceInputDailogState<T extends MaterialBaseProvider>
    extends State<VoiceInputDailog<T>> {
  final TextEditingController wordsEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 11.w,
              right: 11.w,
            ),
            decoration: BoxDecoration(
              color: ByColorUtil.WhiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.w),
                topRight: Radius.circular(18.w),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 13.h),
                _buildTitle(context),
                SizedBox(height: 56.h),
                _buildVoiceWidget(context),
                SizedBox(height: 3.h),
                ByWidgetsUtil.commonText(
                  text: "点击开始录音",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  textColor: ByColorUtil.TabTextColorSelected,
                ),
                SizedBox(height: 19.h),
                Image.asset(
                  "assets/home/voice_input_bottom.png",
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector _buildVoiceWidget(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        _startInput(context);
      },
      onTap: () {
        _startInput(context);
      },
      child: Image.asset(
        "assets/home/icon_voice_input.png",
        width: 120.w,
        height: 120.h,
        fit: BoxFit.contain,
      ),
    );
  }

  /// 标题
  Row _buildTitle(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 30.w),
        const Spacer(),
        ByWidgetsUtil.commonText(
          text: "语音输入文字",
          textColor: ByColorUtil.CommonTextColor,
          fontSize: 16.sp,
        ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ByNavRouterUtils.goBack(context);
          },
          child: Container(
            width: 30.w,
            height: 30.w,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/login/login_dialog_close.png",
              width: 12,
              height: 12,
            ),
          ),
        ),
        // SizedBox(width: 11.w),
      ],
    );
  }

  /// 进入录音界面
  void _startInput(BuildContext context) async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      BotToast.showText(text: "请前往设置界面打开麦克风权限");
      return;
    }
    ByNavRouterUtils.goBack(context);
    showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: true,
      builder: (ctx) => ChangeNotifierProvider.value(
        value: context.read<T>(),
        child: VoiceInputStartDailog<T>(),
      ),
    );
  }
}
