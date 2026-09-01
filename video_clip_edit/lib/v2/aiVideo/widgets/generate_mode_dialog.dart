import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

enum VideoQuality {
  standard("标准", "（普通画质）", 0, "std", "480P"),
  highQuality("高品质", "（高清晰度）", 1, "pro", "720P"),
  superHighQuality("超高品质", "（超高清晰度）", 2, "pro max", "1080P");

  final String label;
  final String subLabel;
  final int value;
  final String key;
  final String quality;

  const VideoQuality(this.label, this.subLabel, this.value, this.key, this.quality);

  static VideoQuality? fromString(int input) {
    return VideoQuality.values.firstWhere(
      (e) => e.value == input,
      orElse: () => throw ArgumentError("Invalid video quality: $input"),
    );
  }

  static VideoQuality? fromKey(String key) {
    try {
      return VideoQuality.values.firstWhere(
        (e) => e.key == key,
        orElse: () => throw ArgumentError("Invalid video quality: $key"),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => label;
}

///生成模式选择弹窗
class GenerateModeDialog extends StatefulWidget {
  final int? videoQuality;
  final bool? showQuality; ///是否显示清晰度
  final bool? showSuperQualityItem; ///是否显示超高清选择项

  const GenerateModeDialog({super.key, required this.videoQuality, this.showQuality = false, this.showSuperQualityItem = false});

  @override
  State<GenerateModeDialog> createState() => _GenerateModeDialogState();
}

class _GenerateModeDialogState extends State<GenerateModeDialog> {
  int? _videoQuality;

  @override
  void initState() {
    _videoQuality = widget.videoQuality;
    super.initState();
  }

  ///标题
  Widget _buildTitle({
    required BuildContext context,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 20.w, right: 15.w),
      child: Row(
        children: [
          SizedBox(
            width: 18.w,
            height: 14.h,
          ),
          const Spacer(),
          ByWidgetsUtil.commonText(
            text: "生成模式",
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
              height: 18.h,
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

  ///视频质量
  Widget _videoQualityItem({
    required VideoQuality quality,
  }) {
    return GestureDetector(
      onTap: () {
        if (quality.value != _videoQuality) {
          _videoQuality = quality.value;
          setState(() {});
        }
      },
      child: Container(
        height: 48.h,
        margin: EdgeInsets.only(top: 10.w, right: 12.w, left: 12.w),
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
            color: quality.value == _videoQuality
                ? const Color(0XFFF4F6FF)
                : const Color(0XFFF8FAFB),
            border: quality.value == _videoQuality
                ? Border.all(color: const Color(0XFF5B4BF7), width: 2.w)
                : null,
            borderRadius: BorderRadius.circular(12.w)),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: quality.label,
                style: TextStyle(
                    fontSize: 16.sp,
                    color: quality.value == _videoQuality
                        ? const Color(0XFF5B4BF7)
                        : const Color(0XFF0B1843))),
            TextSpan(
                text: widget.showQuality! ? "（${quality.quality}）": quality.subLabel,
                style: TextStyle(
                    fontSize: 12.sp,
                    color: quality.value == _videoQuality
                        ? const Color(0XFF5B4BF7)
                        : const Color(0XFF0B1843)))
          ]),
        ),
      ),
    );
  }

  ///确定按钮
  Widget _confirmBtn() {
    return InkResponse(
      onTap: () {
        Get.back(result: [_videoQuality]);
      },
      child: Container(
        alignment: Alignment.center,
        width: 1.sw,
        padding: EdgeInsets.only(top: 15.w, bottom: 15.w),
        margin: EdgeInsets.only(left: 12.w, right: 12.w),
        decoration: BoxDecoration(
            color: const Color(0XFF5B4BF7),
            borderRadius: BorderRadius.circular(12.w)),
        child: Text(
          "确定",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(child: SizedBox()),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.w),
                topRight: Radius.circular(18.w),
              )),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitle(context: context),
              _videoQualityItem(quality: VideoQuality.standard),
              _videoQualityItem(quality: VideoQuality.highQuality),
              if(widget.showSuperQualityItem!)
               _videoQualityItem(quality: VideoQuality.superHighQuality),
              SizedBox(
                height: 52.h,
              ),
              _confirmBtn(),
              SizedBox(
                height: 20.h,
              )
            ],
          ),
        )
      ],
    );
  }
}
