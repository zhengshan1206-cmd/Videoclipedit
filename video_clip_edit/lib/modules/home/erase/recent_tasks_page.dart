import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/erase/beans/erease_record_bean.dart';
import 'package:video_clip_edit/modules/home/providers/video_erase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

import 'widgets/erease_task_view.dart';

class PictureRecentTasksPage extends StatefulWidget {
  const PictureRecentTasksPage({super.key});

  @override
  State<PictureRecentTasksPage> createState() => _PictureRecentTasksPageState();
}

class _PictureRecentTasksPageState extends State<PictureRecentTasksPage> {
  @override
  void initState() {
    super.initState();

    _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.CommonPageBgColor,
      appBar: ByWidgetsUtil.appBar(context: context, title: "我的创作"),
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
            _buildWorkList(context),
          ],
        ),
      )
    );
  }

  _buildTipsbar() {
    return ByWidgetsUtil.commonTipsBar("文件在云端存储7天，过期无法恢复，请及时保存。");
  }

  _buildWorkList(BuildContext context) {
    final beans = context.select<VideoEraseProvider, List<EreaseRecordBean>>(
      (provider) => provider.ereaseRecordBean,
    );
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.w,
          crossAxisSpacing: 10.w,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return EraseTaskView(
            myWorkBean: beans[index],
            type: EraseTaskViewType.picture,
          );
        },
        itemCount: beans.length,
      ),
    );
  }

  /// 获取擦除纪录
  void _loadRecords() {
    final VideoEraseProvider provider = context.read<VideoEraseProvider>();
    provider.loadEreaseRecords();
  }
}
