import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/profile/widgets/no_data_view.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class RecentTasksPage extends StatelessWidget {
  const RecentTasksPage({super.key});

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
            _buildWorkList(),
          ],
        ),
      )
    );
  }

  _buildTipsbar() {
    return ByWidgetsUtil.commonTipsBar("文件在云端存储7天，过期无法恢复，请及时保存。");
  }

  _buildWorkList() {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: Container(
          margin:
              EdgeInsets.only(bottom: ByScreenUtils.bottomSafeHeight + 12.h),
          color: ByColorUtil.WhiteColor,
          alignment: Alignment.center,
          height: 300.h,
          child: const NoDataView(),
        ),
      ),
    );
  }
}
