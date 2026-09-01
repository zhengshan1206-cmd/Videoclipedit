import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

typedef AssetsPickerTypeSelectCallback = void Function(int);

bool isSelect = false;

class AssetsPickerForVideoDialog extends StatelessWidget {
  final AssetsPickerTypeSelectCallback onSelected;
  final String? albumTitle;
  final String? cameraTitle;
  final AssetsPickerTypeSelectCallback? onCancel;

  const AssetsPickerForVideoDialog({
    super.key,
    required this.onSelected,
    this.albumTitle,
    this.cameraTitle,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    isSelect = false;
    return PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          if (!isSelect) {
            onCancel?.call(-1);
          }
        },
        child: Column(
          children: [
            const Spacer(),
            Container(
              padding: EdgeInsets.only(
                left: 15.w,
                right: 15.w,
                top: 10.h,
                bottom: 15.h + ByScreenUtils.bottomSafeHeight,
              ),
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
                  Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              onCancel?.call(-1);
                              ByNavRouterUtils.goBack(context);
                            },
                            child: Container(
                              width: 22.w,
                              height: 32.h,
                              alignment: Alignment.center,
                              child: Image.asset(
                                "assets/home/icon_close_dark.png",
                                width: 14.w,
                                height: 14.w,
                              ),
                            ),
                          )
                        ],
                      ),
                      Text(
                        "选择图片",
                        style: TextStyle(
                            color: Color(0xFF0B1843), fontSize: 16.sp,fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Column(
                    children: [
                      _buildMenuItem(
                          icon: "assets/ai/aiVideo/img_get_photo.png",
                          title: albumTitle ?? "本地上传",
                          index: 0,
                          onSelected: (index) {
                            isSelect = true;
                            onSelected(index);
                          }),
                      SizedBox(
                        height: 10.h,
                      ),
                      _buildMenuItem(
                          icon: "assets/ai/aiVideo/img_take_photo.png",
                          title: cameraTitle ?? "相机拍摄",
                          index: 1,
                          onSelected: (index) {
                            isSelect = true;
                            onSelected(index);
                          }),
                      SizedBox(
                        height: 10.h,
                      ),
                      _buildMenuItem(
                          icon: "assets/ai/aiVideo/img_my_created.png",
                          title: albumTitle ?? "我的创作",
                          index: 2,
                          onSelected: (index) {
                            isSelect = true;
                            onSelected(index);
                          }),
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
  }

  GestureDetector _buildMenuItem({
    required AssetsPickerTypeSelectCallback onSelected,
    required String icon,
    required String title,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        onSelected(index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: ByColorUtil.CommonPageBgColor,
          borderRadius: BorderRadius.circular(12.w),
        ),
        width: double.infinity,
        height: 60.h,
        alignment: Alignment.center,
        child: Row(
          children: [
            SizedBox(
              width: 20.w,
            ),
            Image.asset(
              icon,
              width: 32.w,
              height: 32.w,
            ),
            SizedBox(
              width: 18.w,
            ),
            Text(
              title,
              style: TextStyle(color: Color(0xFF0B1843), fontSize: 16.sp),
            ),
            const Expanded(child: SizedBox()),
            Image.asset(
              "assets/ai/aiVideo/img_next1_icon.png",
              width: 15.w,
              height: 15.w,
            ),
            SizedBox(
              width: 13.w,
            ),
          ],
        ),
      ),
    );
  }
}
