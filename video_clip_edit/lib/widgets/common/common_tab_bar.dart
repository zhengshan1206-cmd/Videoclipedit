import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

abstract class TabBarItem {
  String get tabText;

  String? get tabIcon;

  String? get markIcon;
}

///公共tabbar组件
class CommonTabBar extends StatelessWidget {
  const CommonTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.tabHeight,
    this.tabController,
    this.showMarkIcon = false,
    this.isScrollable = false,
    this.padding,
    this.spacing,
    this.selectedTextStyle,
    this.unselectedTextStyle,
  });

  final List<TabBarItem> tabs;

  final TabController? tabController;

  final Rx<int> currentIndex;

  ///是否显示标签
  final bool showMarkIcon;

  ///是否可滑动
  final bool isScrollable;

  ///Tab的高度
  final double tabHeight;

  final EdgeInsetsGeometry? padding;

  ///文字与图标的间距
  final double? spacing;

  final TextStyle? selectedTextStyle;

  final TextStyle? unselectedTextStyle;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.center,
      isScrollable: isScrollable,
      dividerColor: Colors.transparent,
      dividerHeight: 0,
      indicatorWeight: 0,
      indicator: const BoxDecoration(color: Colors.transparent),
      labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
      tabs: List.generate(tabs.length, (index) {
        return _buildTabItem(tabs[index], index);
      }),
    );
  }

  _buildTabItem(TabBarItem tabBarItem, int index) {
    final hasTabIcon =
        tabBarItem.tabIcon != null && tabBarItem.tabIcon!.isNotEmpty;
    final hasMarkIcon =
        tabBarItem.markIcon != null && tabBarItem.markIcon!.isNotEmpty;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Obx(() {
          return Container(
            height: tabHeight,
            margin: EdgeInsets.only(top: showMarkIcon ? 8.h : 0),
            decoration: currentIndex.value == index
                ? _getSelectBoxDecoration()
                : _getBoxDecoration(),
            padding: padding ?? EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasTabIcon)
                  (tabBarItem.tabIcon?.startsWith(RegExp(r'^https?://')) ??
                          false)
                      ? CachedNetworkImage(
                          fadeInDuration: Duration.zero,
                          alignment: Alignment.center,
                          width: 20.w,
                          height: 20.h,
                          imageUrl: tabBarItem.tabIcon!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          tabBarItem.tabIcon!,
                          fit: BoxFit.contain,
                          width: 20.w,
                          height: 20.h,
                        ),
                if (hasTabIcon) SizedBox(width: spacing ?? 4.w),
                Text(tabBarItem.tabText,
                    style: currentIndex.value == index
                        ? _getSelectedStyle()
                        : _getUnSelectedStyle()),
              ],
            ),
          );
        }),
        if (showMarkIcon && hasMarkIcon)
          Positioned(
            top: 0,
            right: 0,
            child: CachedNetworkImage(
              fadeInDuration: Duration.zero,
              alignment: Alignment.center,
              width: 23.w,
              height: 15.h,
              imageUrl: tabBarItem.markIcon!,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }

  _getBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
    );
  }

  _getSelectBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      color: ByColorUtil.colorEAEEFF,
    );
  }

  _getSelectedStyle() {
    return selectedTextStyle ??
        BYTextStyle.instance(16.sp,
            color: ByColorUtil.TabTextColorSelected,
            fontWeight: BYFontWeight.bold);
  }

  _getUnSelectedStyle() {
    return unselectedTextStyle ??
        BYTextStyle.instance(16.sp,
            color: ByColorUtil.CommonTextColor.withOpacity(0.6),
            fontWeight: BYFontWeight.medium);
  }
}

///公共的带有指示器tabbar组件
class CommonIndicatorTabBar extends StatelessWidget {
  const CommonIndicatorTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    this.tabController,
    this.isScrollable = false,
    this.padding,
    this.selectedTextStyle,
    this.unselectedTextStyle,
  });

  final List<TabBarItem> tabs;

  final TabController? tabController;

  final Rx<int> currentIndex;

  ///是否可滑动
  final bool isScrollable;

  final EdgeInsetsGeometry? padding;

  final TextStyle? selectedTextStyle;

  final TextStyle? unselectedTextStyle;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.center,
      isScrollable: isScrollable,
      dividerColor: Colors.transparent,
      dividerHeight: 0,
      indicatorWeight: 0,
      indicator: const BoxDecoration(color: Colors.transparent),
      labelPadding: EdgeInsets.zero,
      tabs: List.generate(tabs.length, (index) {
        return _buildTabItem(tabs[index], index);
      }),
    );
  }

  _buildTabItem(TabBarItem tabBarItem, int index) {
    return Obx(() {
      return Padding(
        padding: padding ??
            EdgeInsets.only(
                left: index != 0 ? 10.w : 0,
                right: index != tabs.length - 1 ? 10.w : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tabBarItem.tabText,
                style: currentIndex.value == index
                    ? _getSelectedStyle()
                    : _getUnSelectedStyle()),
            Container(
              width: 15.w,
              height: 3.h,
              margin: EdgeInsets.only(top: 5.h),
              color: currentIndex.value == index
                  ? ByColorUtil.TabTextColorSelected
                  : Colors.transparent,
            ),
          ],
        ),
      );
    });
  }

  _getSelectedStyle() {
    return selectedTextStyle ??
        BYTextStyle.instance(16.sp,
            color: ByColorUtil.TabTextColorSelected,
            fontWeight: BYFontWeight.medium);
  }

  _getUnSelectedStyle() {
    return unselectedTextStyle ??
        BYTextStyle.instance(16.sp,
            color: ByColorUtil.CommonTextColor,
            fontWeight: BYFontWeight.medium);
  }
}
