import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';

class NestedScrollWithCenteredCategory extends StatefulWidget {
  const NestedScrollWithCenteredCategory({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NestedScrollWithCenteredCategoryState createState() =>
      _NestedScrollWithCenteredCategoryState();
}

class _NestedScrollWithCenteredCategoryState
    extends State<NestedScrollWithCenteredCategory> {
  final PageController _pageController = PageController();
  final EasyRefreshController _easyRefreshController = EasyRefreshController();
  final ScrollController _categoryScrollController = ScrollController();

  int _currentCategoryIndex = 0;

  // 示例数据
  final List<String> _categories = [
    'Cat 1',
    'Cat 2',
    'Cat 3',
    'Cat 4',
    'Cat 5'
  ];
  final List<List<String>> _itemsPerCategory = List.generate(
    5,
    (index) => List.generate(20, (i) => 'Item $i of Category $index'),
  );

  // 滚动到选中的分类位置
  void _scrollToCategoryCenter(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    const itemWidth = 100.0; // 假设每个分类的宽度
    final scrollPosition = index * itemWidth - screenWidth / 2 + itemWidth / 2;

    _categoryScrollController.animateTo(
      scrollPosition.clamp(
          0.0, _categoryScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 分类点击切换 PageView
  void _onCategorySelected(int index) {
    _scrollToCategoryCenter(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentCategoryIndex = index;
    });
  }

  // PageView 滑动事件
  void _onPageChanged(int index) {
    setState(() {
      _currentCategoryIndex = index;
    });
    _scrollToCategoryCenter(index);
  }

  // 上拉加载更多
  Future<void> _loadMore(int categoryIndex) async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _itemsPerCategory[categoryIndex].addAll(
        List.generate(10,
            (i) => 'New Item ${_itemsPerCategory[categoryIndex].length + i}'),
      );
    });
    _easyRefreshController.finishLoad();
  }

  // 下拉刷新
  Future<void> _refresh(int categoryIndex) async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _itemsPerCategory[categoryIndex] = List.generate(
          20, (i) => 'Refreshed Item $i of Category $categoryIndex');
    });
    _easyRefreshController.finishRefresh();
  }

  // 分类列表组件
  Widget _buildCategoryList() {
    return Container(
      color: Colors.white,
      height: 50.0,
      child: ListView.builder(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _onCategorySelected(index),
            child: Container(
              width: 100.0,
              alignment: Alignment.center,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: _currentCategoryIndex == index
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  color: _currentCategoryIndex == index
                      ? Colors.orange
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // GridView 页
  Widget _buildGridView(int categoryIndex) {
    return EasyRefresh(
      controller: _easyRefreshController,
      onLoad: () => _loadMore(categoryIndex),
      onRefresh: () => _refresh(categoryIndex),
      child: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _itemsPerCategory[categoryIndex].length,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.lightBlueAccent,
            alignment: Alignment.center,
            child: Text(_itemsPerCategory[categoryIndex][index]),
          );
        },
      ),
    );
  }

  // PageView 包裹多个 GridView
  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        return _buildGridView(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // 轮播图
          SliverToBoxAdapter(
            child: Container(
              height: 200.0,
              color: Colors.blue,
              alignment: Alignment.center,
              child: const Text(
                "Carousel Placeholder",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          // 吸顶分类列表
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              child: _buildCategoryList(),
              minHeight: 50.0,
              maxHeight: 50.0,
            ),
          ),
        ],
        body: _buildPageView(),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _StickyHeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
