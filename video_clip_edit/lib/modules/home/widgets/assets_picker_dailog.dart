import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

typedef AssetsPickerTypeSelectCallback = void Function(int);
bool isSelect = false;
class AssetsPickerDailog extends StatelessWidget {
  final AssetsPickerTypeSelectCallback onSelected;
  final String? albumTitle;
  final String? cameraTitle;
  final AssetsPickerTypeSelectCallback? onCancel;
  const AssetsPickerDailog({
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
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if(!isSelect) {
          onCancel?.call(-1);
        }
      },
      child:Column(
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
                          width: 12.w,
                          height: 12.w,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _buildMenuItem(
                      icon: "assets/home/icon_media_album.png",
                      title: albumTitle ?? "相册",
                      index: 0,
                      onSelected: (index){
                        isSelect = true;
                        onSelected(index);
                      }
                    ),
                    const Spacer(),
                    _buildMenuItem(
                      icon: "assets/home/icon_media_take_photo.png",
                      title: cameraTitle ?? "相机",
                      index: 1,
                      onSelected: (index){
                        isSelect = true;
                        onSelected(index);
                      }
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      )
    );
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
          borderRadius: BorderRadius.circular(15),
        ),
        width: 160.w,
        // height: 160.w,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 53.h),
            Image.asset(
              icon,
              width: 40.w,
              height: 40.w,
            ),
            const SizedBox(height: 41),
            ByWidgetsUtil.commonText(
              text: title,
              fontSize: 14.sp,
              textColor: const Color(0xfF0E1840),
            ),
            SizedBox(height: 18.5.h),
          ],
        ),
      ),
    );
  }
}
