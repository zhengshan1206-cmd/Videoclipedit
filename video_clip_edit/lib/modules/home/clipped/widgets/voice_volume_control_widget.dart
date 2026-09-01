import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class VoiceVolumeControlWidget extends StatefulWidget {
  const VoiceVolumeControlWidget({
    super.key,
  });

  @override
  State<VoiceVolumeControlWidget> createState() =>
      _VoiceVolumeControlWidgetState();
}

class _VoiceVolumeControlWidgetState extends State<VoiceVolumeControlWidget> {
  double volume = 0;

  @override
  void initState() {
    super.initState();
    // Listen to system volume change
    VolumeController.instance.addListener((val) {
      setState(() => volume = val);
    });

    VolumeController.instance.getVolume().then((val) => volume = val);
  }

  @override
  void dispose() {
    VolumeController.instance.removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final volumeValue = volume * 100;
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 12.w,
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: ByColorUtil.WhiteColor,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: ByColorUtil.BlackColor.withOpacity(0.1),
            blurRadius: 2.w,
          ),
        ],
      ),
      child: Row(
        children: [
          ByWidgetsUtil.commonText(
            text: "音量",
            fontSize: 14.sp,
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Slider(
              value: volumeValue,
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: ByColorUtil.LoginBtnBgColor,
              inactiveColor: const Color(0xfFEFF4F5),
              thumbColor: ByColorUtil.LoginBtnBgColor,
              label: volumeValue.round().toString(),
              onChanged: (double value) {
                final vol = value / 100;
                VolumeController.instance.setVolume(vol);
                setState(() {
                  volume = vol;
                });
              },
            ),
          ),
          SizedBox(
            width: 30.w,
            child: ByWidgetsUtil.commonText(
              textAlign: TextAlign.right,
              text: volumeValue.round().toString(),
            ),
          )
        ],
      ),
    );
  }
}
