import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/beans/ai_squre_tab_bean.dart';

class AiStyleCasesView extends StatelessWidget {
  const AiStyleCasesView({super.key});

  @override
  Widget build(BuildContext context) {
    byDebugPrint("AiStyleCasesView-----build");
    AiSqureTabBean? aiSqureTabBean =
        context.select<AiSquareProvider, AiSqureTabBean?>(
      (p) => p.aiSqureTabBean,
    );
    final views = context.read<AiSquareProvider>().casesViews;
    final currentView = views[aiSqureTabBean?.id ?? 1] ??
        SliverToBoxAdapter(child: Container());
    return currentView;
    // if (aiSqureTabBean != null) {
    //   switch (aiSqureTabBean.id) {
    //     /// AI绘画
    //     case 1:
    //       return const AiCasesListView();

    //     /// AI推文
    //     case 3:
    //       return const AiCasesTweetsListView();

    //     /// AI写歌
    //     case 5:
    //       return const AiSongListView();

    //     /// AI其他
    //     default:
    //       return SliverToBoxAdapter(child: Container());
    //   }
    // } else {
    //   return SliverToBoxAdapter(child: Container());
    // }
  }
}
