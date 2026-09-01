import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTabBar extends StatefulWidget {
  final int initialIndex;
  final bool isScrollable;
  final Color tabBarColor;
  final List<Widget> tabs;
  final List<Widget> pages;
  final double tabBarHeight;
  final Color indicatorColor;
  final double indicatorWidth;
  final double indicatorRadius;
  final double indicatorHeight;
  final EdgeInsetsGeometry? tabPadding;
  final ValueChanged<int>? onTabChanged;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.pages,
    this.onTabChanged,
    this.indicatorColor = Colors.blue,
    this.indicatorHeight = 3.0,
    this.indicatorWidth = 20.0,
    this.indicatorRadius = 1.0,
    this.tabBarHeight = 48.0,
    this.initialIndex = 0,
    this.isScrollable = true,
    this.tabBarColor = Colors.white,
    this.tabPadding,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  late int _currentIndex;
  bool _isTabSwitching = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );

    _pageController = PageController(
      initialPage: widget.initialIndex,
    );

    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    try {
      if (_tabController.indexIsChanging) {
        // 这里处理Tab切换时的逻辑
        _isTabSwitching = true;

        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _isTabSwitching = false;
      }

      if (_currentIndex != _tabController.index) {
        setState(() {
          _currentIndex = _tabController.index;
        });

        if (widget.onTabChanged != null) {
          widget.onTabChanged!(_currentIndex);
        }
      }
    } catch (e) {
      // 捕获切换时的异常，避免崩溃
      _isTabSwitching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: _handlePageChange,
            children: widget.pages,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      alignment: Alignment.centerLeft,
      color: widget.tabBarColor,
      height: widget.tabBarHeight,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      child: TabBar(
        controller: _tabController,
        isScrollable: widget.isScrollable,
        padding: widget.tabPadding,
        indicatorWeight: 0,
        indicatorColor: Colors.transparent,
        labelPadding: EdgeInsets.zero, //symmetric(horizontal: 5.w),
        indicatorPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        tabs: widget.tabs,
        // 使用自定义指示器，并确保它完全安全
        indicator: _CustomTabIndicator(
          color: widget.indicatorColor,
          height: widget.indicatorHeight,
          width: widget.indicatorWidth,
          radius: widget.indicatorRadius,
        ),
        // 完全禁用默认指示器的绘制
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }

  void _handlePageChange(int index) {
    if (!_isTabSwitching && _currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });

      _tabController.animateTo(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      if (widget.onTabChanged != null) {
        widget.onTabChanged!(index);
      }
    }
  }
}

class _CustomTabIndicator extends Decoration {
  final Color color;
  final double height;
  final double width;
  final double radius;

  const _CustomTabIndicator({
    required this.color,
    required this.height,
    required this.width,
    required this.radius,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabIndicatorPainter(
      color: color,
      height: height,
      width: width,
      radius: radius,
    );
  }
}

class _CustomTabIndicatorPainter extends BoxPainter {
  final Color color;
  final double height;
  final double width;
  final double radius;

  _CustomTabIndicatorPainter({
    required this.color,
    required this.height,
    required this.width,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    // 检查 configuration.size 是否为 null，避免在切换时出现空值异常
    final size = configuration.size;
    if (size == null || size.width <= 0 || size.height <= 0) {
      return;
    }

    try {
      final Rect rect = offset & size;
      final Paint paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final double indicatorLeft = rect.left + (rect.width - width) / 2;
      final double indicatorRight = indicatorLeft + width;
      final double indicatorTop = rect.bottom - height;
      final double indicatorBottom = rect.bottom;

      // 确保指示器矩形有效
      if (indicatorRight <= indicatorLeft || indicatorBottom <= indicatorTop) {
        return;
      }

      final Rect indicatorRect = Rect.fromLTRB(
        indicatorLeft,
        indicatorTop,
        indicatorRight,
        indicatorBottom,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          indicatorRect,
          Radius.circular(radius),
        ),
        paint,
      );
    } catch (e) {
      // 捕获任何绘制异常，避免崩溃
      return;
    }
  }
}
