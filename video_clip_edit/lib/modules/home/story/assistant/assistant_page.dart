import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/story/assistant/assistant_info_page.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/creator_bean.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/modules/home/story/assistant/widgets/assistant_item_cell.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  @override
  void initState() {
    super.initState();

    _loadCreators();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Container(
          //   height: 5.h,
          //   color: const Color(0xFFF5F8F9),
          // ),
          _buildAssistantListView(context),
        ],
      ),
    );
  }

  Expanded _buildAssistantListView(BuildContext context) {
    final List<CreatorBean> beans =
        context.select<StroyCreateProvider, List<CreatorBean>>(
      (p) => p.assisntItemBeans,
    );
    return Expanded(
      child: GridView.builder(
        itemCount: beans.length,
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          top: 15.h,
          bottom: 15.h + ByScreenUtils.bottomSafeHeight,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 13.h,
            crossAxisSpacing: 11.w,
            childAspectRatio: 17 / 9),
        itemBuilder: (context, index) {
          final bean = beans[index];
          return AssistantItemCell(
            bean: bean,
            index: index,
            callback: (CreatorBean bean) {
              ByNavRouterUtils.push(
                context,
                ChangeNotifierProvider.value(
                  value: context.read<StroyCreateProvider>(),
                  child: AssistantInfoPage(bean: bean),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _loadCreators() {
    StroyCreateProvider provider = context.read<StroyCreateProvider>();

    provider.loadCreators(
        call: provider.typeID.isNotEmpty
            ? () {
                final List<CreatorBean> beans =
                    context.read<StroyCreateProvider>().assisntItemBeans;
                var data = beans.where((e) => e.id == provider.typeID);
                if (data.isNotEmpty) {
                  CreatorBean bean = data.first;

                  ByNavRouterUtils.push(
                    context,
                    ChangeNotifierProvider.value(
                      value: context.read<StroyCreateProvider>(),
                      child: AssistantInfoPage(bean: bean),
                    ),
                  );
                }
              }
            : null);
  }
}
