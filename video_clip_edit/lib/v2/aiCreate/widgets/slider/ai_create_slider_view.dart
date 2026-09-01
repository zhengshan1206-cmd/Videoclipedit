import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

///音色配音滑块类型
enum AiCreateVoiceSliderType {
  ///配音-语速
  voiceSpeed,

  ///配音音量
  voiceVolume;

  String get title {
    switch (this) {
      case voiceSpeed:
        return '语速';
      case voiceVolume:
        return '音量';
    }
  }

  double get minValue {
    switch (this) {
      case voiceSpeed:
        return 0.5;
      case voiceVolume:
        return 0.5;
    }
  }

  double get maxValue {
    switch (this) {
      case voiceSpeed:
        return 2.0;
      case voiceVolume:
        return 3.0;
    }
  }

  double get defaultValue {
    switch (this) {
      case voiceSpeed:
        return 1.0;
      case voiceVolume:
        return 1.0;
    }
  }
}

///Ai创作滑块
class AiCreateSliderView extends StatefulWidget {
  const AiCreateSliderView({
    super.key,
    required this.sliderType,
    this.valueChanged,
    this.currentValue,
  });

  final AiCreateVoiceSliderType sliderType;
  final ValueChanged<double>? valueChanged;
  final double? currentValue;

  @override
  State<AiCreateSliderView> createState() => _AiCreateSliderViewState();
}

class _AiCreateSliderViewState extends State<AiCreateSliderView> {
  final sliderValue = Rx<double>(0.0);

  @override
  void initState() {
    super.initState();
    sliderValue.value = widget.currentValue ?? 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.h),
        color: ByColorUtil.colorF8FAFB,
      ),
      child: Row(
        children: [
          BYText.instance(widget.sliderType.title, 14.sp, fontWeight: BYFontWeight.medium),
          Expanded(
            child: Obx(() {
              return SfSlider(
                min: widget.sliderType.minValue,
                max: widget.sliderType.maxValue,
                value: sliderValue.value,
                showTicks: false,
                showLabels: false,
                enableTooltip: false,
                minorTicksPerInterval: 1,
                activeColor: ByColorUtil.TabTextColorSelected,
                inactiveColor: ByColorUtil.CommonTextColor.withOpacity(0.1),
                onChanged: (value) {
                  sliderValue.value = value;
                  widget.valueChanged?.call(value);
                },
              );
            }),
          ),
          Obx(
                () {
              final value = sliderValue.value;
              return BYText.instance(value.toStringAsFixed(1), 14.sp);
            },
          ),
        ],
      ),
    );
  }
}
