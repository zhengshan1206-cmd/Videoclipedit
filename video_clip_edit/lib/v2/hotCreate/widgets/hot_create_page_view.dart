import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/v2/hotCreate/single_novel_list_page.dart';
import 'package:video_clip_edit/v2/hotCreate/beans/hot_create_category_bean.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_provider.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_single_provider.dart';
import 'package:video_clip_edit/v2/promote/beans/promotion_category_bean.dart';

class HotCreatePageView extends StatelessWidget {
  const HotCreatePageView({
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
          create: (BuildContext context) {
            final singleProvider = NovelCreateSingleProvider();
            // 设置NovelCreateProvider引用
            final novelProvider = context.read<NovelCreateProvider>();
            singleProvider.setNovelCreateProvider(novelProvider);
            return singleProvider;
          },
          child: NovelListPage(
            categoryBean: bean,
            promoteType: promoteType,
            index: index,
          ),
        );
      },
    );
  }
}
