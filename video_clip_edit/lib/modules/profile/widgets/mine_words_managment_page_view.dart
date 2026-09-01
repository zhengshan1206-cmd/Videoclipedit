import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_words_management_provider.dart';

/// 工具底部的PageView整体
class MineWordsManagmentPageView extends StatelessWidget {
  const MineWordsManagmentPageView({
    super.key,
    required this.pageController,
    required this.onPageChanged,
  });
  final PageController pageController;
  final void Function(int index) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages =
        context.read<MineWordsManagementProvider>().pages;

    return PageView.builder(
      itemCount: pages.length,
      controller: pageController,
      onPageChanged: onPageChanged,
      physics: const PageScrollPhysics(),
      itemBuilder: (context, index) => pages[index],
    );
  }
}
