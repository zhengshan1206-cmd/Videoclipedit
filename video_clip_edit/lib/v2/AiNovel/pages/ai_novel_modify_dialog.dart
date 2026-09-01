import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class AiNovelModifyDialog extends StatelessWidget {
  const AiNovelModifyDialog({
    super.key,
    this.onDelete,
    this.onRename,
  });

  final void Function()? onDelete;
  final void Function()? onRename;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20.h, width: double.infinity),
            ByWidgetsUtil.commonText(
              text: "修改",
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 42.h),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ByNavRouterUtils.goBack(context);
                onRename?.call();
              },
              child: SizedBox(
                height: 50.h,
                child: ByWidgetsUtil.commonContainer(
                  borerRadius: 10.w,
                  bgColor: const Color(0xFFECF1F3),
                  child: Row(
                    children: [
                      SizedBox(width: 15.w),
                      Expanded(
                        child: ByWidgetsUtil.commonText(
                          text: "重命名",
                          fontSize: 16.sp,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Image.asset(
                        "assets/ai/oralVideos/ai_oral_icon_edit.png",
                        width: 20.w,
                        height: 20.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 17.w),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ByNavRouterUtils.goBack(context);
                onDelete?.call();
              },
              child: SizedBox(
                height: 50.h,
                child: ByWidgetsUtil.commonContainer(
                  borerRadius: 10.w,
                  bgColor: const Color(0xFFECF1F3),
                  child: Row(
                    children: [
                      SizedBox(width: 15.w),
                      Expanded(
                        child: ByWidgetsUtil.commonText(
                            text: "删除",
                            fontSize: 16.sp,
                            textAlign: TextAlign.left,
                            textColor: const Color(0xFFFF5373)),
                      ),
                      Image.asset(
                        "assets/ai/oralVideos/ai_oral_icon_delete.png",
                        width: 20.w,
                        height: 20.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 17.w),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 25.h + ByScreenUtils.bottomSafeHeight),
          ],
        ),
      ),
    );
  }
}
