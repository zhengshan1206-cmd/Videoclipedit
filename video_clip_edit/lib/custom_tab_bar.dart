import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> tabs;
  final Function(int) onTabSelected;
  final int initialSelectedIndex;

  const CustomTabBar({
    Key? key,
    required this.tabs,
    required this.onTabSelected,
    this.initialSelectedIndex = 0,
  }) : super(key: key);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          widget.tabs.length,
          (index) => _buildTabItem(index),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index) {
    final bool isSelected = index == _selectedIndex;

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: isSelected
            ? _buildSelectedTab(widget.tabs[index])
            : _buildUnselectedTab(widget.tabs[index]),
      ),
    );
  }

  Widget _buildSelectedTab(String title) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnselectedTab(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.grey,
      ),
    );
  }
}
