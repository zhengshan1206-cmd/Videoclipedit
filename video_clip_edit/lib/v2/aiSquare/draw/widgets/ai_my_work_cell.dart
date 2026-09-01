import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_datetime_ext.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_img_details_bean.dart';

class AiMyWorkCell extends StatelessWidget {
  const AiMyWorkCell({
    super.key,
    required this.bean,
  });

  final AiDrawImgDetailsBean bean;

  @override
  Widget build(BuildContext context) {
    byDebugPrint(bean.toJson());
    final status = bean.status;
    bool isCreating = [0, 1, 2].contains(status);
    bool isSuccess = status == 3;
    bool isFailed = status == 4;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.w),
      child: Stack(
        children: [
          Container(),
          Positioned.fill(
            child: Offstage(
              offstage: !isSuccess,
              child: CachedNetworkImage(
                imageUrl: bean.picUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Offstage(
              offstage: !isCreating,
              child: Container(
                alignment: Alignment.center,
                color: const Color(0xFFE6E9EB),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ByWidgetsUtil.activityIndicator(
                      radius: 16.w,
                      color: const Color(0xFF0E1840),
                    ),
                    SizedBox(height: 30.h),
                    ByWidgetsUtil.commonText(
                      text: "生成中···",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.normal,
                      textColor: const Color(0xFF0E1840),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Offstage(
              offstage: !isFailed,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/mine/work_failed_bg.png"),
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    width: 82.w,
                    height: 82.w,
                    fit: BoxFit.contain,
                    "assets/mine/work_failed.png",
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 40.h,
            child: ByWidgetsUtil.gradientBgContainer(
              padding: EdgeInsets.zero,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF000000).withOpacity(0.6),
                  const Color(0xFF000000).withOpacity(0),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 10.w, bottom: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    ByWidgetsUtil.commonText(
                      text: DateTime.now()
                          .formattedTime(format: "yyyy:MM:dd hh:mm"),
                      fontSize: 12.sp,
                      textColor: const Color(0xFFFFFFFF),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
