import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/story/assistant/assistant_record_page.dart';
import 'package:video_clip_edit/modules/home/story/beans/story_argument_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/story/create/recent_tasks_page.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/modules/home/story/widgets/stroy_home_title_view.dart';

class StoryCreateHomePage extends StatefulWidget {
  final int select;
  const StoryCreateHomePage({super.key, required this.select});

  @override
  State<StoryCreateHomePage> createState() => _StoryCreateHomePageState();
}

class _StoryCreateHomePageState extends State<StoryCreateHomePage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final index = context.select<StroyCreateProvider, int>(
      (provider) => provider.selectedTabIndex,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F9),
      appBar: AppBar(
        bottom: ByWidgetsUtil.appBarBottom(),
        title: _buildTitle(),
        centerTitle: true,
        actions: [
          if (index == 0)
            ByWidgetsUtil.commonBtn(
              title: "创作记录",
              bgColor: Colors.transparent,
              fontSize: 14.sp,
              textColor: ByColorUtil.CommonTextColor,
              fontWeight: FontWeight.normal,
              onClick: () {
                ByNavRouterUtils.push(
                  context,
                  ChangeNotifierProvider.value(
                    value: context.read<StroyCreateProvider>(),
                    child: const RecentTasksPage(),
                  ),
                );
              },
            ),
          if (index == 1)
            ByWidgetsUtil.commonBtn(
              title: "历史记录",
              bgColor: Colors.transparent,
              fontSize: 14.sp,
              textColor: ByColorUtil.CommonTextColor,
              fontWeight: FontWeight.normal,
              onClick: () {
                ByNavRouterUtils.push(
                  context,
                  ChangeNotifierProvider.value(
                    value: context.read<StroyCreateProvider>(),
                    child:  AssistantRecordPage(),
                  ),
                );
              },
            )
        ],
      ),
      body: Consumer<StroyCreateProvider>(
        builder: (context, p, child) {
          return p.pages[p.selectedTabIndex];
        },
      ),
    );
  }

  initData() {
    StroyCreateProvider provider = context.read<StroyCreateProvider>();

    provider.updateSelectedTabIndex(widget.select);

    StoryArgumentBean? bean =
        ModalRoute.of(context)?.settings.arguments as StoryArgumentBean?;

    if (bean != null) provider.updateTypeId(bean.typeId);
  }

  Widget _buildTitle() => const StoryHomeTitleView();
}
