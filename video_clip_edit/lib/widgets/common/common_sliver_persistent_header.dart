import 'dart:math';
import 'package:flutter/material.dart';

///公共吸顶Widget
class CommonSliverPersistentHeader extends StatelessWidget {
  const CommonSliverPersistentHeader({
    super.key,
    required this.minHeight,
    required this.maxHeight,
    required this.pinned,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final bool pinned;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: pinned, /// 设置为true实现吸顶
      delegate: SliverDelegate(
        minHeight: minHeight,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  SliverDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
