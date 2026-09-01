import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';

class AiCartoonMoreSettingsDialog<T extends AiSettingsMixin>
    extends StatelessWidget {
  const AiCartoonMoreSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiCartoonMoreSettingsDialog_build");
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
                AiSettingsItemView<T>(
                  title: '视频播放倍数',
                  type: AiSettingsItemtype.times,
                  minValue: 0.5,
                  maxValue: 2,
                ),
                SizedBox(height: 10.h),
                AiSettingsItemView<T>(
                  title: '配音-语速',
                  type: AiSettingsItemtype.voiceSpeed,
                  minValue: 0.5,
                  maxValue: 2,
                ),
                SizedBox(height: 10.h),
                AiSettingsItemView<T>(
                  title: '配音-音量',
                  type: AiSettingsItemtype.voiceVolume,
                  minValue: 0.5,
                  maxValue: 3,
                ),
                SizedBox(height: 10.h),
                AiSettingsItemView<T>(
                  title: '背景音乐-语速',
                  type: AiSettingsItemtype.bgmSpeed,
                  minValue: 0.5,
                  maxValue: 2,
                ),
                SizedBox(height: 10.h),
                AiSettingsItemView<T>(
                  title: '背景音乐-音量',
                  type: AiSettingsItemtype.bgmVolume,
                  minValue: 0.5,
                  maxValue: 3,
                ),
                SizedBox(height: 30.h),
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
        bottom: 18.h,
      ),
      height: 50.h,
      child: Row(
        children: [
          Expanded(
            child: ByWidgetsUtil.commonBtn(
              title: "重置",
              fontSize: 16.sp,
              bgColor: const Color(0xFFCED1D9),
              borderRadius: 12.w,
              padding: EdgeInsets.zero,
              fontWeight: FontWeight.w500,
              textColor: ByColorUtil.WhiteColor,
              onClick: () {
                context.read<T>().resetMoreSettings();
              },
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: ByWidgetsUtil.commonBtn(
              title: "确定",
              fontSize: 16.sp,
              borderRadius: 12.w,
              padding: EdgeInsets.zero,
              fontWeight: FontWeight.w500,
              textColor: ByColorUtil.WhiteColor,
              onClick: () {
                Navigator.of(context).pop();
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
            text: "更多设置",
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

class AiSettingsItemView<T extends AiSettingsMixin> extends StatelessWidget {
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
          return context.select<T, double>(
            (value) => value.videoTimes,
          );
        case AiSettingsItemtype.voiceSpeed:
          return context.select<T, double>(
            (value) => value.voiceSpeed,
          );
        case AiSettingsItemtype.voiceVolume:
          return context.select<T, double>(
            (value) => value.voiceVolume,
          );
        case AiSettingsItemtype.bgmSpeed:
          return context.select<T, double>(
            (value) => value.bgmSpeed,
          );
        case AiSettingsItemtype.bgmVolume:
          return context.select<T, double>(
            (value) => value.bgmVolume,
          );
        default:
      }
      return 0;
    }

    final provider = context.read<T>();
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
              padding: EdgeInsets.only(right: 10.w),
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
                      // thumbIcon: SizedBox(
                      //   width: 30,
                      //   height: 30,
                      //   child: Image.asset(
                      //     "assets/ai/ai_cartoon_slider_thumb.png",
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                      activeColor: ByColorUtil.TabTextColorSelected,
                      inactiveColor:
                          ByColorUtil.CommonTextColor.withOpacity(0.1),
                      onChanged: onValueChanged,
                    ),
                  ),
                  ByWidgetsUtil.commonText(
                    textAlign: TextAlign.end,
                    fontSize: 14.sp,
                    text: value.toStringAsFixed(1),
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
