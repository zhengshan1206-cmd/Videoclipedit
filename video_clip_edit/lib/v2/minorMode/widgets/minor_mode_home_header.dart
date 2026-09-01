import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/widgets/ai_cases_view.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/minorMode/beans/minor_page_type.dart';
import 'package:video_clip_edit/v2/minorMode/controllers/minor_mode_controller.dart';

class MinorModeHomeHeader extends StatelessWidget {
  const MinorModeHomeHeader({super.key});

  void _openPasswordVerify(MinorVerifyIntent intent) {
    Get.toNamed(
      Routes.minorCreatePage,
      arguments: MinorCreateRouteArgs(
        pageType: MinorPageType.enterPassword,
        verifyIntent: intent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final enabled = MinorModeController.to.isMinorModeEnabled;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          children: [
            Expanded(
              child: _MinorModeHeaderButton(
                label: enabled ? '关闭未成年人模式' : '开启未成年人模式',
                icon: enabled ? Icons.lock_outline : Icons.lock_open_outlined,
                onTap: () => _openPasswordVerify(
                  enabled
                      ? MinorVerifyIntent.closeMinorMode
                      : MinorVerifyIntent.openMinorMode,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _MinorModeHeaderButton(
                label: '时间管理',
                icon: Icons.access_time,
                showArrow: true,
                onTap: () =>
                    _openPasswordVerify(MinorVerifyIntent.openTimeManage),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// 未成年人模式首页 Sliver Header，需直接放入 NestedScrollView.headerSliverBuilder。
class MinorModeHomeSliverHeader extends StatelessWidget {
  const MinorModeHomeSliverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final headerH = 56.h + ByScreenUtils.topSafeHeight;
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: StickyHeaderDelegate(
        minHeight: headerH,
        maxHeight: headerH,
        onPinned: (pinned) =>
            context.read<AiSquareProvider>().changepPinnedHeaderHeight(
              pinned ? ByScreenUtils.topSafeHeight : 0,
            ),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(top: ByScreenUtils.topSafeHeight),
          child: const Align(
            alignment: Alignment.center,
            child: MinorModeHomeHeader(),
          ),
        ),
      ),
    );
  }
}

class _MinorModeHeaderButton extends StatelessWidget {
  const _MinorModeHeaderButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.showArrow = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F9),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: ByColorUtil.CommonTextColor),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: ByColorUtil.CommonTextColor,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                size: 18.sp,
                color: ByColorUtil.CommonTextColor.withOpacity(0.45),
              ),
          ],
        ),
      ),
    );
  }
}
