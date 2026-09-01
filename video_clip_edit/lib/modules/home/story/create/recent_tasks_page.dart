import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/modules/home/story/create/beans/ai_create_bean.dart';
import 'package:video_clip_edit/modules/home/story/create/widgets/recent_task_cell.dart';
import 'package:video_clip_edit/modules/profile/widgets/no_data_view.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class RecentTasksPage extends StatefulWidget {
  const RecentTasksPage({super.key});

  @override
  State<RecentTasksPage> createState() => _RecentTasksPageState();
}

class _RecentTasksPageState extends State<RecentTasksPage> {
  @override
  void initState() {
    super.initState();

    _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    final StroyCreateProvider provider = context.watch<StroyCreateProvider>();
    final beans = provider.aiCreateBeans;
    final len = beans.length;
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "最近任务"),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Padding(
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          top: 12.h,
          bottom: context.byBottomSafeHeight,
        ),
        child: Column(
          children: [
            ByWidgetsUtil.commonTipsBar("文字在云端存储7天，过期无法恢复，请及时保存。"),
            Expanded(
              child: len == 0
                  ? _buildNoData(context)
                  : EasyRefresh(
                      controller: provider.aiController,
                      onRefresh: () {
                        provider.aiPage = 1;
                        provider.loadAIRecords(
                          onSuccess: (p0) {},
                        );
                      },
                      onLoad: () {
                        provider.loadAIRecords(
                          onSuccess: (p0) {},
                        );
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 12.w),
                        itemCount: len,
                        itemBuilder: (context, index) {
                          final AiCreateBean bean = beans[index];
                          return RecentTaskCell(
                            showBottomMargin: index < 9,
                            taskCellBean: bean,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _buildNoData(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ByColorUtil.WhiteColor,
        borderRadius: BorderRadius.circular(15.h),
      ),
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 15.h),
      child: NoDataView(
        onTap: () {
          ByNavRouterUtils.goBack(context);
        },
      ),
    );
  }

  void _loadRecords() {
    final provider = context.read<StroyCreateProvider>();
    provider.loadAIRecords(
      onSuccess: (beans) {},
    );
  }
}
