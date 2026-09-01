import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/modules/profile/beans/my_work_bean.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class MyTaskView extends StatelessWidget {
  final MyWorkBean myWorkBean;
  const MyTaskView({
    super.key,
    required this.myWorkBean,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.w),
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: myWorkBean.fileCoverUrl,
            ),
          ),
          Positioned.fill(
            child: Offstage(
              offstage: true,
              child: Container(
                color: const Color(0xFFE5E9EC),
                child: Center(
                  child: Image.asset(
                    width: 82.w,
                    height: 82.w,
                    fit: BoxFit.contain,
                    "assets/mine/work_missed.png",
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Offstage(
              offstage: true,
              child: Container(
                alignment: Alignment.center,
                color: ByColorUtil.WhiteColor.withOpacity(0.5),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 90.w,
                    height: 32.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: ByColorUtil.LoginBtnBgColor,
                    ),
                    child: Text(
                      "继续编辑",
                      style: TextStyle(
                        color: ByColorUtil.WhiteColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Offstage(
              offstage: false,
              child: Container(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 40.w,
                  height: 40.h,
                  child: Image.asset("assets/home/icon_audio_play.png"),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10.w,
            bottom: 5.w,
            child: Text(
              myWorkBean.updatedAt.toIso8601String(),
              style: TextStyle(
                color: ByColorUtil.WhiteColor,
                fontSize: 12.sp,
              ),
            ),
          ),
          Positioned.fill(
            child: Offstage(
              offstage: true,
              child: Container(
                color: const Color(0xFFE6E9EB),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoActivityIndicator(
                      color: const Color(0xFF0E1840),
                      radius: 16.w,
                    ),
                    SizedBox(height: 30.h),
                    ByWidgetsUtil.commonText(
                        text: "去重中...",
                        textColor: ByColorUtil.CommonTextColor.withOpacity(0.5))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
