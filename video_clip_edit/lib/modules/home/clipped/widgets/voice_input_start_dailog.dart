// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/widgets/by_translate_animate_widget.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/counter_widget.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';

class VoiceInputStartDailog<T extends MaterialBaseProvider>
    extends StatefulWidget {
  const VoiceInputStartDailog({super.key});

  @override
  State<VoiceInputStartDailog> createState() =>
      _VoiceInputStartDailogState<T>();
}

class _VoiceInputStartDailogState<T extends MaterialBaseProvider>
    extends State<VoiceInputStartDailog<T>> {
  @override
  void initState() {
    super.initState();

    /// 初始化录音机
    _initRecorder();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initRecorder() async {}

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
              bottom: 14.h + ByScreenUtils.bottomSafeHeight,
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
                SizedBox(height: 15.h),
                ByWidgetsUtil.commonTipsBar("为保证视频效果，语音输入时长请小于视频时长。"),
                SizedBox(height: 30.h),
                ByWidgetsUtil.commonText(
                  text: "正在录音中",
                  textColor: ByColorUtil.TabTextColorSelected,
                  fontSize: 14.sp,
                ),
                SizedBox(height: 19.h),
                const CounterWidget(),
                SizedBox(height: 16.h),
                _buildWave(),
                SizedBox(height: 15.h),
                _buildBtns(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding _buildWave() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26.w),
      child: ClipRect(
        child: ByTranslateAnimateWidget(
          child: Image.asset(
            "assets/home/voice_input_wave.png",
            width: double.infinity, //ByScreenUtils.screenWidth - 27.w,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }

  Row _buildBtns(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ByWidgetsUtil.commonBtn(
            bgColor: ByColorUtil.CommonTextColor.withOpacity(0.2),
            title: "取消",
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            onClick: () {
              ByNavRouterUtils.goBack(context);
            },
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: ByWidgetsUtil.commonBtn(
            title: "确定",
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            onClick: () async {
              // ByNavRouterUtils.goBack(context);

              // await ChannelOperate.toVideoEdit(false).then((data) {
              //   ByNavRouterUtils.pushReplacement(
              //     context,
              //     ChangeNotifierProvider.value(
              //       value: context.read<T>(),
              //       child: VoiceoverSubtitleAudioPage<T>(data, ""),
              //     ),
              //   );
              // });

              // ByNativeBridge.callNativeMethod(
              //     method: ByNativeMehod.record)
              //     .then((dynamic e) {
              //       if(e!=null){
              //         byDebugPrint(e, tag: "获取到原生结果：${e.toString()}");
              //         ByNavRouterUtils.pushReplacement(
              //           context,
              //           ChangeNotifierProvider.value(
              //             value: context.read<T>(),
              //             child: VoiceoverSubtitleAudioPage<T>(e,""),
              //           ),
              //         );
              //       }
              // });

              // String path = await _audioRecorder?.stopRecording() ?? "";
              // if (path.isEmpty) {
              //   BotToast.showText(text: "保存录音文件失败");
              //   return;
              // }

              // /// 保存到相册
              // await _audioRecorder?.saveToAlbum();
              // ByNavRouterUtils.goBack(context);
              // ByNavRouterUtils.pushReplacement(
              //   context,
              //   ChangeNotifierProvider.value(
              //     value: context.read<T>(),
              //     child: VoiceoverSubtitleAudioPage<T>(),
              //   ),
              // );
            },
          ),
        ),
        SizedBox(height: ByScreenUtils.bottomSafeHeight + 10.h),
      ],
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
}
