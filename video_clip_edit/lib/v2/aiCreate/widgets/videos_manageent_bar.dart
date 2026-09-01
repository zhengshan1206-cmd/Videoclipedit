import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class VideosManagementBar extends StatelessWidget {
  const VideosManagementBar({
    super.key,
    this.onCancel,
    this.onDelete,
    this.onDownload,
  });
  final void Function()? onCancel;
  final void Function()? onDelete;
  final void Function()? onDownload;

  /// 与 [ByScreenUtils.bottomInsetForScrollable] 一致，避免底栏白底高度小于列表留白，
  /// 折叠屏等机型上出现底部「镂空」透灰底。
  static double _bottomInset(BuildContext context) {
    return ByScreenUtils.bottomInsetForScrollable(context);
  }

  /// 与 [build] 中白底操作区 + 底部手势区总高度一致，供列表/滚动区底部留白，避免叠在底栏上。
  static double totalBarHeight(BuildContext context) {
    final rowH = ByScreenUtils.managementBottomActionRowHeight(44.h);
    final barH = ByScreenUtils.managementBottomBarSurfaceHeight(
      scaledBarH: 66.h,
      actionRowHeight: rowH,
    );
    return barH + _bottomInset(context);
  }

  @override
  Widget build(BuildContext context) {
    final rowH = ByScreenUtils.managementBottomActionRowHeight(44.h);
    final barH = ByScreenUtils.managementBottomBarSurfaceHeight(
      scaledBarH: 66.h,
      actionRowHeight: rowH,
    );
    final bottomInset = _bottomInset(context);

    // 1) Row 子项之间、按钮未铺满的槽位默认不绘制像素，Stack 下层列表会「透上来」；
    //    用 ColoredBox + stretch + SizedBox.expand 保证整条操作区为不透明白底。
    // 2) 鸿蒙等环境 bottom 可能为 0，SafeArea 不生效；用显式白底条盖住手势区。
    return Material(
      elevation: 10,
      color: ByColorUtil.WhiteColor,
      shadowColor: Colors.black26,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColoredBox(
            color: ByColorUtil.WhiteColor,
            child: SizedBox(
              height: barH,
              width: double.infinity,
              child: Center(
                child: SizedBox(
                  height: rowH,
                  child: ColoredBox(
                    color: ByColorUtil.WhiteColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: 12.w),
                        Expanded(
                          child: SizedBox.expand(
                            child: Center(
                              child: ByWidgetsUtil.commonBtn(
                                title: "取消",
                                fontSize: 16.sp,
                                borderRadius: 12.w,
                                fontWeight: FontWeight.w600,
                                bgColor:
                                    ByColorUtil.CommonTextColor.withOpacity(
                                        0.2),
                                textColor: ByColorUtil.WhiteColor,
                                onClick: () {
                                  onCancel?.call();
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: SizedBox.expand(
                            child: Center(
                              child: ByWidgetsUtil.commonBtn(
                                title: "删除",
                                fontSize: 16.sp,
                                borderRadius: 12.w,
                                fontWeight: FontWeight.w600,
                                bgColor: const Color(0xFFFF5373),
                                textColor: ByColorUtil.WhiteColor,
                                onClick: () {
                                  onDelete?.call();
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: SizedBox.expand(
                            child: Center(
                              child: ByWidgetsUtil.commonBtn(
                                title: " 下载",
                                fontSize: 16.sp,
                                borderRadius: 12.w,
                                fontWeight: FontWeight.w600,
                                textColor: ByColorUtil.WhiteColor,
                                bgColor: ByColorUtil.LoginBtnBgColor,
                                onClick: () {
                                  onDownload?.call();
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          ColoredBox(
            color: ByColorUtil.WhiteColor,
            child: SizedBox(
              width: double.infinity,
              height: bottomInset,
            ),
          ),
        ],
      ),
    );
  }
}
