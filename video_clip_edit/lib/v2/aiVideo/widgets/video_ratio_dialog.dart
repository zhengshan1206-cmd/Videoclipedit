import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/modules/ai/ai_video/image_edit_controller.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

///视频比例选择弹窗
class VideoRatioDialog extends StatefulWidget {
  final String? videoRatio;

  const VideoRatioDialog({super.key, required this.videoRatio});

  @override
  State<VideoRatioDialog> createState() => _VideoRatioDialogState();
}

class _VideoRatioDialogState extends State<VideoRatioDialog> {
  String? _videoRatio;

  @override
  void initState() {
    _videoRatio = widget.videoRatio;
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
            text: "视频比例",
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

  ///视频比例条目
  Widget _videoRatioItem({
    required ImageAspectRatio videoRatio,
  }) {
    return GestureDetector(
      onTap: () {
        if (videoRatio.label != _videoRatio) {
          _videoRatio = videoRatio.label;
          setState(() {});
        }
      },
      child: Container(
        height: 48.h,
        // alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
            color: videoRatio.label == _videoRatio
                ? const Color(0XFFF4F6FF)
                : const Color(0XFFF8FAFB),
            border: videoRatio.label == _videoRatio
                ? Border.all(color: const Color(0XFF5B4BF7), width: 2.w)
                : null,
            borderRadius: BorderRadius.circular(12.w)),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 15.w,),
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: Center(
                child: AspectRatio(
                  aspectRatio: videoRatio.value,
                  child: Container(
                    height: 24.w,
                    width: 24.h,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),
                        border: Border.all(
                            color: const Color(0xFF0B1843), width: 2.w)),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10.w,
            ),
            Text(
              videoRatio.label.replaceAll("/", ":"),
              style: const TextStyle(color: Color(0xFF0B1843)),
            )
          ],
        ),
      ),
    );
  }

  ///确定按钮
  Widget _confirmBtn() {
    return InkResponse(
      onTap: () {
        Get.back(result: [_videoRatio]);
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
              SizedBox(
                height: 20.h,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 12.w,
                  ),
                  Expanded(
                      child: _videoRatioItem(
                          videoRatio: ImageAspectRatio.ratio4_3)),
                  SizedBox(
                    width: 12.w,
                  ),
                  Expanded(
                      child: _videoRatioItem(
                          videoRatio: ImageAspectRatio.ratio3_4)),
                  SizedBox(
                    width: 12.w,
                  ),
                  Expanded(
                      child: _videoRatioItem(
                          videoRatio: ImageAspectRatio.ratio16_9)),
                  SizedBox(
                    width: 12.w,
                  ),
                ],
              ),
              SizedBox(
                height: 12.h,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 12.w,
                  ),
                  Expanded(
                      child: _videoRatioItem(
                          videoRatio: ImageAspectRatio.ratio9_16)),
                  SizedBox(
                    width: 12.w,
                  ),
                  Expanded(
                      child: _videoRatioItem(
                          videoRatio: ImageAspectRatio.ratio1_1)),
                  SizedBox(
                    width: 12.w,
                  ),

                  ///占位使用
                  Expanded(
                      child: Visibility(
                    visible: false,
                    child:
                        _videoRatioItem(videoRatio: ImageAspectRatio.ratio9_16),
                  )),
                  SizedBox(
                    width: 12.w,
                  ),
                ],
              ),
              SizedBox(
                height: 30.h,
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
