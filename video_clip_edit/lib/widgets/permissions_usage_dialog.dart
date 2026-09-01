import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/beans/permission_usage_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class PermissionsUsageDialog extends StatelessWidget {
  PermissionsUsageDialog({
    super.key,
    required this.permissionBeans,
  });

  final List<PermissionUsageBean> permissionBeans;
  final double gap = 10.h;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: double.infinity,
        child: ByWidgetsUtil.commonContainer(
          margin: EdgeInsets.only(
            left: 15.w,
            right: 15.w,
            bottom: ByScreenUtils.bottomSafeHeight + 20.h,
          ),
          padding:
              EdgeInsets.only(left: 15.w, right: 15.w, top: 20.h, bottom: 10.h),
          borerRadius: 10.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ByWidgetsUtil.commonText(
                text: "权限申请说明",
                fontSize: 17.sp,
                fontWeight: FontWeight.normal,
                textColor: ByColorUtil.CommonTextColor,
              ),
              SizedBox(height: gap),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final permission = permissionBeans[index];
                  final single = permissionBeans.length == 1;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ByWidgetsUtil.commonText(
                        text: single
                            ? permission.permissionName
                            : "${index + 1}、${permission.permissionName}",
                        maxLines: 100,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.normal,
                      ),
                      SizedBox(height: gap),
                      ByWidgetsUtil.commonText(
                        text: permission.usage,
                        maxLines: 100,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.normal,
                        textColor: ByColorUtil.CommonTextColor.withOpacity(0.7),
                      ),
                      SizedBox(height: gap),
                    ],
                  );
                },
                itemCount: permissionBeans.length,
              ),
              SizedBox(height: gap),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 50.w),
                child: ByWidgetsUtil.commonBtn(
                  title: "同意",
                  borderRadius: 50.h,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.normal,
                  onClick: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 50.w),
                child: ByWidgetsUtil.commonBtn(
                  bgColor: Colors.transparent,
                  title: "取消",
                  textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                  borderRadius: 50.h,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.normal,
                  onClick: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
