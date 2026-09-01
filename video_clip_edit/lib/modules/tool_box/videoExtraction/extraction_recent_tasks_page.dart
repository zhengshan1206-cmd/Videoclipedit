import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/extraction_task_view.dart';

class ExtractionRecentTasksPage extends StatefulWidget {
  const ExtractionRecentTasksPage({super.key});

  @override
  State<ExtractionRecentTasksPage> createState() =>
      _ExtractionRecentTasksPageState();
}

class _ExtractionRecentTasksPageState extends State<ExtractionRecentTasksPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecords();
      // 上报页面进入埋点
      ByNavigatorUtil.reportDataPoint(
        pageTag: "myworks_list_video_extraction_works",
        operateType: "view",
        funcDetailTag: "",
        funcDetailImg: "",
      );
    });
  }

  void _loadRecords() {
    final provider = context.read<VideoExtractionProvider>();
    provider.loadParseRecords();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoExtractionProvider>();
    final extractionRecordBeans = provider.extractionRecordBeans;
    final refCount = provider.refCount;
    return Scaffold(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      appBar: ByWidgetsUtil.appBar(context: context, title: "最近任务"),
      body: Padding(
        padding: EdgeInsets.only(
            top: 8.w,
            left: 12.w,
            right: 12.w,
            bottom: context.byBottomSafeHeight),
        child: Column(
          children: [
            _buildTipsbar(),
            SizedBox(height: 10.h),
            Expanded(
              child: EasyRefresh(
                refreshOnStart: true,
                onRefresh: () {
                  provider.loadParseRecords(refresh: true);
                },
                onLoad: () {
                  provider.loadParseRecords();
                },
                child: (extractionRecordBeans.isEmpty && refCount > 0)
                    ? ByWidgetsUtil.commonListNoDataView()
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10.w,
                          crossAxisSpacing: 10.w,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          return ExtractionTaskView(
                            myWorkBean: extractionRecordBeans[index],
                          );
                        },
                        itemCount: extractionRecordBeans.length,
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildTipsbar() {
    return ByWidgetsUtil.commonTipsBar("文件在云端存储7天，过期无法恢复，请及时保存。");
  }
}
