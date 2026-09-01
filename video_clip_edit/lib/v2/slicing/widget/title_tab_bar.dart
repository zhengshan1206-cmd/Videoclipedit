import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TitleTabBar extends StatefulWidget {
  final List<String> tabs;
  final List<String> selectedImages;
  final List<String> unselectedImages;
  final Color? selectedColor;
  final Color? unselectedColor;
  final int initialSelectedIndex;
  final Function(int) onTabSelected;
  final double? selectedFontSize;
  final double? unselectedFontSize;
  final double? tabHeight;
  final String? selectedIcon;

  const TitleTabBar({
    super.key,
    required this.tabs,
    required this.selectedImages,
    required this.unselectedImages,
    this.selectedColor,
    this.unselectedColor,
    required this.onTabSelected,
    this.initialSelectedIndex = 0,
    this.selectedFontSize,
    this.unselectedFontSize,
    this.tabHeight,
    this.selectedIcon,
  });

  @override
  State<TitleTabBar> createState() => _TitleTabBarState();
}

class _TitleTabBarState extends State<TitleTabBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        widget.tabs.length,
        (index) => _buildTabItem(index),
      ),
    );
  }

  Widget _buildTabItem(int index) {
    final bool isSelected = index == _selectedIndex;
    final bool isLast = index == widget.tabs.length - 1;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            _selectedIndex = index;
          });
          widget.onTabSelected(index);
        }
      },
      child: Container(
        height: widget.tabHeight ?? 35.h,
        alignment: Alignment.center,
        padding: EdgeInsets.only(right: isLast ? 0 : 18.w),
        child: isSelected
            ? _buildSelectedTab(widget.tabs[index], index)
            : _buildUnselectedTab(widget.tabs[index], index),
      ),
    );
  }

  Widget _buildSelectedTab(String title, int index) {
    return Image.asset(
      widget.selectedImages[index],
      height: widget.tabHeight ?? 28.h,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _buildUnselectedTab(String title, int index) {
    return Image.asset(
      widget.unselectedImages[index],
      height: widget.tabHeight ?? 28.h,
      fit: BoxFit.fitHeight,
    );
  }
}
