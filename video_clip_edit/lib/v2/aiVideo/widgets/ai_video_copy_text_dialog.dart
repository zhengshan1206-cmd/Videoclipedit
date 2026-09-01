import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import '../models/ai_video_generation_model.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';

class AiVideoCopyTextDialog extends StatelessWidget {
  const AiVideoCopyTextDialog({
    super.key,
    required this.videoBean,
  });

  final AiVideoGenerationTaskModel videoBean;
  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiVideoCopyTextDialog_build");
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const Spacer(),
          Container(
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
                SizedBox(height: 20.h),
                _buildTitle(context),
                SizedBox(height: 20.h),
                if (videoBean.prompt != null)
                  SizedBox(
                    height: 200.h,
                    child: ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: ByWidgetsUtil.commonText(
                              text: videoBean.prompt!,
                              maxLines: 10000,
                              textColor:
                                  ByColorUtil.CommonTextColor.withOpacity(
                                0.8,
                              )),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20.h),
                _buildBottomBar(context)
              ],
            ),
          )
        ],
      ),
    );
  }

  Container _buildBottomBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        bottom: 8.h,
      ),
      height: 50.h,
      child: Row(
        children: [
          Expanded(
            child: ByWidgetsUtil.commonBtn(
              title: "复制",
              fontSize: 16.sp,
              borderRadius: 12.w,
              padding: EdgeInsets.zero,
              fontWeight: FontWeight.w500,
              textColor: ByColorUtil.WhiteColor,
              onClick: () {
                Clipboard.setData(ClipboardData(text: videoBean.prompt ?? ""));
                BotToast.showText(text: "复制成功");
                // Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          SizedBox(
            width: 18.w,
            height: 14.h,
          ),
          const Spacer(),
          ByWidgetsUtil.commonText(
            text: "视频内容",
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SizedBox(
              width: 18.w,
              height: 14.h,
              child: Image.asset(
                "assets/home/icon_close_dark.png",
                width: 14.w,
                height: 14.h,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
    );
  }
}

enum AiSettingsItemtype {
  /// 视频播放倍速
  times,

  /// 配音语速
  voiceSpeed,

  /// 配音音量
  voiceVolume,

  /// bgm语速
  bgmSpeed,

  /// bgm音量
  bgmVolume,
}

class AiSettingsItemView extends StatelessWidget {
  const AiSettingsItemView({
    super.key,
    required this.title,
    required this.type,
    required this.minValue,
    required this.maxValue,
    this.initialValue = 0,
  });

  final String title;
  final AiSettingsItemtype type;
  final double initialValue;
  final double minValue;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    double getCurrentValue() {
      switch (type) {
        case AiSettingsItemtype.times:
          return context.select<AiCartoonProvider, double>(
            (value) => value.videoTimes,
          );
        case AiSettingsItemtype.voiceSpeed:
          return context.select<AiCartoonProvider, double>(
            (value) => value.voiceSpeed,
          );
        case AiSettingsItemtype.voiceVolume:
          return context.select<AiCartoonProvider, double>(
            (value) => value.voiceVolume,
          );
        case AiSettingsItemtype.bgmSpeed:
          return context.select<AiCartoonProvider, double>(
            (value) => value.bgmSpeed,
          );
        case AiSettingsItemtype.bgmVolume:
          return context.select<AiCartoonProvider, double>(
            (value) => value.bgmVolume,
          );
        default:
      }
      return 0;
    }

    final provider = context.read<AiCartoonProvider>();
    onValueChanged(dynamic value) {
      switch (type) {
        case AiSettingsItemtype.times:
          provider.changeVideoTimes(value);
          break;
        case AiSettingsItemtype.voiceSpeed:
          provider.changeVoiceSpeed(value);
          break;
        case AiSettingsItemtype.voiceVolume:
          provider.changeVoiceVolume(value);
          break;
        case AiSettingsItemtype.bgmSpeed:
          provider.changeBgmSpeed(value);
          break;
        case AiSettingsItemtype.bgmVolume:
          provider.changeBgmVolume(value);
          break;
        default:
      }
    }

    final value = getCurrentValue();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ByWidgetsUtil.commonText(
            text: title,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 40.h,
            child: ByWidgetsUtil.commonContainer(
              borerRadius: 10.w,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              bgColor: ByColorUtil.CommonPageBgColor,
              child: Row(
                children: [
                  Expanded(
                    child: SfSlider(
                      min: minValue,
                      max: maxValue,
                      value: value,
                      // interval: 20,
                      showTicks: false,
                      showLabels: false,
                      enableTooltip: false,
                      minorTicksPerInterval: 1,
                      thumbIcon: SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset(
                          "assets/ai/ai_cartoon_slider_thumb.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      activeColor: ByColorUtil.TabTextColorSelected,
                      inactiveColor:
                          ByColorUtil.CommonTextColor.withOpacity(0.1),
                      onChanged: onValueChanged,
                    ),
                  ),
                  SizedBox(
                    width: 32.w,
                    child: ByWidgetsUtil.commonText(
                      textAlign: TextAlign.end,
                      fontSize: 14.sp,
                      text: value.toStringAsFixed(1),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
