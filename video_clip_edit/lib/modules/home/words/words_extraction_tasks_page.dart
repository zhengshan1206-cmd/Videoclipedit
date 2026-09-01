import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/widgets/words_task_cell.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class WordsExtractionTasksPage extends StatefulWidget {
  const WordsExtractionTasksPage({
    super.key,
    this.showAppBar = true,
  });
  final bool showAppBar;

  @override
  State<WordsExtractionTasksPage> createState() =>
      _WordsExtractionTasksPageState();
}

class _WordsExtractionTasksPageState extends State<WordsExtractionTasksPage> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordsExtractProvider>();
    final taskBeans = provider.taskBeans;
    return Scaffold(
      appBar: widget.showAppBar
          ? ByWidgetsUtil.appBar(context: context, title: "最近任务")
          : null,
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Padding(
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          top: widget.showAppBar ? 12.h : 0,
          bottom: context.byBottomSafeHeight,
        ),
        child: Column(
          children: [
            if (widget.showAppBar)
              ByWidgetsUtil.commonTipsBar("文字在云端存储7天，过期无法恢复，请及时保存。"),
            Expanded(
              child: EasyRefresh(
                refreshOnStart: true,
                onRefresh: () {
                  provider.resetPages();
                  provider.loadRecords();
                },
                onLoad: () {
                  provider.loadRecords();
                },
                child: (provider.taskBeans.isEmpty && provider.refCount > 0)
                    ? Container(
                        margin: EdgeInsets.only(top: 10.h, bottom: 10.h),
                        child: ByWidgetsUtil.commonListNoDataView(),
                      )
                    : ListView.builder(
                        padding:
                            EdgeInsets.only(top: widget.showAppBar ? 12.w : 0),
                        itemCount: taskBeans.length,
                        itemBuilder: (context, index) {
                          return WordsTaskCell(
                            showBottomMargin: index < taskBeans.length - 1,
                            taskCellBean: taskBeans[index],
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
}
