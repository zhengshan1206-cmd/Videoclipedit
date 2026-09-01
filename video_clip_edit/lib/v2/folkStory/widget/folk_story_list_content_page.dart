/*
  folk_story_list_content_page.dart
  民间故事列表页，配置信息
  Created by duncy on 25/4/23.
*/


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/v2/hotCreate/beans/hot_create_category_bean.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_provider.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_single_provider.dart';
import 'package:video_clip_edit/v2/promote/beans/promotion_category_bean.dart';

import 'folk_story_list_novel_content_page.dart';

class FolkStoryListContentPage extends StatelessWidget {
  const FolkStoryListContentPage({
    super.key,
    required this.pageController,
    required this.onPageChanged,
    required this.promoteType,
  });
  final PageController pageController;
  final void Function(int index) onPageChanged;
  final PromotionCategoryType promoteType;

  @override
  Widget build(BuildContext context) {
    final List<HotCreateCategoryBean> categoryBeans =
        context.select<NovelCreateProvider, List<HotCreateCategoryBean>>(
      (val) => val.categoryBeans,
    );

    return PageView.builder(
      controller: pageController,
      onPageChanged: onPageChanged,
      itemCount: categoryBeans.length,
      scrollDirection: Axis.horizontal,
      physics: const PageScrollPhysics(), // 指定滚动物理行为
      itemBuilder: (context, index) {
        final bean = categoryBeans[index];
        return ChangeNotifierProvider(
          create: (BuildContext context) => NovelCreateSingleProvider(),
          child: FolkStoryListNovelPage(
            categoryBean: bean,
            promoteType: promoteType,
            index: index,
          ),
        );
      },
    );
  }
}
