import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

///生成模式选择弹窗
class VideoDurationDialog extends StatefulWidget {
  final int? videoDuration;

  const VideoDurationDialog({super.key, required this.videoDuration});

  @override
  State<VideoDurationDialog> createState() => _VideoDurationDialogState();
}

class _VideoDurationDialogState extends State<VideoDurationDialog> {
  int? _videoDuration;

  @override
  void initState() {
    _videoDuration = widget.videoDuration;
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
            text: "视频时长",
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
  Widget _videoDurationItem({
    required int duration,
  }) {
    return GestureDetector(
      onTap: () {
        if (duration != _videoDuration) {
          _videoDuration = duration;
          setState(() {});
        }
      },
      child: Container(
        height: 48.h,
        margin: EdgeInsets.only(top: 10.w, right: 12.w, left: 12.w),
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
            color: duration == _videoDuration
                ? const Color(0XFFF4F6FF)
                : const Color(0XFFF8FAFB),
            border: duration == _videoDuration
                ? Border.all(color: const Color(0XFF5B4BF7), width: 2.w)
                : null,
            borderRadius: BorderRadius.circular(12.w)),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: "${duration}S",
                style: TextStyle(
                    fontSize: 16.sp,
                    color: duration == _videoDuration
                        ? const Color(0XFF5B4BF7)
                        : const Color(0XFF0B1843))),
            TextSpan(
                text: map[duration],
                style: TextStyle(
                    fontSize: 12.sp,
                    color: duration == _videoDuration
                        ? const Color(0XFF5B4BF7)
                        : const Color(0XFF0B1843)))
          ]),
        ),
      ),
    );
  }

  Map<int, String> map = {5: "（生成速度快）", 10: "（生成速度慢）"};

  ///确定按钮
  Widget _confirmBtn() {
    return InkResponse(
      onTap: () {
        Get.back(result: [_videoDuration]);
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
              _videoDurationItem(duration: 5),
              _videoDurationItem(duration: 10),
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
